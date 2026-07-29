# Highly Available WordPress on GCP

This project packages the supplied WordPress 4.9.4 site without modifying it
and builds toward a highly available, autoscaling Google Cloud environment.
The current deployment slice serves one privately networked server through a
global HTTPS load balancer backed by Cloud SQL. Later slices add durable media,
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

Follow these steps in order. The application image does not use a floating tag.

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

### 3. Create and register the self-signed certificate

```bash
make certificate
```

The script generates the certificate and private key under the ignored
`.certificates/` directory, then registers the public certificate with Compute
Engine. Terraform only reads the registered certificate as a data source, so
the private key never enters Terraform configuration or state. The repository's
deny-all ignore policy and explicit `*.key`/certificate rules prevent the local
key from being added to version control.

The target is safe to repeat. It checks the project for `wp-self-signed` first
and leaves both the registered resource and local files unchanged when it
exists. Confirm the certificate is registered:

```bash
gcloud compute ssl-certificates describe wp-self-signed \
  --project="${PROJECT_ID}" --global --format='value(name,type)'
```

Expected: `wp-self-signed SELF_MANAGED`.

### 4. Provision the public application stack

```bash
make infra
```

Allow about 10-15 minutes. Cloud SQL is the slowest resource. The target creates
the custom network, NAT gateway, private database, dedicated instance identity,
fixed regional instance group containing one `e2-medium` server, and global
load balancer. The main stack reads the project and region from the bootstrap
stack's local outputs, so those values remain configured in one place.

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

### 5. Seed and rewrite the managed database

```bash
make seed
```

Run this once on the fresh database. The first control-plane import loads the
supplied dump. The second stages `data/rewrite-urls.sql` with the destination
set to the load balancer's stable HTTPS address and imports it through the same
Cloud SQL control-plane path. Nothing connects to the private instance over the
network, and the supplied dump and WordPress tree remain unmodified.

Confirm HTTPS, the permanent HTTP redirect, the migrated page, the rewrite, and
an existing PATH_INFO permalink:

```bash
IP=$(terraform -chdir=terraform/main output -raw load_balancer_ip)
curl --insecure --fail --silent "https://${IP}/" | grep -F '<title>Photography Guy'
curl --silent --output /dev/null --write-out '%{http_code} %{redirect_url}\n' \
  "http://${IP}/"
! curl --insecure --fail --silent "https://${IP}/" | grep -F '104.155.81.48'
curl --insecure --fail --silent \
  "https://${IP}/index.php/2018/02/07/romanian-autumn/" \
  | grep -F 'Romanian Autumn'
```

Expected: the title is present, HTTP reports a `301` destination beginning
with `https://`, the old address search finds nothing, and the existing post
title is present. Allow several minutes after apply for the backend to report
healthy:

```bash
gcloud compute backend-services get-health wp-backend \
  --project="${PROJECT_ID}" --global
```

### 6. Tear down

```bash
make destroy
```

This destroys the main stack, including the load balancer, VM, NAT gateway,
private peering, and Cloud SQL database, then deletes the externally managed
certificate. The ignored local certificate pair remains so `make certificate`
can register the same pair on a later deployment. The bootstrap APIs and image
repository remain so the environment can be recreated without repeating the
one-time foundation work.

## Current architecture and request flow

```text
Public client
  | HTTP :80
  +----------------> redirect URL map -- 301 --> HTTPS
  |
  | HTTPS :443 (self-signed TLS)
  v
global external Application Load Balancer
  |
  v
application URL map
  |
  +-- all paths today --> WordPress backend service
  |                        | TCP health check on :80
  |                        v
  |                    regional MIG: 1 VM, no public IP
  |                        |
  |                        +-- WordPress -- Unix socket --> SQL proxy
  |                                                       |
  |                                                       v private path
  |                                                  Cloud SQL MySQL 8
  |
  +.. /wp-content/uploads/* ..> CDN + bucket backend
                                  planned in issue #7; not active yet

Operator -- SSH through Identity-Aware Proxy --> regional MIG
VM outbound package/image traffic ------------> Cloud NAT
```

The diagram shows both final request backends, with the not-yet-active media
route dotted and labelled. In this slice the application URL map sends every
HTTPS path to the WordPress backend. Issue #7 adds the path rule and bucket
backend without changing either public frontend.

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
the SSH account to the operator's IAM identity. Backend port 80 accepts only
Google's published health-check/load-balancer ranges. Public HTTP and HTTPS
terminate at the global load balancer; no rule admits arbitrary internet
traffic to a VM or to the whole VPC.

Port 80 has a redirect-only URL map with no backend service, so it cannot serve
content. Port 443 terminates TLS and forwards HTTP to Apache. The image maps the
load balancer's `X-Forwarded-Proto: https` header to Apache's `HTTPS=on`
environment, allowing unmodified WordPress to issue secure URLs and cookies
without entering a redirect loop. The certificate is self-signed and named for
`wideops-wordpress.invalid`, so the browser warning when accessing the stable
IP is expected. A production deployment would use a real domain and a
Google-managed, publicly trusted certificate.

The backend health check is TCP on port 80. It verifies that Apache accepts a
connection without executing PHP or querying Cloud SQL, so a shared database
incident cannot mark every server unhealthy at once.

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

### Session management

Session handling was verified against the supplied application rather than
assumed: a PHP-source search of WordPress core, all supplied plugins, and the
supplied themes found no calls to `session_start()`, `session_id()`, or
`$_SESSION`. WordPress 4.9.4 authenticates administrators with cookies signed
by the salts in the supplied `wp-config.php`. That unchanged file is identical
on every VM, so any server can validate a cookie issued through any other.

Accordingly, the load-balancer backend configures no session affinity. Affinity
would hide stateful-server behavior rather than solve it and would add no value
here. Admin login still uses secure cookies because Apache sees the forwarded
HTTPS signal described above.

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
one server and still has no durable upload storage, autohealing, autoscaling, or
read replica. Issues #7-#8 add those capabilities in vertical slices without
weakening the private network or public HTTPS entry point established here.
