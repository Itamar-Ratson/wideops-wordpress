# Highly Available WordPress on GCP

This project packages the supplied WordPress 4.9.4 site without modifying it
and runs it in a highly available, autoscaling Google Cloud environment. A
regional managed instance group keeps two to five privately networked servers
behind a global HTTPS load balancer, Cloud SQL holds relational data and a read
replica, and Cloud Storage serves shared media through Cloud CDN.

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

Allow about 15-20 minutes. Cloud SQL and its read replica are the slowest
resources. The target creates the custom network, NAT gateway, private primary
and replica databases, dedicated instance identity, private seed and public
uploads buckets, regional instance group containing at least two `e2-medium`
servers, and global load balancer with a CDN-enabled bucket backend. The main
stack reads the project and region from the bootstrap stack's local outputs, so
those values remain configured in one place.

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

Confirm the replica follows that private primary, and that the primary has the
stream source a replica needs:

```bash
gcloud sql instances describe wp-replica --project="${PROJECT_ID}" \
  --format='value(masterInstanceName,ipAddresses[0].type)'
gcloud sql instances describe wp-primary --project="${PROJECT_ID}" \
  --format='value(settings.backupConfiguration.enabled,settings.backupConfiguration.binaryLogEnabled)'
```

Expected: the first command names `wp-primary` and reports `PRIVATE`; the
second prints `True True`. WordPress's rendered proxy command still contains
only the primary's connection name. The replica is deliberately reserved for
reporting or analytical reads rather than application-level read/write
splitting.

Confirm the autoscaler policy, autohealing delay, and regional distribution:

```bash
gcloud compute instance-groups managed describe wp-mig \
  --project="${PROJECT_ID}" --region="${REGION}" \
  --format='yaml(autoscaler.autoscalingPolicy,autoHealingPolicies,distributionPolicy.zones)'
```

Expected: a floor of `2`, ceiling of `5`, CPU target of `0.6`, and a
600-second initialization period. The group lists multiple zones and uses
`wp-tcp-health` for healing with the same 600-second initial delay.

The first boot installs Docker, GCS FUSE, and the Google Cloud Ops Agent,
authenticates to Artifact Registry with a short-lived metadata-server token,
mounts only the uploads prefix, writes a Terraform-rendered
`/opt/wordpress/compose.yaml`, and brings it up. That file mirrors the local
one: the Cloud SQL Auth Proxy takes MySQL's place as the service backing the
shared Unix socket, while the host mount takes the place of the image's uploads
directory. WordPress itself is unchanged. Check it through IAP:

```bash
VM=$(gcloud compute instances list --project="${PROJECT_ID}" \
  --filter='name~^wp-' --format='value(name)' --limit=1)
ZONE=$(gcloud compute instances list --project="${PROJECT_ID}" \
  --filter="name=${VM}" --format='value(zone.basename())' --limit=1)
gcloud compute ssh "${VM}" --project="${PROJECT_ID}" --zone="${ZONE}" \
  --tunnel-through-iap \
  --command='findmnt /mnt/wordpress-uploads; sudo tail -50 /var/log/wordpress-startup.log; sudo docker ps'
```

Expected: the uploads path reports `fuse.gcsfuse`, and the `db` and `app`
containers are running, with `app` healthy. The startup script is safe to run
again: package installation converges, `mountpoint` skips an existing mount,
and Compose reconciles the running containers against the same declared file.

### 5. Seed and rewrite the managed database

```bash
make seed
```

Run this once on the fresh database. It first syncs the supplied
`app/wp-content/uploads` tree to the uploads bucket under that same
`wp-content/uploads` path, so stored object names match browser paths without
rewriting. The first control-plane import then loads the supplied dump. The
second stages `data/rewrite-urls.sql` with the destination set to the load
balancer's stable HTTPS address and imports it through the same Cloud SQL
control-plane path. Nothing connects to the private instance over the network,
and the supplied dump and WordPress tree remain unmodified.

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

