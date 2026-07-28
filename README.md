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

You also need a Google Cloud project with billing enabled and both forms of CLI
authentication used by this project:

```bash
gcloud auth login
gcloud auth application-default login
```

The first command authenticates the `gcloud` CLI. The second supplies
Application Default Credentials to Terraform's Google provider.

## Configure the project

Set the project ID and region in `terraform/project.tfvars`. This is the only
committed location for either value, so retargeting the deployment means
changing each value on its single line there.

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

Allow about 3-5 minutes in a fresh project. The target first enables the APIs
declared by the bootstrap stack. It then queries the GCP APIs to prove that the
chosen region offers `e2-medium`, the shared-core `db-g1-small` database tier,
and an Artifact Registry location. Terraform cannot create the repository or
its IAM bindings unless all three checks pass. It then creates the regional
Docker repository and grants the build identity permission to push images and
write build logs.

The target finishes by describing the repository. Check that it reports a
repository path followed by `DOCKER`. Destroying the bootstrap stack does not
disable project APIs.

### 2. Build and publish the application image

```bash
make image
```

Allow about 5-10 minutes for the first managed build. Cloud Build builds the
existing `app/Dockerfile` and pushes the result as
`${REGION}-docker.pkg.dev/${PROJECT_ID}/wordpress/wordpress:v1`. The `v1`
tag is specific and intentionally does not float. The target finishes by
listing the matching repository entry; check that its `TAGS` column contains
`v1`.

The managed build path was exercised successfully, so `make image` records the
path actually used rather than the local Docker fallback.
