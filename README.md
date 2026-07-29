# Highly Available WordPress on GCP

This project packages the supplied WordPress 4.9.4 site without modifying it
and builds toward a highly available, autoscaling Google Cloud environment.
The current deployment slice provides one privately networked server backed by
Cloud SQL. Later slices add the public HTTPS load balancer, durable media,
autoscaling, autohealing, and a database replica.

## Prerequisites

Before starting, install:

- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) (`gcloud`)
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.5 or later
- [Docker](https://docs.docker.com/engine/install/)
- [`openssl`](https://www.openssl.org/)
- A load-generation tool such as [`hey`](https://github.com/rakyll/hey) or
  ApacheBench (`ab`)

You also need a Google account that can create projects and link them to an
open billing account. Authenticate both the `gcloud` CLI and Terraform:

```bash
gcloud auth login
gcloud auth application-default login
```

Run every command below from the repository root.

## Create and configure the project

The project ID and region are declared as variable defaults in
`terraform/bootstrap/variables.tf`. Terraform reads them from there with no
flags, so retargeting the deployment starts by changing those two defaults.

The region is assumed to offer `e2-medium`, the shared-core `db-g1-small`
database tier, and Artifact Registry. If you change it, confirm all three before
deploying.

The project-creation steps below run before Terraform does, so set the same two
values in your shell for them:

```bash
export PROJECT_ID=wideops-wordpress
export REGION=europe-north2
```

Create the project once. The display name and globally unique project ID both
come from `PROJECT_ID`:

```bash
gcloud projects create "${PROJECT_ID}" --name="${PROJECT_ID}"
```

If the project already exists under your account, skip that command. If Google
reports that the ID belongs to someone else, choose another globally unique ID,
update it in `terraform/bootstrap/variables.tf` and in the `image` target of the
`Makefile`, re-export `PROJECT_ID`, and retry.

List the open billing accounts available to your user:

```bash
gcloud billing accounts list --filter='open=true'
```

Copy the required account ID from the `ACCOUNT_ID` column, then link it to the
new project:

```bash
export BILLING_ACCOUNT_ID="replace-with-account-id"
gcloud billing projects link "${PROJECT_ID}" \
  --billing-account="${BILLING_ACCOUNT_ID}"
```

Make the new project the default for interactive commands and for Application
Default Credentials. Terraform receives its project explicitly, but aligning
these defaults prevents quota warnings and accidental commands against another
project:

```bash
gcloud config set project "${PROJECT_ID}"
gcloud auth application-default set-quota-project "${PROJECT_ID}"
```

Confirm that the project is active and billing is enabled:

```bash
gcloud projects describe "${PROJECT_ID}" \
  --format='value(projectId,lifecycleState)'
gcloud billing projects describe "${PROJECT_ID}" \
  --format='value(billingEnabled)'
```

Expected: the configured project ID followed by `ACTIVE`, then `True`.

## Pre-deployment check

Before creating cloud infrastructure, build and run the real migrated site
locally:

```bash
make local-check
```

`compose.yaml` starts MySQL and WordPress as two containers, with a named volume
sharing MySQL's Unix socket between them. PHP gives the literal host `localhost`
special treatment and uses that socket rather than TCP, so the supplied
`wp-config.php` connects unmodified. Because the socket is the only path in,
MySQL publishes no port and binds only its own loopback; the site is the single
thing exposed to the host, on port 80.

The supplied dump and the shared URL rewrite are mounted into MySQL's
`docker-entrypoint-initdb.d`, so they are applied by the database's own
first-run initialisation rather than by an external script. WordPress waits on a
MySQL health check that connects over TCP, which the initialising server does not
serve — so the site never starts against a half-imported database. The target is
re-runnable: it tears the previous run down before bringing a new one up.

The command only brings the site up; the verification is yours to do. Once it
reports that the site is running, open <http://localhost> and work through
[`scripts/local-check.md`](scripts/local-check.md), which lists what to look at
and what each item proves. Remove both containers when you are done:

```bash
make local-clean
```

## Deployment

The deployment starts with these two steps. Neither uses a floating image tag.

### 1. Bootstrap the GCP project

```bash
make bootstrap
```

Allow about 3-5 minutes in a fresh project. The target enables the APIs declared
by the bootstrap stack, creates the regional Docker repository, and grants the
build identity permission to push images and write build logs.

Confirm that the repository exists and is a Docker repository:

```bash
gcloud artifacts repositories describe wordpress \
  --project="${PROJECT_ID}" --location="${REGION}" \
  --format='value(name,format)'
```

Expected: a repository path followed by `DOCKER`. Destroying the bootstrap stack
does not disable project APIs.

### 2. Build and publish the application image

```bash
make image
```

Allow about 5-10 minutes for the first managed build. Cloud Build builds the
existing `app/Dockerfile` and pushes the result as
`${REGION}-docker.pkg.dev/${PROJECT_ID}/wordpress/wordpress:v1`. The `v1`
tag is specific and intentionally does not float.

Confirm that the image was published:

```bash
gcloud artifacts docker images list \
  "${REGION}-docker.pkg.dev/${PROJECT_ID}/wordpress" \
  --project="${PROJECT_ID}" --include-tags --filter='tags:v1' \
  --format='table(package,tags,createTime)'
```

Expected: one row whose `TAGS` column contains `v1`.

### 3. Provision the private application stack

```bash
make infra
```

Allow about 10-15 minutes. Cloud SQL is the slowest resource. The target creates
the custom network, NAT gateway, private database, dedicated instance identity,
and a fixed regional instance group containing one `e2-medium` server. The
main stack reads the project and region from the bootstrap stack's local
outputs, so those values remain configured in one place.

Confirm that the VM has an internal address and no external address:

```bash
gcloud compute instances list \
  --project="${PROJECT_ID}" --filter='name~^wp-' \
  --format='table(name,networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)'
```

The final column must be empty. Confirm that Cloud SQL has only a private
address:

```bash
gcloud sql instances describe wp-primary --project="${PROJECT_ID}" \
  --format='table(ipAddresses[].type,ipAddresses[].ipAddress)'
```

Expected: a `PRIVATE` row and no `PRIMARY` public address.

The first boot installs Docker and the Google Cloud Ops Agent, authenticates to
Artifact Registry with a short-lived metadata-server token, writes a
Terraform-rendered `/opt/wordpress/compose.yaml`, and brings it up. That file
mirrors the local one: the Cloud SQL Auth Proxy takes MySQL's place as the
service backing the shared Unix socket, and WordPress is otherwise unchanged.
Check it through IAP:

```bash
VM=$(gcloud compute instances list --project="${PROJECT_ID}" \
  --filter='name~^wp-' --format='value(name)' --limit=1)
ZONE=$(gcloud compute instances list --project="${PROJECT_ID}" \
  --filter="name=${VM}" --format='value(zone.basename())' --limit=1)
gcloud compute ssh "${VM}" --project="${PROJECT_ID}" --zone="${ZONE}" \
  --tunnel-through-iap \
  --command='sudo tail -50 /var/log/wordpress-startup.log; sudo docker ps'
```

Expected: the `db` and `app` containers are running, with `app` healthy. The
startup script is safe to run again: package installation converges, and
Compose reconciles the running containers against the same declared file rather
than recreating them.

### 4. Seed the managed database

```bash
make seed
```

Run this once on the fresh database. `make infra` has already uploaded
`data/wordpress.sql` to the assets bucket and granted the Cloud SQL instance
read access to it, so this step is a single control-plane call: the service
reads the object from Cloud Storage and applies it to the `wordpress`
database. Nothing connects to the private instance over the network, so no
bastion, tunnel, or database client is involved.

Confirm that WordPress now serves the migrated site. The dump still carries the
old server's address, so the request has to present that host:

```bash
VM=$(gcloud compute instances list --project="${PROJECT_ID}" \
  --filter='name~^wp- AND status=RUNNING' --format='value(name)' --limit=1)
ZONE=$(gcloud compute instances list --project="${PROJECT_ID}" \
  --filter="name=${VM}" --format='value(zone.basename())' --limit=1)
gcloud compute ssh "${VM}" --project="${PROJECT_ID}" --zone="${ZONE}" \
  --tunnel-through-iap \
  --command="curl --fail --silent --resolve 104.155.81.48:80:127.0.0.1 \
    http://104.155.81.48/ | grep -F '<title>Photography Guy'"
```

Expected: one matching `<title>` line. The old public address is deliberately
not rewritten in this slice; issue #6 adds the stable load-balancer address and
performs that rewrite.

### 5. Tear down

```bash
make destroy
```

This destroys the main stack, including the VM, NAT gateway, private peering,
and Cloud SQL database. The bootstrap APIs and image repository remain so the
environment can be recreated without repeating the one-time foundation work.

## Current architecture

```text
Operator
   |
   | SSH through Identity-Aware Proxy
   v
+---------------------------------------------------+
| Custom VPC                                        |
|                                                   |
|  one subnet                                       |
|  +---------------------------------------------+  |
|  | regional MIG: 1 VM                         |  |
|  | no external IP                             |  |
|  |                                             |  |
|  | WordPress -- unix socket ----> SQL proxy   |  |
|  +--------------------------+------------------+  |
|              | outbound     | private database    |
|              v              v path                |
|          Cloud NAT     service-networking peering |
+-----------------------------+---------------------+
                              |
                              v
                       Cloud SQL MySQL 8
                       private IP only
```

There is no public website endpoint yet. The port-80 firewall rule is restricted
to Google's published health-check/load-balancer ranges and is ready for issue
#6; with no load balancer frontend, it creates no public route to the VM.

### Where state lives

- Application code and the supplied media are baked into the immutable
  `wordpress:v1` image. A VM can be recreated from that image, but new uploads
  are not durable yet; issue #7 moves them to the assets bucket.
- The assets bucket holds the supplied database dump so Cloud SQL can import it
  without a network path to the instance. It has uniform bucket-level access and
  enforced public access prevention, and the only grant on it is object read for
  the Cloud SQL instance's own identity.
- Relational data lives in Cloud SQL, not on the VM disk. The Cloud SQL Auth
  Proxy exposes the instance as a Unix socket shared with the WordPress
  container, so the supplied `DB_HOST='localhost'` resolves the same way it does
  locally.
- The VM boot disk contains only replaceable runtime files, container layers,
  and logs. Central copies of system logs are sent to Cloud Logging.
- Terraform resource state is local in each stack and excluded from version
  control. The main stack reads only the bootstrap stack's non-secret project,
  region, and repository outputs.

### Networking and security

The VPC is custom mode, so it creates exactly one subnet and no surprise
subnets in other regions. The VM has no external IP. Its outbound package and
container downloads use Cloud NAT, while Private Google Access keeps Google API
traffic on Google's network. Cloud SQL has no public IP and receives its private
address from a separately reserved peering range; it does not occupy the
application subnet.

Both firewall rules use `google_netblock_ip_ranges` rather than hardcoded
CIDRs. Port 22 accepts only Identity-Aware Proxy forwarders, and OS Login ties
the SSH account to the operator's IAM identity. Port 80 accepts only Google's
published health-check/load-balancer ranges. No rule admits arbitrary internet
traffic or the whole VPC.

The VM runs as `wordpress-vm`, not the project's default service account. It
has exactly three project roles:

- `roles/cloudsql.client` lets the proxy authenticate the workload before it
  opens a private database tunnel.
- `roles/artifactregistry.reader` lets Docker pull the published image.
- `roles/logging.logWriter` lets the Ops Agent send logs.

The broad `cloud-platform` OAuth scope does not add permissions; IAM still
limits the identity to those three roles. No service-account key is created.
The database and persistent disks use Google-managed encryption at rest.

Confirm startup logs have reached Cloud Logging:

```bash
gcloud logging read \
  'resource.type="gce_instance" AND log_id("syslog")' \
  --project="${PROJECT_ID}" --limit=10
```

## Known limitations of this slice

**The database credential is hardcoded.** `Foxtrot01` is fixed in the
supplied `wp-config.php`, which may not be edited, and therefore also appears
in Terraform state. Secret Manager would not remove it from the shipped
application. The compensating controls are a database with no public address
and an IAM-authenticated proxy reached only from the private VM. Rotating the
credential would be the first step in a real engagement.

**Terraform state is local.** State files are excluded from version control.
That is acceptable for this demo while the only credential in state is the
already-supplied database password. [The decisions record](docs/decisions.md)
describes the migration to a versioned, IAM-restricted Cloud Storage backend.

**This is not the final availability design.** The current group is fixed at
one server and has no public frontend, durable upload storage, autohealing,
autoscaling, or read replica. Issues #6-#8 add those capabilities in vertical
slices without weakening the private network established here.