Confirm that an existing media request goes to Cloud Storage rather than
Apache. Storage-provider headers such as `x-goog-generation` and
`x-goog-storage-class` prove which backend answered:

```bash
IP=$(terraform -chdir=terraform/main output -raw load_balancer_ip)
curl --insecure --silent --head \
  "https://${IP}/wp-content/uploads/2018/02/IMG_6056.jpg" \
  | grep --ignore-case '^x-goog-'
```

For an end-to-end write check, log in at `https://${IP}/wp-admin/`, upload a
uniquely named image, and place it on a page. Its public URL must load and the
object must appear beneath the bucket prefix:

```bash
UPLOADS_URI=$(terraform -chdir=terraform/main output -raw uploads_uri)
gcloud storage ls "${UPLOADS_URI}/**" --project="${PROJECT_ID}"
```

Finally, delete one VM directly and wait for the managed instance group to
restore its floor. The page and new image must stay available while the group
returns to two, which proves both automatic replacement and that the object
survived independently of the server that wrote it:

```bash
VM=$(gcloud compute instances list --project="${PROJECT_ID}" \
  --filter='name~^wp-' --format='value(name)' --limit=1)
ZONE=$(gcloud compute instances list --project="${PROJECT_ID}" \
  --filter="name=${VM}" --format='value(zone.basename())' --limit=1)
gcloud compute instances delete "${VM}" --project="${PROJECT_ID}" \
  --zone="${ZONE}" --quiet
gcloud compute instance-groups managed wait-until wp-mig \
  --project="${PROJECT_ID}" --region="${REGION}" --stable
gcloud compute instance-groups managed list-instances wp-mig \
  --project="${PROJECT_ID}" --region="${REGION}" \
  --format='table(instance.basename(),instanceStatus,instanceHealth[0].detailedHealthState)'
```

Expected: the table returns to two `RUNNING` instances without intervention.
The replacement's startup script rebuilds the whole runtime from the current
template; no useful state was present on the deleted boot disk.

### 6. Demonstrate autoscaling and availability

Run the load demonstration after seeding, when the homepage executes real PHP
and database work. Requests for its images bypass the VM through the bucket
backend, so the CPU signal measures application work rather than JPEG delivery:

```bash
make load-test
```

The defaults run 50 concurrent workers for 600 seconds, sample every 15
seconds, and then wait up to 1,800 seconds for scale-in. Expect the whole run
to take around 30 minutes: the autoscaler returns the target to two within a
couple of minutes of load stopping, but the managed instance group drains the
surplus instances over several more, and the test waits for both. All four
values are overridable, in seconds apart from the worker count:

```bash
make load-test \
  LOAD_DURATION=900 \
  LOAD_CONCURRENCY=80 \
  LOAD_SAMPLE_INTERVAL=10 \
  LOAD_SETTLE_TIMEOUT=1800
```

Each line prints the autoscaler's target size, the number of existing
instances, and an independent HTTP status. A successful run grows from the
two-instance floor toward the five-instance ceiling, keeps returning HTTP 200,
and eventually returns to two after load stops. Keep the output as the
deployment evidence. For example:

```text
Driving https://203.0.113.10 with 50 workers for 600s.
The test will then wait up to 1800s for the group to return to 2.
2026-07-29T08:00:00Z phase=load     target=2 actual=2 http=200
2026-07-29T08:00:45Z phase=load     target=3 actual=3 http=200
2026-07-29T08:01:08Z phase=load     target=4 actual=4 http=200
2026-07-29T08:06:02Z phase=load     target=5 actual=5 http=200
Load stopped; watching scale-in.
2026-07-29T08:10:11Z phase=scale-in target=5 actual=5 http=200
2026-07-29T08:22:05Z phase=scale-in target=2 actual=5 http=200
2026-07-29T08:29:01Z phase=scale-in target=2 actual=2 http=200
The group scaled to 5/5 (target/actual), returned to 2, and every availability sample succeeded.
```

