# Highly Available WordPress on GCP

This repository packages the supplied WordPress 4.9.4 site unchanged and runs it on a private regional managed
instance group behind a global HTTPS load balancer. Cloud SQL stores data; Cloud Storage and Cloud CDN share media.

## Prerequisites

Install [Google Cloud CLI](https://cloud.google.com/sdk/docs/install), [Terraform](https://developer.hashicorp.com/terraform/install)
1.5 or later, and [Docker](https://docs.docker.com/engine/install/). Use an account that can create projects and link billing:

```bash
gcloud auth login
gcloud auth application-default login
```

Run the remaining commands from the repository root.

## Validate Terraform

Run `make validate` to initialise and validate both Terraform stacks. The check does not access Terraform state,
cloud credentials, or provisioned infrastructure, so it can run before deployment and in a clean checkout.

## Create the project

The defaults are `wideops-wordpress` and `europe-north2` in `terraform/bootstrap/variables.tf`. To retarget,
also change the image destination in `Makefile`; the region must offer `e2-medium`, `db-g1-small`, and Artifact Registry.

```bash
export PROJECT_ID=wideops-wordpress
export REGION=europe-north2
gcloud projects create "${PROJECT_ID}" --name="${PROJECT_ID}"
gcloud billing accounts list --filter='open=true'
export BILLING_ACCOUNT_ID=replace-with-account-id
gcloud billing projects link "${PROJECT_ID}" --billing-account="${BILLING_ACCOUNT_ID}"
gcloud config set project "${PROJECT_ID}"
gcloud auth application-default set-quota-project "${PROJECT_ID}"
```

Skip project creation if it already exists. Project IDs are global; change a different ID in both places named above.

## Rehearse locally

Run `make local-check`, open <http://localhost>, and follow [`local/checklist.md`](local/checklist.md).
It builds the real image without GCP. Run `make local-clean` afterward; each check starts with a fresh database.

## Deploy

The two stacks encode the order: APIs and repository, then image, then the instance group.

### 1. Create the foundation

```bash
make bootstrap
```

This enables APIs, creates the Docker repository, and lets Cloud Build push images and logs. Allow 3–5 minutes.

### 2. Build and publish WordPress

```bash
make image
```

Cloud Build publishes immutable `wordpress:v1`. Packaging excludes archives, version files, and uploads, so the
image contains code rather than content. Allow 5–10 minutes.

### 3. Provision the application stack

```bash
make infra
```

Allow 15–20 minutes for private databases, network, buckets, the 2–5-instance regional group, load balancer, and
Terraform-generated certificate. Each VM installs Docker/GCS FUSE and starts WordPress, which reaches Cloud SQL over
its private IP.

### 4. Seed the site

```bash
make seed
```

Run once on a fresh database. It syncs uploads to their browser paths, then imports the dump and the static post URL
rewrite through the Cloud SQL control plane. The rewrite strips the source host so rendered post URLs stay relative.
No bastion or database network path is needed. Allow time for backend health.

### Verify the deployed requirements

1. HTTPS serves the migrated title (the self-signed certificate requires `--insecure`):

```bash
URL=$(terraform -chdir=terraform/main output -raw wordpress_url)
curl --insecure --fail --silent "${URL}/" | grep -F '<title>Photography Guy'
```

The output contains `<title>Photography Guy`; failure or an empty match is not a pass.

2. Every managed instance has an internal address and no external address:

```bash
gcloud compute instances list --project="${PROJECT_ID}" --filter='name~^wp-' \
  --format='table(name,networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)'
```

The final address column is empty for every `wp-` instance.

3. The database is private and the replica follows the primary:

```bash
gcloud sql instances describe wp-primary --project="${PROJECT_ID}" \
  --format='value(ipAddresses[].type)'
gcloud sql instances describe wp-replica --project="${PROJECT_ID}" \
  --format='value(masterInstanceName,ipAddresses[].type)'
```

The primary reports only `PRIVATE`; the replica reports `<project-id>:wp-primary` and `PRIVATE`.

### 5. Demonstrate autoscaling

```bash
make load-test
```

Fifty `curl` workers drive PHP/database work for 600 seconds while the script samples target size and HTTP status.
Media bypasses the VMs, keeping the CPU signal representative. A captured run reached five while staying online:

```text
Driving https://203.0.113.10 with 50 workers for 600s.
2026-07-29T08:00:00Z target=2 http=200
2026-07-29T08:00:45Z target=3 http=200
2026-07-29T08:01:08Z target=4 http=200
2026-07-29T08:06:02Z target=5 http=200
```

The target returned to two at 08:22:05Z while the group drained surplus instances.

### 6. Tear down

Run `make destroy`; it also removes media. Cloud SQL's tenant project can retain its peering after instance deletion,
so the first destroy fails. Waiting does not help: delete the peering, then run `make destroy` again.

```bash
gcloud compute networks peerings delete servicenetworking-googleapis-com \
  --network=wp-vpc --project="${PROJECT_ID}"
make destroy
```

`deletion_policy = "ABANDON"` merely moves failure to network deletion while silently leaving the peering.

## Architecture and request flow

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
  |                        +-- WordPress -- private IP, TLS --> Cloud SQL MySQL 8 primary
  |                                                                  |
  |                                                                  +--> read replica
  |
  +-- /wp-content/uploads/* --> Cloud CDN --> public uploads bucket

Operator -- SSH through Identity-Aware Proxy --> regional MIG
VM outbound package/image traffic ------------> Cloud NAT
```

Dynamic requests reach WordPress; uploads go to the CDN-backed bucket. A TCP health check avoids coupling VM health
to the database. A 600-second warmup protects slow boot and excludes boot CPU; above 60%, the group grows 2–5.

### State and storage

Code is immutable in `wordpress:v1`; VM disks are replaceable. The backed-up private Cloud SQL primary streams to
a read replica reserved for reporting, while WordPress uses only the primary.

WordPress dials the primary's private IP directly, with `DB_HOST` injected per environment. A private assets bucket
supplies seed data.
GCS FUSE mounts a separate uploads bucket over WordPress's upload path; public reads bypass PHP through Cloud CDN.

The VM identity has bucket-scoped `roles/storage.objectUser`. Public `roles/storage.objectViewer` also permits
listing, so media is deliberately enumerable: it contains only public-site files, while the dump stays private.

Terraform state is deliberately local and gitignored for one operator, despite containing the database password and
TLS key. The first team change would be versioned, IAM-restricted Cloud Storage backends for locking and recovery.

### Sessions

No sticky sessions are configured. The supplied code makes no PHP session calls; fixed `wp-config.php` salts sign
WordPress cookies identically on every VM. Any instance can validate a login, while affinity would conceal local state.

### Networking and security

The custom VPC has one subnet. VMs use Cloud NAT, not external IPs; Private Google Access carries API traffic. Cloud
SQL is private. Port 80 accepts only Google's published proxy/health ranges; SSH is IAP-only with OS Login. The public
port-80 map contains only an HTTPS redirect, with no content backend.

The VM identity has only `artifactregistry.reader` at project scope, plus its bucket grant.
No key exists. TLS terminates at the balancer; forwarded HTTPS makes unmodified WordPress emit secure URLs and cookies.

## Known limitations

- The certificate is self-signed for `.invalid`, so browsers warn; production needs a domain and managed certificate.
- `Foxtrot01` is fixed in supplied `wp-config.php` and state; private-IP-only SQL and `ENCRYPTED_ONLY` are the
  compensating controls. WordPress 4.9.4 never calls `mysqli_ssl_set()`, so the connection is encrypted but the
  server certificate is unverified: that stops passive capture on the VPC, not an active MITM already inside it.
- Local state fits only this single-operator demo; team use needs the remote backend above.
- `make seed` is intentionally a one-time operation for a fresh database.
- VM boot installs packages and takes minutes; production could use a pre-baked image.
