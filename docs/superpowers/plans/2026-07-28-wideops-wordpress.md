# WideOps WordPress on GCP — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deploy the supplied WordPress 4.9.4 site into a highly-available, autoscaling GCP environment where every instance is disposable, using Terraform plus a small number of shell scripts.

**Architecture:** WordPress runs unmodified in a container on a regional managed instance group behind a global external HTTPS load balancer. All three kinds of state are moved off the instances: code into the container image, relational data into Cloud SQL (reached through the Cloud SQL Auth Proxy so the frozen `DB_HOST='localhost'` stays literally true), and uploaded media into a GCS bucket (written through gcsfuse, read directly by a CDN-backed backend bucket). Sessions need no treatment at all — WordPress authenticates with cookies signed by salts baked into the supplied `wp-config.php`, identical on every instance.

**Tech Stack:** Terraform (google provider), Docker (`php:7.4-apache`), Cloud SQL for MySQL 8.0, Cloud Storage + gcsfuse 2.5.2, Cloud SQL Auth Proxy 2.14.1, Artifact Registry, Cloud Build, Ubuntu 24.04 LTS, `openssl`, `hey`.

## Global Constraints

These apply to **every** task. They come from the user and from `assignment.txt`.

- **Keep it simple.** Verbatim: *"I want to keep it simple as I'll need to explain every line myself."* Every line must be defensible out loud. When two designs work, take the one that is shorter to explain.
- **Do not change any file supplied with the assignment.** Verbatim: *"don't change any of the files we got from assignment."* That means `html/**` and `wordpress.sql` are byte-for-byte untouched. They may be **moved**, never edited.
- **Infrastructure only.** Verbatim: *"I don't want to touch php, wordpress and stuff like that, just the infrastructure."*
- **No PHP files are authored.** Verbatim: *"no php file!!!!!"* No drop-ins, no `wp-config` overrides, no mu-plugins.
- **No `legacy*` IAM roles.** Verbatim: *"legacyObjectReader has 'legacy' in the name, we should avoid in almost all costs such things."*
- **No GCP Marketplace / Bitnami images** (`assignment.txt`).
- **Machine type is `e2-medium`; Cloud SQL is a shared-core tier** (`assignment.txt`).
- **Autoscaling 2 → 5 instances on CPU** (`assignment.txt`).
- **Cloud SQL primary + read replica; WordPress connects to the primary** (`assignment.txt`).
- **Backends are never directly reachable from the internet** — no external IPs on instances, no public IP on Cloud SQL.
- **Region is `europe-north2`.** Project ID is supplied via `terraform/project.tfvars`.
- **Budget:** a personal Google account with $300 of free credit. Prefer the cheap option; tear down with `make destroy` when idle.
- Design rationale that must survive into the README already lives in `docs/decisions.md`. **Reference it, do not duplicate it.**

## File Structure

```
wideops-wordpress/
├── README.md                     # deliverable: deploy steps + architecture write-up
├── Makefile                      # thin wrappers over the commands the README documents
├── .gitignore                    # deny-all whitelist (already in this style)
├── assignment.txt                # supplied brief
├── app/                          # docker build context
│   ├── Dockerfile                # php:7.4-apache + gd + mysqli + the site
│   ├── wordpress.conf            # one line: trust the LB's X-Forwarded-Proto
│   └── html/                     # SUPPLIED, UNMODIFIED (moved from repo root)
├── data/
│   └── wordpress.sql             # SUPPLIED, UNMODIFIED (moved from repo root)
├── docs/
│   ├── decisions.md              # existing rationale record
│   └── superpowers/plans/        # this plan
├── scripts/
│   ├── cert.sh                   # self-signed cert -> global SSL certificate
│   ├── seed.sh                   # import dump, rewrite URLs, push uploads
│   └── load-test.sh              # drive `hey` to trip the autoscaler
└── terraform/
    ├── project.tfvars            # project_id + region (committed, not secret)
    ├── bootstrap/                # APIs, Artifact Registry, Cloud Build IAM
    │   ├── terraform.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   ├── main.tf
    │   └── outputs.tf
    └── main/                     # everything else
        ├── terraform.tf
        ├── providers.tf
        ├── variables.tf
        ├── locals.tf
        ├── network.tf            # VPC, subnet, NAT, firewall, PSA peering
        ├── iam.tf                # instance service account + project roles
        ├── storage.tf            # media bucket + its bindings
        ├── sql.tf                # primary, replica, database, user
        ├── compute.tf            # template, MIG, autoscaler, health check
        ├── lb.tf                 # backend service, backend bucket, URL map, proxies
        ├── outputs.tf
        └── startup.sh.tftpl      # instance bootstrap
```

**Why `html/` moves under `app/`.** `gcloud builds submit app/` uploads `app/` as the build context and expects the `Dockerfile` at its root. Keeping `html/` inside that directory lets the Dockerfile say `COPY html/` with no path gymnastics, and keeps the entire container input in one place.

**Why one stack plus a bootstrap stack.** `terraform/bootstrap/` enables the APIs and creates the Artifact Registry repository that `terraform/main/` and the image build depend on. Enabling an API is not something the stack that consumes it can do reliably in one pass, so it gets its own tiny stack that runs once.

---

## Deployment order (what the tasks build toward)

```
make bootstrap   # enable APIs, create Artifact Registry repo
make image       # build + push the WordPress image
make cert        # self-signed cert -> global SSL certificate resource
make infra       # terraform apply: network, SQL, bucket, MIG, LB
make seed        # import wordpress.sql, rewrite URLs, push uploads to the bucket
make load-test   # drive traffic, watch the MIG grow 2 -> 5
make destroy     # tear it all down
```

Linear. No step ever sends you back to an earlier one.

---

### Task 1: Repository layout and supplied files

Move the supplied assets into their final homes without editing a byte, and open up `.gitignore` so the new tree can actually be committed (the existing file denies everything by default).

**Files:**
- Modify: `.gitignore`
- Move: `html/` → `app/html/`
- Move: `wordpress.sql` → `data/wordpress.sql`
- Create: `app/`, `data/`, `scripts/`, `terraform/bootstrap/`, `terraform/main/`

**Interfaces:**
- Consumes: nothing.
- Produces: `app/html/` (container build input), `data/wordpress.sql` (seed input). Later tasks reference these exact paths.

- [ ] **Step 1: Record checksums of the supplied files before touching them**

```bash
cd /home/itamar/github/wideops-wordpress
find html -type f -exec sha256sum {} + | sort -k2 > /tmp/supplied-before.txt
sha256sum wordpress.sql >> /tmp/supplied-before.txt
wc -l /tmp/supplied-before.txt
```

- [ ] **Step 2: Create the directory skeleton and move the supplied files**

```bash
mkdir -p app data scripts terraform/bootstrap terraform/main
git mv html app/html
git mv wordpress.sql data/wordpress.sql
```

`html/` and `wordpress.sql` are not currently tracked (the deny-all `.gitignore` hides them), so if `git mv` refuses, fall back to plain `mv`:

```bash
mv html app/html
mv wordpress.sql data/wordpress.sql
```

- [ ] **Step 3: Verify the supplied files are byte-for-byte identical after the move**

```bash
{ find app/html -type f -exec sha256sum {} + | sed 's| app/html/| html/|'
  sha256sum data/wordpress.sql | sed 's|data/wordpress.sql|wordpress.sql|'
} | sort -k2 > /tmp/supplied-after.txt
diff /tmp/supplied-before.txt /tmp/supplied-after.txt && echo "IDENTICAL"
```

Expected: `IDENTICAL`. If `diff` reports anything, stop — a supplied file was modified, which violates a global constraint.

- [ ] **Step 4: Replace `.gitignore`**

The current file is a deny-all whitelist (`*` then `!*/`). Keep that style — it is what stops certificates, Terraform state and the 23 MB `site.tar.gz` from ever being committed by accident — and whitelist the tree this plan builds.