The `target=2 actual=5` samples are the expected middle of scale-in, not a
stall: the autoscaler lowers the target quickly, and the group then deletes the
surplus instances one at a time.

If scale-out is not observed, even one load worker or availability sample
fails, or the group does not return to two before the settle timeout, the target
exits unsuccessfully.

### 7. Tear down

```bash
make destroy
```

This destroys the main stack, including the load balancer, VMs, NAT gateway,
private peering, Cloud SQL primary and replica, and both buckets. The uploads
bucket uses `force_destroy`, so its media is deleted with the stack. The
registered certificate and the ignored local pair both remain, alongside the
bootstrap APIs and image repository, so a later `make infra` rebuilds the stack
without repeating any of the one-time foundation work.

Expect the private peering to need a second pass. Cloud SQL's tenant project
keeps the `servicenetworking-googleapis-com` peering attached after the
instances themselves are gone, and Terraform cannot force it, so the run stops
with `Failed to delete connection; Producer services (e.g. CloudSQL, Cloud
Memstore, etc.) are still using this connection` and leaves the network, its
reserved range, and the connection behind. Waiting does not clear it. Delete
the peering directly, then run the target again:

```bash
gcloud compute networks peerings delete servicenetworking-googleapis-com \
  --network=wp-vpc --project="${PROJECT_ID}"
make destroy
```

Setting `deletion_policy = "ABANDON"` on the connection is not a fix. It skips
the failing call, but Compute Engine then refuses to delete a network that
still carries a peering, so the same run fails one resource later and leaves
the peering behind silently.

To remove the certificate as well, or to rotate it before its 365-day expiry,
run this after `make destroy`:

```bash
scripts/delete-certificate.sh "${PROJECT_ID}"
```

