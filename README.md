# Highly Available WordPress on GCP

This project runs WordPress 4.9.4 on an autoscaling regional managed instance group (MIG). A global HTTPS load
balancer serves the site, Cloud SQL stores its data, and Cloud Storage with Cloud CDN serves uploaded media.

## Requirements

- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.5+
- [Docker](https://docs.docker.com/engine/install/)
- A Google Cloud account that can create projects and link billing

Authenticate, then run all commands from the repository root:

```bash
gcloud auth login
gcloud auth application-default login
```

## Deploy

The default project ID is `wideops-wordpress` and the default region is `europe-north2`. To use other values, update
`terraform/bootstrap/variables.tf` and the image destination in `Makefile`. The region must support `e2-medium`,
`db-g1-small`, and Artifact Registry.

### 1. Create the project

```bash
export PROJECT_ID=wideops-wordpress
gcloud projects create "${PROJECT_ID}" --name="${PROJECT_ID}"
gcloud billing accounts list --filter='open=true'
gcloud billing projects link "${PROJECT_ID}" --billing-account=replace-with-account-id
gcloud config set project "${PROJECT_ID}"
gcloud auth application-default set-quota-project "${PROJECT_ID}"
```

### 2. Validate and deploy

```bash
make validate    # validate both Terraform stacks without credentials or state
make bootstrap   # enable APIs and create the image repository
make image       # build and publish wordpress:v1 with Cloud Build
make infra       # create the network, database, MIG, load balancer, and certificate
make seed        # import the database and media once
```

The stacks must run in this order because the image repository is needed before the VMs can start. VM boot can take
several minutes while Docker and GCS FUSE install.

To test the same image locally before deploying:

```bash
make local-check
# Follow local/checklist.md, then:
make local-clean
```

## Verify

```bash
# The site serves the migrated title. --insecure accepts the self-signed certificate.
URL=$(terraform -chdir=terraform/main output -raw wordpress_url)
curl --insecure --fail --silent "${URL}/" | grep -F '<title>Photography Guy'

# MIG instances have internal addresses but no external addresses (the last column is empty).
gcloud compute instances list --project="${PROJECT_ID}" --filter='name~^wp-' \
  --format='table(name,networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)'

# The primary is private; the replica identifies the primary and is also private.
gcloud sql instances describe wp-primary --project="${PROJECT_ID}" --format='value(ipAddresses[].type)'
gcloud sql instances describe wp-replica --project="${PROJECT_ID}" \
  --format='value(masterInstanceName,ipAddresses[].type)'
```

Run `make load-test` to send concurrent traffic for ten minutes and watch the MIG scale from 2 to 5 instances.

## Architecture

```text
                           +--> WordPress MIG (2-5 private VMs) --> Cloud SQL primary --> read replica
Client --> global HTTPS LB |
                           +--> /wp-content/uploads/* --> Cloud CDN --> uploads bucket

VM outbound traffic --> Cloud NAT
Operator SSH traffic --> Identity-Aware Proxy
```

- **State and storage:** The immutable `wordpress:v1` image makes VM disks replaceable. WordPress writes to the private
  Cloud SQL primary; the replica is reserved for reporting. GCS FUSE shares uploads between VMs, and Cloud CDN serves
  them without PHP. Seed data remains in a separate private bucket.
- **Sessions:** WordPress signs browser cookies with keys shared by every VM and stores token metadata in Cloud SQL.
  Users therefore remain logged in without sticky sessions or local session storage.
- **Networking and security:** VMs and Cloud SQL have no public IPs. VMs use Cloud NAT for outbound traffic, SSH is
  available only through IAP with OS Login, and firewall rules allow HTTP only from Google's load balancer ranges.
  Workload identities use bucket-scoped IAM roles and read-only image access; no service-account keys are stored.
- **Scaling and cost:** A TCP health check does not depend on database health. After a 600-second warmup, average CPU
  above 60% scales the regional MIG from 2 to 5 `e2-medium` VMs. Cloud SQL uses shared-core instances.

`wp-config.php` reads the database host and site URL from environment variables and requires encrypted Cloud SQL
connections. `make seed` imports the supplied dump and uploads, then rewrites old post URLs without modifying
PHP-serialized plugin options.

## Limitations

- The self-signed `.invalid` certificate causes browser warnings. Production needs a domain and managed certificate.
- The supplied database password and WordPress keys are fixed. They should be rotated and stored in Secret Manager.
- Terraform state is local and contains secrets. Teams should use an IAM-restricted remote backend.
- `make seed` is only for a fresh database and must run once.
- VM boot installs packages dynamically; a production system should use a pre-baked image.

## Destroy

`make destroy` removes the infrastructure and media. Cloud SQL can leave its service-networking peering behind, which
causes the first destroy to fail. If that happens, delete the peering and run the command again:

```bash
gcloud compute networks peerings delete servicenetworking-googleapis-com \
  --network=wp-vpc --project="${PROJECT_ID}"
make destroy
```