```gitignore
# Deny everything by default, then whitelist what belongs in the repo.
# Anything not listed below (certs, tfstate, site.tar.gz, scratch notes)
# can never be committed by accident.
*

# Do not ignore directories, or git will not descend into them.
!*/

# Whitelist
!.gitignore
!README.md
!Makefile
!assignment.txt
!docs/**
!app/**
!data/**
!scripts/**
!terraform/**

# ...except Terraform working files, which must never be committed.
terraform/**/.terraform/
terraform/**/*.tfstate
terraform/**/*.tfstate.*
```

- [ ] **Step 5: Verify the whitelist matches expectations**

```bash
git add -A
git status --short | head -40
git ls-files --others --exclude-standard | grep -E 'site\.tar\.gz|gpt-design' && echo "LEAK" || echo "no leaks"
```

Expected: `app/html/**` and `data/wordpress.sql` staged; `site.tar.gz` and `gpt-design.txt` absent from the staged set; the word `no leaks` printed.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore: move supplied assets into app/ and data/, open up .gitignore"
```

---

### Task 2: Container image

Package the supplied site into an image. Eight lines of Dockerfile and one line of Apache config — everything here has to be explainable.

**Files:**
- Create: `app/Dockerfile`
- Create: `app/wordpress.conf`

**Interfaces:**
- Consumes: `app/html/` from Task 1.
- Produces: an image serving WordPress on port 80 as uid 33 (`www-data`), with `gd` and `mysqli` loaded, that treats requests carrying `X-Forwarded-Proto: https` as HTTPS. Task 4 pushes it; Task 9's startup script runs it.

- [ ] **Step 1: Write `app/wordpress.conf`**

```apache
# The load balancer terminates TLS and forwards plain HTTP. Without this,
# is_ssl() in wp-includes/load.php returns false, WordPress sees an http://
# request for an https:// site, and redirects forever.
SetEnvIf X-Forwarded-Proto https HTTPS=on
```

- [ ] **Step 2: Write `app/Dockerfile`**

```dockerfile
# WordPress 4.9.4 predates PHP 8 support (added in WP 5.6), so PHP 7.4.
FROM php:7.4-apache