It has to run with the stack down: Compute Engine refuses to delete a
certificate while the HTTPS proxy still references it. Removing the local
`.certificates/` pair too makes the next `make certificate` generate a fresh
one instead of re-registering the old pair.

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
  +-- all other paths --> WordPress backend service
  |                        | TCP health check on :80
  |                        v
  |                    regional MIG: 2-5 VMs across zones, no public IP
  |                        |
  |                        +-- WordPress -- Unix socket --> SQL proxy
  |                                                       |
  |                                                       v private path
  |                                                  Cloud SQL MySQL 8 primary
  |                                                       |
  |                                                       +--> read replica
  |
  +-- /wp-content/uploads/* --> Cloud CDN --> public uploads bucket

Operator -- SSH through Identity-Aware Proxy --> regional MIG
VM outbound package/image traffic ------------> Cloud NAT
```

The application URL map chooses between two backends without changing either
public frontend. Dynamic requests reach WordPress; upload reads go directly to
the CDN-backed bucket and never consume VM, Apache, or PHP capacity.

### Where state lives

- Application code is baked into the immutable `wordpress:v1` image. Its
  supplied uploads are seed input only; the runtime uploads directory is a GCS
  FUSE mount backed by the uploads bucket.
- The private assets bucket holds the supplied database dump so Cloud SQL can
  import it without a network path to the instance. It has uniform bucket-level
  access, enforced public access prevention, and object read for only the Cloud
  SQL instance's own identity.
- The separate uploads bucket holds supplied and newly uploaded media at
  `wp-content/uploads/...`. It is durable across VM replacement and shared by
  every instance.
- Relational data lives in the Cloud SQL primary, not on a VM disk, and streams
  through binary logs to a read replica. Automated primary backups provide a
  recovery path. The Cloud SQL Auth Proxy exposes only the primary as a Unix
  socket shared with the WordPress container, so the supplied
  `DB_HOST='localhost'` resolves the same way it does locally.
- The VM boot disk contains only replaceable runtime files, container layers,
  and logs. Central copies of system logs are sent to Cloud Logging.
- Terraform resource state is local in each stack and excluded from version
  control. The main stack reads only the bootstrap stack's non-secret project,
  region, and repository outputs.

### Media storage and delivery

GCS FUSE is intentionally only on the write path. During boot, root mounts the
uploads bucket's `wp-content/uploads` prefix at
`/mnt/wordpress-uploads`; Compose bind-mounts that directory over WordPress's
normal `/var/www/html/wp-content/uploads` path. The mount presents objects as
uid and gid 33 (`www-data`) and uses `allow_other`, because FUSE otherwise
allows only the root user that created the mount to enter it. WordPress can
therefore create originals and thumbnails without application changes.

The load balancer sends every public `/wp-content/uploads/*` request to a
CDN-enabled backend bucket. It does not read the host mount, start Apache, or
execute PHP. Besides avoiding needless compute cost, that keeps the CPU signal
used by the later autoscaler representative of application work.

Backend buckets fetch anonymously, so `allUsers` receives
`roles/storage.objectViewer` on the uploads bucket. That built-in role also
permits object listing: the bucket is deliberately public and enumerable. This
is acceptable here because it contains only media already published by the
site; the private SQL dump remains in a different bucket. Signed URLs were
rejected because they would require WordPress to generate them. Keeping the
bucket private was also rejected because it would force reads back through GCS
FUSE and the servers, defeating the CDN design. The preferred future tightening
is a custom bucket role containing object-read but not object-list permission;
the built-in read-only alternative was not selected because its name is
`legacy`-prefixed.

The instance identity receives `roles/storage.objectUser` on this bucket
itself, not on the project. It can create, update, and delete WordPress media but
cannot use that grant to reach any other project storage.

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

That same check drives autohealing. A new VM gets 600 seconds to install its
packages, pull the two containers, mount the uploads bucket, and pass Compose
health before the manager may judge it unhealthy. The autoscaler also ignores
a new VM's boot CPU for 600 seconds, preventing scale-out from mistaking package
installation for visitor demand. After that window, average CPU above the 60%
target grows the regional group as far as five; falling demand returns it to a
floor of two. A regional group distributes those instances across zones, so a
single VM or zone loss leaves capacity for the load balancer while replacement
occurs.

The VM runs as `wordpress-vm`, not the project's default service account. It
has exactly three project roles:

- `roles/cloudsql.client` lets the proxy authenticate the workload before it
  opens a private database tunnel.
- `roles/artifactregistry.reader` lets Docker pull the published image.
- `roles/logging.logWriter` lets the Ops Agent send logs.

The broad `cloud-platform` OAuth scope does not add permissions; IAM still
limits the identity to those three roles, plus the uploads bucket-scoped object
grant described above. No service-account key is created. The database,
persistent disks, and buckets use Google-managed encryption at rest.

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

## Known limitations

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

## Deferred improvements

- **Remote Terraform state:** move both stacks to versioned, IAM-restricted GCS
  backends before multiple operators collaborate; local state keeps this demo's
  bootstrap linear and contains no certificate private key.
- **Terraform-managed certificate and image build:** move both into the graph
  after state is remote. Doing it now would place the TLS private key in a local
  state file and add a second provider for an image whose source is fixed.
- **Keyless CI/CD:** use GitHub Actions with Workload Identity Federation for
  pull-request plans and merge-time applies; it is deferred because this
  assignment asks for an explicit, explainable manual deployment sequence.
- **Pre-baked machine images:** install Docker, GCS FUSE, and the Ops Agent with
  Packer to shorten scale-out by one to two minutes; startup remains scripted
  here so every dependency is visible in one place.
- **Object caching:** add Redis only when application demand justifies its cost;
  it needs a WordPress drop-in, adds roughly $36/month, and would suppress the
  CPU signal used by this autoscaling demonstration.
- **Rotate the database credential:** replace `Foxtrot01` and store the new
  credential in Secret Manager in a real engagement; it is deferred because
  the supplied, immutable `wp-config.php` hardcodes the current value.
