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
