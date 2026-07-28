# Design decisions & future improvements

Running record of choices that need to survive into the README, and of things
deliberately deferred. Add to this rather than relying on memory.

---

## 1. Media bucket IAM — `objectViewer` for `allUsers`

**Decision:** grant `roles/storage.objectViewer` to `allUsers` on the media bucket.

**Why it must be public at all:** uploads are served through a Cloud CDN–backed
*backend bucket* on the load balancer. The LB fetches objects anonymously, so
they have to be publicly readable. The alternatives both require modifying
WordPress, which is out of scope:

- Cloud CDN signed URLs — WordPress would have to generate them.
- A private bucket — means dropping the backend bucket and serving uploads from
  the VMs through gcsfuse, which puts FUSE back on the read path (exactly what
  the current design avoids).

**Consequence to state honestly in the README:**

> The media bucket grants `roles/storage.objectViewer` to `allUsers`. This also
> permits `storage.objects.list`, so the bucket can be enumerated. That is
> acceptable here because it holds nothing but the media already displayed on a
> public website.

**If we ever want to tighten it:** the goal is get-without-list.

- `roles/storage.legacyObjectReader` grants only `storage.objects.get` and does
  exactly this. Rejected on naming — we avoid `legacy*` roles by default, even
  though this one is not on a deprecation path ("legacy" refers to it mapping
  onto the pre-IAM ACL model).
- **Preferred tightening:** a custom role granting only `storage.objects.get`
  (~8 lines of Terraform). Same effect, no legacy naming, and it reads as a
  deliberate least-privilege choice.

Not doing this now — `objectViewer` stays.

---

## 2. Terraform state — local now, GCS backend later

**Decision:** local state, gitignored.

**Why that is defensible here:**

- The self-signed certificate is generated with `openssl` and uploaded with
  `gcloud`, so **the private key never enters Terraform state**.
- The only credential in state is the database password `Foxtrot01`, which is
  already committed in the supplied `wp-config.php`.
- A GCS backend needs a bucket that the config using it cannot create, so it
  adds a bootstrap step to an otherwise linear README.

**Future improvement — migrating to a GCS backend:**

1. Add the state bucket to `terraform/bootstrap/` (versioning enabled, uniform
   bucket-level access, public access prevention, lifecycle rule capping
   noncurrent versions). Bootstrap keeps local state permanently — the stack
   that creates the bucket cannot store its state in it.
2. Add the backend block to `terraform/main/terraform.tf`:

   ```hcl
   terraform {
     backend "gcs" {
       bucket = "PROJECT-tfstate"
       prefix = "main"
     }
   }
   ```

3. Run `terraform init -migrate-state`. Terraform detects the backend change and
   offers to copy the existing state up. **No resource is touched** — it is a
   file move, not a plan. The local copy is retained as
   `terraform.tfstate.backup`.

---

## 3. Moving `gcloud` / `openssl` steps into Terraform

Two steps run outside Terraform today. Both were deliberate, both could move in,
and one of them is blocked on item 2 above.

**Self-signed certificate** — currently `openssl req -x509` plus
`gcloud compute ssl-certificates create`, with Terraform referencing the result
through a `data "google_compute_ssl_certificate"` block.

Moving it in means `tls_private_key` + `tls_self_signed_cert` feeding
`google_compute_ssl_certificate`, so the whole stack comes up from one
`terraform apply`. The catch is the reason we did not do it: **anything
Terraform generates lands in state**, so this move puts a private key there.
`tls_private_key` marks it sensitive and redacts it from plan output, but the
state file holds it in plaintext.

> **Do item 2 (GCS remote backend) first.** Only once state lives in a versioned
> bucket with restricted IAM is it honest to put a private key in it.

Note this also changes the certificate's lifecycle: today `terraform destroy`
leaves it behind and it needs manual cleanup; managed by Terraform it would be
destroyed with everything else.

**Image build and push** — currently `gcloud builds submit app/`.

Moving it in means the `kreuzwerker/docker` provider, following the pattern in
the `wideops-prep` repo's `terraform/main/image.tf`:

```hcl
resource "docker_image"          "wordpress" { build { context = local.app_context } ... }
resource "docker_registry_image" "wordpress" { name = docker_image.wordpress.name ... }
```

with a `source_hash` trigger computed from `fileset` + `filesha256` over `app/`.
The real benefit is ordering: because the instance template references the image
resource, Terraform's dependency graph builds and pushes *before* the MIG
consumes it — no two-phase apply, no chance of instances booting against an
image that does not exist yet.

Rejected for now because the payoff does not apply here. The `source_hash`
machinery exists to rebuild when application source changes; our source is
supplied WordPress files that never change, and the image gets built perhaps
three times total. Against that: a second provider, a local Docker daemon
requirement, and ~10 lines of `setsubtract` / `filesha256` locals.

**Not moving in:** `scripts/seed.sh`. Importing `wordpress.sql`, running the
search-replace, and rsyncing uploads into the bucket are data migration, not
infrastructure. Terraform manages resource state, not table contents — wrapping
these in `null_resource` / `local-exec` would make them invisible to `plan` and
non-idempotent. They stay a script.

---

## Other deferred items (for the README's closing section)

- **CI/CD:** image builds via GitHub Actions authenticating with Workload
  Identity Federation — keyless, no service account JSON in CI. `terraform plan`
  on pull request, `apply` on merge.
- **Packer-baked images:** pre-install Docker and gcsfuse so scale-out skips
  `apt-get` and the image pull, cutting boot time by 1–2 minutes.
- **Object caching:** Memorystore for Redis plus an object-cache drop-in.
  Rejected for now — not required, ~$36/mo, needs a plugin, and it suppresses
  the CPU signal the autoscaler demo depends on.
- **Rotate the database credential:** `Foxtrot01` is hardcoded in the supplied
  `wp-config.php`, which we are not permitted to modify. First action in a real
  engagement would be rotating it and moving it to Secret Manager.