# gd: the active plugins (meow-gallery, wp-smushit) resize images.
# mysqli: WordPress's database driver. mysqlnd in 7.4.33 speaks MySQL 8's
#         default caching_sha2_password, so no server-side auth downgrade.
RUN apt-get update \
 && apt-get install -y --no-install-recommends libpng-dev libjpeg-dev \
 && docker-php-ext-configure gd --with-jpeg \
 && docker-php-ext-install gd mysqli \
 && rm -rf /var/lib/apt/lists/*

COPY wordpress.conf /etc/apache2/conf-enabled/
COPY html/ /var/www/html/
```

No multi-stage build: it would save roughly 20 MB out of ~450 MB and make the runtime dependencies implicit. No `a2enmod rewrite` and no `AllowOverride`: the supplied `.htaccess` wraps its rules in `<IfModule mod_rewrite.c>` so it no-ops silently, and the permalink structure in the dump is `/index.php/%year%/...`, which is PATH_INFO and needs no rewriting.

- [ ] **Step 3: Build the image locally**

```bash
cd /home/itamar/github/wideops-wordpress
docker build -t wordpress-local app/
```

Expected: build succeeds.

- [ ] **Step 4: Smoke-test the image**

```bash
docker run -d --name wptest -p 8080:80 wordpress-local
sleep 5
docker exec wptest php -m | grep -E '^(gd|mysqli)$'
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8080/wp-admin/install.php
docker rm -f wptest
```

Expected: `gd` and `mysqli` both printed, and HTTP `200` from `install.php`. `install.php` is the right probe because it renders without a database; hitting `/` would return a database error, which proves nothing about the image.

- [ ] **Step 5: Commit**

```bash
git add app/Dockerfile app/wordpress.conf
git commit -m "feat: containerise the supplied WordPress site"
```

---

### Task 3: Bootstrap stack — APIs, Artifact Registry, Cloud Build IAM

**Files:**
- Create: `terraform/project.tfvars`
- Create: `terraform/bootstrap/terraform.tf`
- Create: `terraform/bootstrap/providers.tf`
- Create: `terraform/bootstrap/variables.tf`
- Create: `terraform/bootstrap/main.tf`
- Create: `terraform/bootstrap/outputs.tf`

**Interfaces:**
- Consumes: nothing.
- Produces: enabled APIs, and an Artifact Registry Docker repository named `wordpress` in `var.region`. Task 4 pushes to `${region}-docker.pkg.dev/${project_id}/wordpress/wordpress:v1`; `terraform/main` reconstructs that same string in `locals.tf`.

- [ ] **Step 1: Confirm the region actually offers what this plan assumes**

`europe-north2` is newer than a lot of Google's own documentation, so check the API rather than the docs. Substitute your real project ID.

```bash
export PROJECT_ID=<your-project-id>
gcloud config set project "$PROJECT_ID"

gcloud compute machine-types list --filter="zone~europe-north2 AND name=e2-medium" --format="value(zone,name)"
gcloud sql tiers list --filter="tier=db-g1-small" --format="value(tier,region)" | grep europe-north2
gcloud artifacts locations list --filter="name=europe-north2" --format="value(name)"
```

Expected: at least one zone for `e2-medium`, `europe-north2` present for `db-g1-small`, and `europe-north2` listed as an Artifact Registry location. If any of these come back empty, stop and pick another region — change it in one place, `terraform/project.tfvars`.

- [ ] **Step 2: Write `terraform/project.tfvars`**

```hcl
project_id = "REPLACE_WITH_YOUR_PROJECT_ID"
region     = "europe-north2"
```

This file is committed. It holds no secrets — only the project ID and region.

- [ ] **Step 3: Write `terraform/bootstrap/terraform.tf`**

```hcl
terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}
```

- [ ] **Step 4: Write `terraform/bootstrap/providers.tf`**

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}
```

- [ ] **Step 5: Write `terraform/bootstrap/variables.tf`**

```hcl
variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for all regional resources."
  type        = string
}
```

- [ ] **Step 6: Write `terraform/bootstrap/main.tf`**

```hcl
# APIs the main stack depends on.
#   compute            - VPC, MIG, load balancer
#   sqladmin           - Cloud SQL
#   servicenetworking  - VPC peering that gives Cloud SQL its private IP
#   artifactregistry   - the container image
#   cloudbuild         - builds that image
#   iap                - SSH to instances that have no public IP
#   storage            - the media bucket
#   cloudresourcemanager - IAM bindings
locals {
  apis = [
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iap.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
  ]
}

resource "google_project_service" "enabled" {
  for_each = toset(local.apis)

  service = each.value

  # Turning an API off on destroy can break unrelated resources in the
  # project and slows teardown down for no benefit.
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "wordpress" {
  location      = var.region
  repository_id = "wordpress"
  format        = "DOCKER"
  description   = "WordPress application image"

  depends_on = [google_project_service.enabled]
}

data "google_project" "this" {
  depends_on = [google_project_service.enabled]
}

# Cloud Build runs as the Compute Engine default service account in projects
# created after mid-2024. It needs to push to Artifact Registry and to write
# its own build logs.
resource "google_project_iam_member" "build_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "build_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}
```

- [ ] **Step 7: Write `terraform/bootstrap/outputs.tf`**

```hcl
output "repository_id" {
  description = "Artifact Registry repository that holds the WordPress image."
  value       = google_artifact_registry_repository.wordpress.repository_id
}

output "project_number" {
  description = "Numeric project ID, used to name the default service accounts."
  value       = data.google_project.this.number
}
```

- [ ] **Step 8: Validate**

```bash
terraform -chdir=terraform/bootstrap init
terraform -chdir=terraform/bootstrap fmt -check
terraform -chdir=terraform/bootstrap validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 9: Apply**

```bash
terraform -chdir=terraform/bootstrap apply -var-file=../project.tfvars
```

Enabling `compute.googleapis.com` on a fresh project takes a few minutes. If the Artifact Registry resource fails on the first run with a "not enabled" error, re-run the same command — the APIs are enabled by then.

- [ ] **Step 10: Verify**

```bash
gcloud artifacts repositories describe wordpress --location=europe-north2 --format="value(name,format)"
```

Expected: the repository path and `DOCKER`.

- [ ] **Step 11: Commit**

```bash
git add terraform/project.tfvars terraform/bootstrap
git commit -m "feat: bootstrap stack enabling APIs and creating the image repository"
```

---

### Task 4: Build and push the image

**Files:**
- No new files. This task runs commands and records their exact form for the Makefile and README.

**Interfaces:**
- Consumes: `app/` from Task 2, the Artifact Registry repository from Task 3.
- Produces: the image `europe-north2-docker.pkg.dev/${PROJECT_ID}/wordpress/wordpress:v1`. `terraform/main/locals.tf` reconstructs exactly this string, so the tag `v1` and the image name `wordpress` are fixed.

- [ ] **Step 1: Submit the build**

```bash
cd /home/itamar/github/wideops-wordpress
gcloud builds submit app/ \
  --tag "europe-north2-docker.pkg.dev/${PROJECT_ID}/wordpress/wordpress:v1" \
  --region=europe-north2
```

- [ ] **Step 2: If Cloud Build refuses to run, fall back to a local build and push**

Fresh personal projects sometimes lack the legacy Cloud Build service account, and the submit fails with `build.service_account is required` or a logs-bucket error. Docker is already installed locally, so this is a complete substitute — the resulting image is identical:

```bash
gcloud auth configure-docker europe-north2-docker.pkg.dev --quiet
docker build -t "europe-north2-docker.pkg.dev/${PROJECT_ID}/wordpress/wordpress:v1" app/
docker push "europe-north2-docker.pkg.dev/${PROJECT_ID}/wordpress/wordpress:v1"
```

Whichever path works, note it — the Makefile target and the README step in Tasks 15 and 16 must document the one actually used.

- [ ] **Step 3: Verify the image landed**

```bash
gcloud artifacts docker images list \
  "europe-north2-docker.pkg.dev/${PROJECT_ID}/wordpress" \
  --format="table(package,tags,createTime)"
```

Expected: one row, tag `v1`.

---

### Task 5: Main stack scaffolding and network

One subnet, not two. Cloud SQL does not sit in your subnet — it lives in a Google-managed VPC attached to yours by service networking peering, and that peering consumes a separately reserved global address range. A second subnet would have nothing to hold.

**Files:**
- Create: `terraform/main/terraform.tf`
- Create: `terraform/main/providers.tf`
- Create: `terraform/main/variables.tf`
- Create: `terraform/main/locals.tf`
- Create: `terraform/main/network.tf`

**Interfaces:**
- Consumes: `var.project_id`, `var.region` from `terraform/project.tfvars`; the Artifact Registry repository name `wordpress` from Task 3.
- Produces:
  - `google_compute_network.vpc` — referenced by firewall rules, the router, the SQL peering and the instance template.
  - `google_compute_subnetwork.main` — referenced by the instance template's `network_interface`.
  - `google_service_networking_connection.private_vpc` — Task 8's SQL instances `depends_on` this.
  - `local.image` — the full image URL, consumed by Task 9's startup script.

- [ ] **Step 1: Write `terraform/main/terraform.tf`**

```hcl
terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}
```

State stays local for now, and is gitignored. `docs/decisions.md` §2 records why, and the exact steps to migrate to a GCS backend later.

- [ ] **Step 2: Write `terraform/main/providers.tf`**

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}
```

- [ ] **Step 3: Write `terraform/main/variables.tf`**

```hcl
variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for all regional resources."
  type        = string
}

variable "subnet_cidr" {
  description = "Primary range of the single application subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "machine_type" {
  description = "Instance type for the WordPress MIG. Fixed by the assignment."
  type        = string
  default     = "e2-medium"
}

variable "db_tier" {
  description = "Cloud SQL tier. Shared-core, as the assignment requires."
  type        = string
  default     = "db-g1-small"
}

variable "db_password" {
  description = <<-EOT
    Password for the 'wordpress' database user. Hardcoded in the supplied
    wp-config.php, which we are not permitted to modify, so it is fixed here
    rather than generated. See docs/decisions.md.
  EOT
  type        = string
  default     = "Foxtrot01"
  sensitive   = true
}

variable "image_tag" {
  description = "Tag of the WordPress image in Artifact Registry."
  type        = string
  default     = "v1"
}

variable "repository_id" {
  description = "Artifact Registry repository created by the bootstrap stack."
  type        = string
  default     = "wordpress"
}

variable "ssl_certificate_name" {
  description = "Name of the self-signed SSL certificate created by scripts/cert.sh."
  type        = string
  default     = "wordpress-selfsigned"
}

variable "min_replicas" {
  description = "Autoscaler floor. Two, so a zone failure never leaves zero."
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Autoscaler ceiling."
  type        = number
  default     = 5
}
```

- [ ] **Step 4: Write `terraform/main/locals.tf`**

```hcl
locals {
  # Rebuilt from the same pieces `gcloud builds submit --tag` used, so the
  # instances pull exactly the image that was pushed.
  image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}/wordpress:${var.image_tag}"
}
```

- [ ] **Step 5: Write `terraform/main/network.tf`**

```hcl
resource "google_compute_network" "vpc" {
  name = "wp-vpc"

  # Custom VPC, as the assignment requires: no auto-created subnets in every
  # region, only the one subnet below.
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "wp-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr

  # Lets instances reach Artifact Registry and Cloud Storage over Google's
  # network instead of through Cloud NAT.
  private_ip_google_access = true
}

# ---------------------------------------------------------------------------
# Outbound internet for instances that have no external IP: apt packages and
# the gcsfuse .deb during boot.
# ---------------------------------------------------------------------------

resource "google_compute_router" "router" {
  name    = "wp-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "wp-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ---------------------------------------------------------------------------
# Firewall. Both source ranges come from a data source rather than hardcoded
# CIDRs, so if Google ever changes them a `terraform apply` picks it up.
# ---------------------------------------------------------------------------

data "google_netblock_ip_ranges" "health_checkers" {
  range_type = "health-checkers"
}

data "google_netblock_ip_ranges" "iap" {
  range_type = "iap-forwarders"
}

# The global external Application Load Balancer sends both health checks and
# real traffic from these ranges. This is the ONLY way in on port 80.
resource "google_compute_firewall" "allow_lb" {
  name    = "wp-allow-lb"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = data.google_netblock_ip_ranges.health_checkers.cidr_blocks_ipv4
  target_tags   = ["wordpress"]
}

# SSH arrives only through Identity-Aware Proxy, so administrative access is
# authenticated by IAM rather than by owning an IP address.
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "wp-allow-iap-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = data.google_netblock_ip_ranges.iap.cidr_blocks_ipv4
  target_tags   = ["wordpress"]
}

# ---------------------------------------------------------------------------
# Private Service Access: the peering that lets Cloud SQL hold a private IP
# reachable from this VPC, so the database never gets a public address.
# ---------------------------------------------------------------------------

resource "google_compute_global_address" "private_ip" {
  name          = "wp-sql-private-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}
```

- [ ] **Step 6: Validate**

```bash
terraform -chdir=terraform/main init
terraform -chdir=terraform/main fmt -check
terraform -chdir=terraform/main validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 7: Commit**

```bash
git add terraform/main
git commit -m "feat: custom VPC, Cloud NAT, firewall and Cloud SQL peering"
```

---

### Task 6: Instance service account and project-level IAM

**Files:**
- Create: `terraform/main/iam.tf`

**Interfaces:**
- Consumes: `var.project_id`.
- Produces: `google_service_account.wordpress` — referenced by the instance template in Task 9 and by the bucket bindings in Task 7 as `google_service_account.wordpress.email`.

- [ ] **Step 1: Write `terraform/main/iam.tf`**

```hcl
# A dedicated identity for the instances. The default Compute Engine service
# account is Editor on the whole project; this one holds three roles.
resource "google_service_account" "wordpress" {
  account_id   = "wordpress-vm"
  display_name = "WordPress MIG instances"
}

# Lets the Cloud SQL Auth Proxy open a connection. This is what replaces a
# database network credential: the instance proves who it is with its service
# account, not with an IP allowlist.
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.wordpress.email}"
}

# Pull the WordPress image at boot.
resource "google_project_iam_member" "artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.wordpress.email}"
}

# Ship instance logs to Cloud Logging.
resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.wordpress.email}"
}
```

Write access to the media bucket is granted on the bucket itself in Task 7, not at project level, so it cannot reach any other bucket.

- [ ] **Step 2: Validate**

```bash
terraform -chdir=terraform/main validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Commit**

```bash
git add terraform/main/iam.tf
git commit -m "feat: least-privilege service account for the WordPress instances"
```

---

### Task 7: Media bucket

**Files:**
- Create: `terraform/main/storage.tf`

**Interfaces:**
- Consumes: `google_service_account.wordpress` from Task 6.
- Produces: `google_storage_bucket.media` — consumed by the startup script's gcsfuse mount (Task 9), by the backend bucket (Task 11) and by `scripts/seed.sh` (Task 13) via the `media_bucket` output.

- [ ] **Step 1: Write `terraform/main/storage.tf`**

```hcl
resource "google_storage_bucket" "media" {
  name     = "${var.project_id}-wp-media"
  location = var.region

  # IAM only, no per-object ACLs. Simpler to reason about and required for
  # the bucket to be a clean load-balancer backend.
  uniform_bucket_level_access = true

  # This is a demo environment that gets torn down; let destroy remove the
  # objects rather than failing on a non-empty bucket.
  force_destroy = true
}

# The load balancer's backend bucket fetches objects anonymously, so uploads
# must be publicly readable. See docs/decisions.md section 1 - this also
# permits listing, which is acceptable for media already on a public site.
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.media.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# The instances write here through gcsfuse when someone uploads media in
# wp-admin. Scoped to this bucket, not the project.
resource "google_storage_bucket_iam_member" "instance_write" {
  bucket = google_storage_bucket.media.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.wordpress.email}"
}
```

Note: `public_access_prevention` is deliberately left unset (it defaults to `inherited`). Setting it to `enforced` would make the `allUsers` binding fail.

- [ ] **Step 2: Validate**

```bash
terraform -chdir=terraform/main validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Commit**

```bash
git add terraform/main/storage.tf
git commit -m "feat: media bucket with public read and instance write"
```

---

### Task 8: Cloud SQL primary and read replica

**Files:**
- Create: `terraform/main/sql.tf`

**Interfaces:**
- Consumes: `google_compute_network.vpc` and `google_service_networking_connection.private_vpc` from Task 5.
- Produces: `google_sql_database_instance.primary.connection_name` — a `project:region:instance` string consumed by the startup script's Cloud SQL Auth Proxy invocation (Task 9) and exported as the `sql_connection_name` output (Task 11).

- [ ] **Step 1: Write `terraform/main/sql.tf`**

```hcl
resource "google_sql_database_instance" "primary" {
  name             = "wp-primary"
  database_version = "MYSQL_8_0"
  region           = var.region

  # The peering must exist before an instance can take a private IP.
  depends_on = [google_service_networking_connection.private_vpc]

  # Demo environment - let `terraform destroy` actually destroy.
  deletion_protection = false

  settings {
    tier              = var.db_tier
    availability_type = "ZONAL"

    ip_configuration {
      # No public IP. The only route in is the VPC peering above.
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }

    # Binary logging is what a read replica streams from, so this block is
    # not optional once a replica exists.
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
      start_time         = "03:00"
    }
  }
}

resource "google_sql_database_instance" "replica" {
  name                 = "wp-replica"
  database_version     = "MYSQL_8_0"
  region               = var.region
  master_instance_name = google_sql_database_instance.primary.name

  deletion_protection = false

  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = var.db_tier
    availability_type = "ZONAL"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
  }
}

# Name, user and password are all fixed by the supplied wp-config.php, which
# we are not permitted to modify.
resource "google_sql_database" "wordpress" {
  name      = "wordpress"
  instance  = google_sql_database_instance.primary.name
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

resource "google_sql_user" "wordpress" {
  name     = "wordpress"
  instance = google_sql_database_instance.primary.name
  host     = "%"
  password = var.db_password
}
```

No `database_flags` block. MySQL 8.0 defaults to `caching_sha2_password`, and PHP 7.4.4+ with mysqlnd — the image is 7.4.33 — speaks it natively. If a connection ever fails with `The server requested authentication method unknown to the client`, the one-line fix is a runbook entry, not a config change:

```bash
gcloud sql instances patch wp-primary --database-flags=default_authentication_plugin=mysql_native_password
```

- [ ] **Step 2: Validate**

```bash
terraform -chdir=terraform/main validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Commit**

```bash
git add terraform/main/sql.tf
git commit -m "feat: Cloud SQL primary and read replica on private IP"
```

---

### Task 9: Instance template, MIG, autoscaler and startup script

**Files:**
- Create: `terraform/main/startup.sh.tftpl`
- Create: `terraform/main/compute.tf`

**Interfaces:**
- Consumes: `google_compute_subnetwork.main` (Task 5), `google_service_account.wordpress` (Task 6), `google_storage_bucket.media` (Task 7), `google_sql_database_instance.primary.connection_name` (Task 8), `local.image` (Task 5).
- Produces:
  - `google_compute_health_check.http` — reused by the backend service in Task 11.
  - `google_compute_region_instance_group_manager.wordpress` — its `.instance_group` attribute is the backend in Task 11, and its `.name` is exported for the load test in Task 14.

- [ ] **Step 1: Write `terraform/main/startup.sh.tftpl`**

```bash
#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Packages. Docker runs the two containers; gcsfuse presents the media bucket
# as a directory so WordPress's upload code needs no changes.
# ---------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq docker.io curl

curl -fsSL -o /tmp/gcsfuse.deb \
  https://github.com/GoogleCloudPlatform/gcsfuse/releases/download/v2.5.2/gcsfuse_2.5.2_amd64.deb
apt-get install -y -qq /tmp/gcsfuse.deb

# ---------------------------------------------------------------------------
# Mount only the uploads prefix of the bucket.
#   --only-dir     the bucket root also holds nothing else, but this keeps the
#                  object layout identical to the URL layout
#   --implicit-dirs GCS has no real directories; this makes prefixes browsable
#   --uid/--gid 33 www-data inside the container
#   -o allow_other root mounts it, www-data reads it; FUSE blocks that by default
# ---------------------------------------------------------------------------
mkdir -p /mnt/uploads
mountpoint -q /mnt/uploads || gcsfuse \
  --only-dir wp-content/uploads \
  --implicit-dirs \
  --uid 33 --gid 33 \
  -o allow_other \
  ${media_bucket} /mnt/uploads

# ---------------------------------------------------------------------------
# Authenticate Docker against Artifact Registry using the instance's own
# service account. No keys anywhere.
# ---------------------------------------------------------------------------
gcloud auth configure-docker ${region}-docker.pkg.dev --quiet

# ---------------------------------------------------------------------------
# Both containers share the host network namespace, which is what makes
# DB_HOST='localhost' in the supplied wp-config.php literally true: the proxy
# listens on 127.0.0.1:3306 and Apache connects to 127.0.0.1:3306.
# ---------------------------------------------------------------------------
docker rm -f sqlproxy wordpress 2>/dev/null || true

docker run -d --name sqlproxy --restart unless-stopped --network host \
  gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.14.1 \
  --private-ip --address 127.0.0.1 --port 3306 ${sql_connection_name}

docker run -d --name wordpress --restart unless-stopped --network host \
  -v /mnt/uploads:/var/www/html/wp-content/uploads \
  ${image}
```

No Docker Compose: with host networking and no shared volumes it would add a file and a dependency without removing a line, and `depends_on` does not wait for readiness anyway. Compose's `${VAR}` syntax also collides with Terraform's inside a `templatefile`.

- [ ] **Step 2: Write `terraform/main/compute.tf`**

```hcl
data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance_template" "wordpress" {
  name_prefix  = "wp-"
  machine_type = var.machine_type
  tags         = ["wordpress"]

  disk {
    source_image = data.google_compute_image.ubuntu.self_link
    auto_delete  = true
    boot         = true
    disk_size_gb = 20
    disk_type    = "pd-balanced"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.main.id
    # No access_config block, so no external IP. The only inbound path is the
    # load balancer; the only outbound path is Cloud NAT.
  }

  service_account {
    email  = google_service_account.wordpress.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh.tftpl", {
    image               = local.image
    region              = var.region
    media_bucket        = google_storage_bucket.media.name
    sql_connection_name = google_sql_database_instance.primary.connection_name
  })

  # A template is immutable; the MIG must move to the new one before the old
  # one can go away.
  lifecycle {
    create_before_destroy = true
  }
}

# A TCP check, not an HTTP one. It costs no PHP execution, and it does not
# couple an instance's health to the shared database - if Cloud SQL hiccups,
# autohealing must not respond by deleting every instance.
resource "google_compute_health_check" "http" {
  name = "wp-health"

  tcp_health_check {
    port = 80
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

resource "google_compute_region_instance_group_manager" "wordpress" {
  name               = "wp-mig"
  region             = var.region
  base_instance_name = "wp"

  version {
    instance_template = google_compute_instance_template.wordpress.id
  }

  # The load balancer's backend service refers to this port by name.
  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check = google_compute_health_check.http.id

    # Boot, apt-get, gcsfuse and an image pull take a while. Recreating an
    # instance that is merely still starting would loop forever.
    initial_delay_sec = 300
  }
}

resource "google_compute_region_autoscaler" "wordpress" {
  name   = "wp-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.wordpress.id

  autoscaling_policy {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    # Longer than a boot takes, so the CPU burned by apt-get and the image
    # pull is not read as user load - otherwise scaling out causes more
    # scaling out.
    cooldown_period = 120

    cpu_utilization {
      target = 0.6
    }
  }
}
```

- [ ] **Step 3: Validate**

```bash
terraform -chdir=terraform/main validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 4: Commit**

```bash
git add terraform/main/compute.tf terraform/main/startup.sh.tftpl
git commit -m "feat: regional MIG with autoscaling, autohealing and boot script"
```

---

### Task 10: Self-signed certificate

The assignment asks for a self-signed certificate. Generating it with `openssl` and uploading it with `gcloud` — rather than with `tls_private_key` in Terraform — keeps the private key out of Terraform state entirely. `docs/decisions.md` §3 records the conditions under which this should move into Terraform.

**Files:**
- Create: `scripts/cert.sh`

**Interfaces:**
- Consumes: nothing.
- Produces: a global SSL certificate resource named `wordpress-selfsigned`. Task 11 reads it back with `data "google_compute_ssl_certificate"`, matching `var.ssl_certificate_name`.

- [ ] **Step 1: Write `scripts/cert.sh`**

```bash
#!/usr/bin/env bash
# Generate a self-signed certificate and register it with Compute Engine.
#
# Deliberately not Terraform: anything Terraform generates lands in state in
# plaintext, and this state is local. Doing it here means the private key
# never enters state at all. See docs/decisions.md section 3.
set -euo pipefail
cd "$(dirname "$0")/.."

CERT_NAME="${CERT_NAME:-wordpress-selfsigned}"

if gcloud compute ssl-certificates describe "$CERT_NAME" --global >/dev/null 2>&1; then
  echo "==> certificate '$CERT_NAME' already exists, nothing to do"
  exit 0
fi

# certs/ is not whitelisted in .gitignore, so the key can never be committed.
mkdir -p certs

echo "==> generating self-signed certificate"
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout certs/wordpress.key \
  -out    certs/wordpress.crt \
  -subj   "/CN=wordpress-demo/O=WideOps Assignment"

echo "==> uploading to Compute Engine as '$CERT_NAME'"
gcloud compute ssl-certificates create "$CERT_NAME" \
  --certificate=certs/wordpress.crt \
  --private-key=certs/wordpress.key \
  --global

echo "==> done"
```

- [ ] **Step 2: Make it executable and run it**

```bash
chmod +x scripts/cert.sh
scripts/cert.sh
```

- [ ] **Step 3: Verify, and confirm it is safe to re-run**

```bash
gcloud compute ssl-certificates describe wordpress-selfsigned --global \
  --format="value(name,creationTimestamp)"
scripts/cert.sh
git check-ignore -v certs/wordpress.key
```

Expected: the certificate name and timestamp; the second run prints `already exists, nothing to do`; `git check-ignore` confirms the key is ignored (by the `*` rule).

- [ ] **Step 4: Commit**

```bash
git add scripts/cert.sh
git commit -m "feat: self-signed certificate script that keeps the key out of state"
```

---

### Task 11: Load balancer and outputs

Two backends behind one URL map. `/wp-content/uploads/*` goes to a CDN-backed backend bucket, so media is served from Google's edge and never touches an instance. Everything else goes to the MIG.

**Files:**
- Create: `terraform/main/lb.tf`
- Create: `terraform/main/outputs.tf`

**Interfaces:**
- Consumes: `google_compute_region_instance_group_manager.wordpress.instance_group` and `google_compute_health_check.http` (Task 9), `google_storage_bucket.media` (Task 7), the certificate named by `var.ssl_certificate_name` (Task 10).
- Produces: outputs `lb_ip`, `media_bucket`, `sql_connection_name`, `sql_replica_connection_name`, `mig_name`, `region`. Tasks 13 and 14 read these by exactly these names.

- [ ] **Step 1: Write `terraform/main/lb.tf`**

```hcl
# The certificate is created by scripts/cert.sh, so Terraform reads it rather
# than owning it - which is how the private key stays out of state.
data "google_compute_ssl_certificate" "wordpress" {
  name = var.ssl_certificate_name
}

resource "google_compute_global_address" "lb" {
  name = "wp-lb-ip"
}

# ---------------------------------------------------------------------------
# Backends
# ---------------------------------------------------------------------------

resource "google_compute_backend_service" "wordpress" {
  name                  = "wp-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.http.id]

  backend {
    group           = google_compute_region_instance_group_manager.wordpress.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# Uploaded media is served straight from Cloud Storage through Cloud CDN.
# Instances never see this traffic, so scaling is driven by PHP work only.
resource "google_compute_backend_bucket" "media" {
  name        = "wp-media-backend"
  bucket_name = google_storage_bucket.media.name
  enable_cdn  = true
}

# ---------------------------------------------------------------------------
# Routing
# ---------------------------------------------------------------------------

resource "google_compute_url_map" "wordpress" {
  name            = "wp-urlmap"
  default_service = google_compute_backend_service.wordpress.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.wordpress.id

    # Objects live in the bucket at the same path the browser requests, so
    # no rewriting is needed.
    path_rule {
      paths   = ["/wp-content/uploads/*"]
      service = google_compute_backend_bucket.media.id
    }
  }
}

resource "google_compute_target_https_proxy" "wordpress" {
  name             = "wp-https-proxy"
  url_map          = google_compute_url_map.wordpress.id
  ssl_certificates = [data.google_compute_ssl_certificate.wordpress.id]
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "wp-https"
  target                = google_compute_target_https_proxy.wordpress.id
  ip_address            = google_compute_global_address.lb.address
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# ---------------------------------------------------------------------------
# Port 80 exists only to redirect. No plaintext ever reaches a backend.
# ---------------------------------------------------------------------------

resource "google_compute_url_map" "redirect" {
  name = "wp-redirect"

  default_url_redirect {
    https_redirect         = true
    strip_query            = false
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  name    = "wp-http-proxy"
  url_map = google_compute_url_map.redirect.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "wp-http"
  target                = google_compute_target_http_proxy.redirect.id
  ip_address            = google_compute_global_address.lb.address
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
```

- [ ] **Step 2: Write `terraform/main/outputs.tf`**

```hcl
output "lb_ip" {
  description = "Public IP of the load balancer. The site's address."
  value       = google_compute_global_address.lb.address
}

output "site_url" {
  description = "Convenience URL. The certificate is self-signed, so browsers warn."
  value       = "https://${google_compute_global_address.lb.address}"
}

output "media_bucket" {
  description = "Bucket holding wp-content/uploads."
  value       = google_storage_bucket.media.name
}

output "sql_connection_name" {
  description = "Primary instance connection name, as the Auth Proxy wants it."
  value       = google_sql_database_instance.primary.connection_name
}

output "sql_replica_connection_name" {
  description = "Read replica connection name. Not used by WordPress."
  value       = google_sql_database_instance.replica.connection_name
}

output "mig_name" {
  description = "Regional managed instance group, for watching the autoscaler."
  value       = google_compute_region_instance_group_manager.wordpress.name
}

output "region" {
  description = "Region everything lives in, so scripts do not hardcode it."
  value       = var.region
}
```

- [ ] **Step 3: Validate**

```bash
terraform -chdir=terraform/main fmt -check
terraform -chdir=terraform/main validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 4: Commit**

```bash
git add terraform/main/lb.tf terraform/main/outputs.tf
git commit -m "feat: HTTPS load balancer with CDN-backed media backend"
```

---

### Task 12: Apply the main stack

**Files:**
- No new files. This task runs the stack and confirms the design actually works.

**Interfaces:**
- Consumes: Tasks 3, 4, 5–11.
- Produces: a running environment, and the output values Tasks 13 and 14 consume.

- [ ] **Step 1: Review the plan before applying**

```bash
terraform -chdir=terraform/main plan -var-file=../project.tfvars
```

Expected: a clean plan with no errors. Skim the resource list — nothing should be marked for destruction on a first run.

- [ ] **Step 2: Apply**

```bash
terraform -chdir=terraform/main apply -var-file=../project.tfvars
```

This takes roughly 15–20 minutes. Cloud SQL is the slow part: the primary takes about 10 minutes and the replica cannot start until the primary is up.

- [ ] **Step 3: Wait for the backends to pass health checks**

```bash
REGION=$(terraform -chdir=terraform/main output -raw region)
watch -n 15 "gcloud compute backend-services get-health wp-backend --global \
  --format='value(status.healthStatus[].healthState)'"
```

Expected: two instances reporting `HEALTHY`. Allow 3–5 minutes after apply finishes — that is `apt-get`, the gcsfuse install and the image pull.

- [ ] **Step 4: Confirm the site is being served**

```bash
LB_IP=$(terraform -chdir=terraform/main output -raw lb_ip)
curl -k -s -o /dev/null -w 'https: %{http_code}\n' "https://$LB_IP/wp-admin/install.php"
curl -s -o /dev/null -w 'http redirect: %{http_code} -> %{redirect_url}\n' "http://$LB_IP/"
```

Expected: `https: 200`, and the HTTP request returning `301` with an `https://` redirect target. `-k` is required and expected — the certificate is self-signed.

At this point the database is still empty, so `/` will show a WordPress error. That is Task 13's job.

- [ ] **Step 5: If instances never go healthy, read the boot log**

```bash
ZONE=$(gcloud compute instances list --filter="name~^wp-" --format="value(zone)" --limit=1)
VM=$(gcloud compute instances list --filter="name~^wp-" --format="value(name)" --limit=1)
gcloud compute ssh "$VM" --zone "$ZONE" --tunnel-through-iap \
  --command "sudo journalctl -u google-startup-scripts --no-pager | tail -50; docker ps -a"
```

The one dependency worth checking first is `gcloud` itself: the startup script calls `gcloud auth configure-docker`, which assumes the CLI is present on the Ubuntu image. If the log shows `gcloud: command not found`, replace that single line in `startup.sh.tftpl` with a metadata-server token, which has no dependencies:

```bash
curl -s -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['access_token'])" \
  | docker login -u oauth2accesstoken --password-stdin "https://${region}-docker.pkg.dev"
```

Then `terraform apply` again and roll the MIG:

```bash
gcloud compute instance-groups managed rolling-action replace wp-mig --region "$REGION"
```

---

### Task 13: Seed the database and media

The dump and the uploads both carry the old server's address, `http://104.155.81.48`, in 66 places. All 66 are plain strings — none sit inside a PHP-serialized value (`s:NN:"..."`), which was verified against the dump — so a plain SQL `REPLACE` is safe and no WordPress tooling is needed.

Rewriting `siteurl` and `home` in the database is also what makes `WP_HOME`/`WP_SITEURL` constants unnecessary. That is why no PHP file is authored.

Because Cloud SQL has no public IP, the import runs from an instance over IAP rather than from the laptop. That instance already has a working Auth Proxy on `127.0.0.1:3306`; a throwaway `mysql:8.0` container supplies the client.

**Files:**
- Create: `scripts/seed.sh`

**Interfaces:**
- Consumes: `data/wordpress.sql` and `app/html/wp-content/uploads` (Task 1); the outputs `media_bucket`, `lb_ip` (Task 11).
- Produces: a populated database and a populated bucket. Nothing consumes this programmatically.

- [ ] **Step 1: Write `scripts/seed.sh`**

```bash
#!/usr/bin/env bash
# One-time data migration: uploads into the bucket, dump into Cloud SQL, and
# the old server's URL rewritten to the load balancer's.
#
# Deliberately not Terraform: this is table contents, not infrastructure.
# See docs/decisions.md section 3.
set -euo pipefail
cd "$(dirname "$0")/.."

TF="terraform -chdir=terraform/main"
BUCKET=$($TF output -raw media_bucket)
LB_IP=$($TF output -raw lb_ip)
OLD_URL="http://104.155.81.48"
NEW_URL="https://$LB_IP"

# Any instance will do - they are identical and all reach the same database.
VM=$(gcloud compute instances list --filter="name~^wp-" --format="value(name)" --limit=1)
ZONE=$(gcloud compute instances list --filter="name~^wp-" --format="value(zone)" --limit=1)
[ -n "$VM" ] || { echo "no instances found; is the MIG up?" >&2; exit 1; }

echo "==> syncing uploads into gs://$BUCKET/wp-content/uploads"
gsutil -m rsync -r app/html/wp-content/uploads "gs://$BUCKET/wp-content/uploads"

echo "==> copying the dump to $VM"
gcloud compute scp data/wordpress.sql "$VM:/tmp/wordpress.sql" \
  --zone "$ZONE" --tunnel-through-iap

# The instance already runs the Cloud SQL Auth Proxy on 127.0.0.1:3306, so a
# throwaway mysql client sharing the host network can just connect to it.
MYSQL="docker run --rm -i --network host mysql:8.0 mysql -h 127.0.0.1 -u wordpress -pFoxtrot01 wordpress"

echo "==> importing the dump"
gcloud compute ssh "$VM" --zone "$ZONE" --tunnel-through-iap \
  --command "$MYSQL < /tmp/wordpress.sql"

echo "==> rewriting $OLD_URL -> $NEW_URL"
gcloud compute ssh "$VM" --zone "$ZONE" --tunnel-through-iap --command "$MYSQL" <<SQL
UPDATE wp_options  SET option_value = REPLACE(option_value, '$OLD_URL', '$NEW_URL');
UPDATE wp_posts    SET post_content = REPLACE(post_content, '$OLD_URL', '$NEW_URL');
UPDATE wp_posts    SET guid         = REPLACE(guid,         '$OLD_URL', '$NEW_URL');
UPDATE wp_postmeta SET meta_value   = REPLACE(meta_value,   '$OLD_URL', '$NEW_URL');
SQL

echo "==> cleaning up"
gcloud compute ssh "$VM" --zone "$ZONE" --tunnel-through-iap \
  --command "rm -f /tmp/wordpress.sql"

echo "==> done. site: $NEW_URL"
```

- [ ] **Step 2: Run it**

```bash
chmod +x scripts/seed.sh
scripts/seed.sh
```

- [ ] **Step 3: Verify the site renders and the old IP is gone**

```bash
LB_IP=$(terraform -chdir=terraform/main output -raw lb_ip)
curl -k -s "https://$LB_IP/" -o /tmp/home.html -w 'status: %{http_code}\n'
grep -c '104\.155\.81\.48' /tmp/home.html || echo "old IP absent: good"
grep -o 'src="[^"]*wp-content/uploads[^"]*"' /tmp/home.html | head -3
```

Expected: `status: 200`, `old IP absent: good`, and image `src` attributes pointing at `https://$LB_IP/wp-content/uploads/...`.

- [ ] **Step 4: Verify media is served by the bucket, not an instance**

```bash
IMG=$(grep -o 'https://[^"]*wp-content/uploads[^"]*' /tmp/home.html | head -1)
curl -k -s -o /dev/null -D - "$IMG" | grep -iE '^(HTTP/|x-goog-|age:|cache-control:)'
```

Expected: `200`, plus `x-goog-*` headers — proof the response came from the backend bucket rather than from Apache.

- [ ] **Step 5: Verify statelessness — the same page from every instance**

```bash
for i in 1 2 3 4 5 6; do
  curl -k -s -o /dev/null -w '%{http_code} %{time_total}s\n' "https://$LB_IP/"
done
```

Expected: six `200`s. Requests land on different instances and all return the same site, which is the whole point of moving state off the disk.

- [ ] **Step 6: Commit**

```bash
git add scripts/seed.sh
git commit -m "feat: seed script for the database dump, URL rewrite and media"
```

---

### Task 14: Load test and autoscaling proof

**Files:**
- Create: `scripts/load-test.sh`

**Interfaces:**
- Consumes: outputs `lb_ip` and `mig_name` (Task 11).
- Produces: evidence that the MIG scales 2 → 5. Nothing consumes this.

- [ ] **Step 1: Write `scripts/load-test.sh`**

```bash
#!/usr/bin/env bash
# Drive enough traffic at the site to push average CPU past the autoscaler's
# 60% target, and print the instance count while it happens.
#
# `hey` skips TLS verification, which it has to - the certificate is self-signed.
set -euo pipefail
cd "$(dirname "$0")/.."

TF="terraform -chdir=terraform/main"
LB_IP=$($TF output -raw lb_ip)
MIG=$($TF output -raw mig_name)
REGION=$($TF output -raw region)

DURATION="${DURATION:-8m}"
CONCURRENCY="${CONCURRENCY:-150}"

echo "==> hammering https://$LB_IP/ for $DURATION at concurrency $CONCURRENCY"
hey -z "$DURATION" -c "$CONCURRENCY" "https://$LB_IP/" &
HEY_PID=$!
trap 'kill $HEY_PID 2>/dev/null || true' EXIT

while kill -0 $HEY_PID 2>/dev/null; do
  COUNT=$(gcloud compute instance-groups managed list-instances "$MIG" \
            --region "$REGION" --format="value(name)" | wc -l)
  printf '%s  instances: %s\n' "$(date +%H:%M:%S)" "$COUNT"
  sleep 30
done

wait $HEY_PID || true
echo "==> load finished. The group scales back down after ~10 minutes of quiet."
```

The homepage is the right target: it is PHP, it is uncached, and its images are served by the bucket rather than the instances — so the CPU the autoscaler sees is genuine application work.

- [ ] **Step 2: Run it**

```bash
chmod +x scripts/load-test.sh
scripts/load-test.sh
```

Expected: the printed instance count rising from 2 toward 5 within a few minutes. The autoscaler's `cooldown_period` is 120s, and each new instance needs 3–5 minutes to boot and pass health checks, so give it time.

- [ ] **Step 3: Capture the evidence for the README**

```bash
REGION=$(terraform -chdir=terraform/main output -raw region)
gcloud compute instance-groups managed describe wp-mig --region "$REGION" \
  --format="value(targetSize,status.autoscaler)"
gcloud compute instance-groups managed list-instances wp-mig --region "$REGION" \
  --format="table(name,zone.basename(),status)"
```

Expected: `targetSize` above 2, and instances spread across more than one zone — which is the high-availability claim, demonstrated.

- [ ] **Step 4: Commit**

```bash
git add scripts/load-test.sh
git commit -m "feat: load test that demonstrates the autoscaler"
```

---

### Task 15: Makefile

Thin wrappers only. Every target is a command already proven in Tasks 3–14, so the Makefile documents the workflow rather than inventing one.

**Files:**
- Create: `Makefile`

**Interfaces:**
- Consumes: everything above.
- Produces: the targets the README instructs a reader to run.

- [ ] **Step 1: Write `Makefile`**

```make
PROJECT_ID := $(shell grep '^project_id' terraform/project.tfvars | cut -d'"' -f2)
REGION     := $(shell grep '^region'     terraform/project.tfvars | cut -d'"' -f2)
IMAGE      := $(REGION)-docker.pkg.dev/$(PROJECT_ID)/wordpress/wordpress:v1

.PHONY: bootstrap image cert infra seed load-test destroy

bootstrap: ## One-time: enable project APIs and create the image repository
	terraform -chdir=terraform/bootstrap init
	terraform -chdir=terraform/bootstrap apply -var-file=../project.tfvars

image: ## Build the WordPress image and push it to Artifact Registry
	gcloud builds submit app/ --tag $(IMAGE) --region=$(REGION)

cert: ## Create the self-signed certificate and register it with Compute Engine
	scripts/cert.sh

infra: ## Provision the network, database, bucket, instance group and load balancer
	terraform -chdir=terraform/main init
	terraform -chdir=terraform/main apply -var-file=../project.tfvars

seed: ## Import wordpress.sql, rewrite the site URL, push uploads to the bucket
	scripts/seed.sh

load-test: ## Drive traffic to trip the autoscaler (DURATION=8m CONCURRENCY=150 to override)
	scripts/load-test.sh

destroy: ## Tear down the main stack (bootstrap and the certificate stay)
	terraform -chdir=terraform/main destroy -var-file=../project.tfvars
	@echo "The SSL certificate is not managed by Terraform. To remove it:"
	@echo "  gcloud compute ssl-certificates delete wordpress-selfsigned --global"
```

If Task 4 had to fall back to a local build, replace the `image` target body with the three-line `docker build` / `docker push` sequence from that task instead.

- [ ] **Step 2: Verify the variables resolve**

```bash
make -n image
```

Expected: the echoed command shows the real project ID and region, with no empty path segments such as `//`.

- [ ] **Step 3: Commit**

```bash
git add Makefile
git commit -m "feat: Makefile wrapping the deployment workflow"
```

---

### Task 16: README

The README is half the deliverable. `assignment.txt` asks for step-by-step deployment instructions **and** an architectural explanation covering state and storage, session management, networking and security.

**Files:**
- Modify: `README.md` (currently one line)

**Interfaces:**
- Consumes: everything. Rationale comes from `docs/decisions.md` — link to it for the deferred items rather than restating them.

- [ ] **Step 1: Write the deployment half**

Sections, in order:

1. **What this is** — one paragraph, plus the architecture diagram below.
2. **Prerequisites** — `gcloud`, `terraform >= 1.5`, `docker`, `openssl`, `hey`; a GCP project with billing enabled; `gcloud auth login` and `gcloud auth application-default login`.
3. **Configure** — set `project_id` in `terraform/project.tfvars`.
4. **Deploy** — `make bootstrap` → `make image` → `make cert` → `make infra` → `make seed`, with the expected duration of each and what to check after it.
5. **Verify** — the `curl -k` checks from Task 12 Step 4 and Task 13 Steps 3–5.
6. **Demonstrate autoscaling** — `make load-test`, with the sample output from Task 14.
7. **Tear down** — `make destroy`, plus the manual certificate deletion.

Include this diagram:

```
                          Internet
                             |
              +--------------+--------------+
              |   Global external HTTPS LB  |   :80 -> 301 -> :443
              |   self-signed certificate   |
              +------+---------------+------+
                     |               |
      /wp-content/uploads/*      everything else
                     |               |
          +----------v-----+   +-----v---------------------+
          | Backend bucket |   | Backend service           |
          | + Cloud CDN    |   | regional MIG, 2-5 x       |
          +----------+-----+   | e2-medium, autoscale @60% |
                     |         +-----+---------------------+
                     |               |  each instance:
                     |               |    docker: wordpress (php:7.4-apache)
                     |               |    docker: cloud-sql-proxy -> 127.0.0.1:3306
                     |               |    gcsfuse -> /var/www/html/wp-content/uploads
                     |               |
          +----------v---------------v------+
          |  GCS bucket   |   Cloud SQL     |
          |  wp-media     |   MySQL 8.0     |
          |               |   private IP    |
          |               |   primary + read replica
          +---------------+-----------------+
```

- [ ] **Step 2: Write the architecture half**

Four sections, each answering the assignment's question directly:

**State and storage.** Three kinds of state, three destinations. *Code* is baked into the image, so an instance's disk is disposable. *Relational data* lives in Cloud SQL; the Auth Proxy runs beside WordPress on the host network so the frozen `DB_HOST='localhost'` is literally true and no PHP was edited. *Uploaded media* lives in a GCS bucket, mounted at `wp-content/uploads` by gcsfuse — writes from wp-admin land in the bucket, reads bypass the instances entirely via the CDN-backed backend bucket. Nothing an instance holds is unique to it, which is what makes autohealing and scale-in safe.

**Session management.** WordPress 4.9.4 keeps no server-side sessions. Authentication is a cookie signed with the salts in `wp-config.php`, and because those salts are supplied and identical on every instance, any instance can validate a cookie any other issued. This was verified by searching WordPress core, the three active plugins (meow-gallery, meow-lightbox, wp-smushit) and the `lucienne` theme for `session_start()` and `$_SESSION` — there are none. **So no session affinity is configured, and none is needed.** The load balancer is free to send consecutive requests from one user to different instances.

**Networking.** A custom VPC with one subnet. Instances have no external IP: inbound reaches them only from the load balancer's ranges on port 80, outbound goes through Cloud NAT. Cloud SQL has no public IP either; it is reachable over a service networking peering. Administrative SSH arrives only through IAP, so access is granted by IAM rather than by owning an IP address. Both firewall source ranges come from the `google_netblock_ip_ranges` data source rather than hardcoded CIDRs.

**Security.** Least privilege: the instances run as a dedicated service account holding `cloudsql.client`, `artifactregistry.reader` and `logging.logWriter`, plus `storage.objectAdmin` scoped to the one bucket — not the project's default Editor account. TLS terminates at the load balancer and port 80 only redirects.

- [ ] **Step 3: Write the honest-limitations section**

State these plainly. They are deliberate trade-offs, and naming them is worth more than hiding them:

- **The certificate is self-signed**, as the assignment specifies, so browsers show `ERR_CERT_AUTHORITY_INVALID` and `curl` needs `-k`. In production this would be a Google-managed certificate on a real domain.
- **The media bucket is publicly readable and enumerable.** The backend bucket fetches objects anonymously, so `roles/storage.objectViewer` for `allUsers` is required; that role also permits listing. Acceptable because the bucket holds only media already published on a public site. `docs/decisions.md` §1 covers the alternatives and the preferred tightening.
- **The database password is hardcoded** in the supplied `wp-config.php`, which may not be modified. Secret Manager would be theatre while the credential sits in a committed file. The compensating controls are real: no public IP on the instance, and the proxy requires `roles/cloudsql.client`. **Rotating this credential would be the first action in a real engagement.**
- **Terraform state is local.** `docs/decisions.md` §2 explains why that is defensible here and gives the exact migration to a GCS backend.
- **The supplied files are unmodified.** `html/**` and `wordpress.sql` are byte-for-byte as delivered; they were only moved into `app/` and `data/`.

- [ ] **Step 4: Write the "what I would do next" section**

Summarise from `docs/decisions.md`, one line each, linking to it for detail: GCS remote backend; move the certificate and the image build into Terraform once state is remote; CI via GitHub Actions with Workload Identity Federation; Packer-baked images to cut boot time; Memorystore for object caching; rotate the database credential.

- [ ] **Step 5: Check every command in the README actually runs**

```bash
grep -oE '^\s*(make|gcloud|terraform|curl|scripts/)[^\n]*' README.md | sed 's/^\s*//' | sort -u
```

Read the list and confirm each one appeared in a task above and was executed. Any command in the README that was never run is a defect.

- [ ] **Step 6: Commit**

```bash
git add README.md
git commit -m "docs: deployment guide and architecture write-up"
```

---

## Self-review

**1. Spec coverage** — every requirement in `assignment.txt` mapped to a task:

| Requirement | Task |
|---|---|
| Custom VPC, subnets, firewall rules | 5 |
| MIG autoscaling 2 → 5 on CPU | 9, demonstrated in 14 |
| Cloud SQL primary + read replica, WordPress on primary | 8 |
| Global HTTP(S) LB with self-signed certificate | 10, 11 |
| `e2-medium` instances | 9 (`var.machine_type`) |
| Shared-core Cloud SQL tier | 8 (`var.db_tier` = `db-g1-small`) |
| No Marketplace / Bitnami | 2 (image built from `php:7.4-apache`) |
| User-uploaded media across ephemeral servers | 7, 9 (gcsfuse), 11 (backend bucket), 13 |
| Session management across ephemeral servers | 16 — no affinity needed; verified, not assumed |
| Least-privilege IAM | 6, 7 |
| Backends not directly public | 5 (no external IP, IAP-only SSH), 8 (private IP) |
| Cost optimisation | shared-core SQL, `e2-medium`, min 2, CDN offload, `make destroy` |
| Deployment scripts | 10, 13, 14, 15 |
| README: steps + state/storage + sessions + networking + security | 16 |

No gaps.

**2. Placeholder scan** — every code block is complete and runnable. The two conditional branches (Task 4 Step 2's local build, Task 12 Step 5's metadata-server token) give full working code rather than describing a fix, and both name the exact symptom that selects them. The only intentional placeholder is `REPLACE_WITH_YOUR_PROJECT_ID` in `terraform/project.tfvars`, which is a user input by definition.

**3. Type consistency** — checked across tasks:

- `local.image` is defined in Task 5 (`locals.tf`), consumed in Task 9. The string it builds matches the `--tag` in Task 4 exactly: `${region}-docker.pkg.dev/${project_id}/wordpress/wordpress:v1`.
- `google_compute_health_check.http` is defined in Task 9 and reused in Task 11 — one health check, both purposes, one name.
- The MIG's `named_port` is `http`, and the backend service's `port_name` is `http`. They must match, and do.
- Output names are defined in Task 11 and consumed verbatim in Tasks 13 and 14: `media_bucket`, `lb_ip`, `mig_name`, `region`.
- `var.ssl_certificate_name` defaults to `wordpress-selfsigned` (Task 5), which is the name `scripts/cert.sh` creates (Task 10) and the `data` block reads (Task 11).
- `var.repository_id` defaults to `wordpress`, matching `repository_id` in the bootstrap stack (Task 3).
- The gcsfuse `--uid 33 --gid 33` matches `www-data` in `php:7.4-apache`, and the mount path `/mnt/uploads` matches the bind mount in the same script.
- Bucket object layout (`wp-content/uploads/...`, set by `seed.sh`) matches both the gcsfuse `--only-dir wp-content/uploads` prefix and the URL map's `/wp-content/uploads/*` path rule.
