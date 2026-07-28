# Highly Available WordPress on GCP

This project packages the supplied WordPress 4.9.4 site without modifying it
and deploys it to a highly available, autoscaling Google Cloud environment.
Terraform declares the infrastructure, Docker provides an immutable application
image, Cloud SQL holds relational data, and Cloud Storage holds uploaded media.

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
