# Cloud SQL imports are performed by the service's control plane, which reads
# the object directly from Cloud Storage. That path does not touch the VPC, so
# it works against the private-only instance without a bastion or a proxy.
resource "google_storage_bucket" "assets" {
  name                        = "${local.project_id}-assets"
  location                    = local.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  # The bucket holds only re-uploadable seed data in this slice, so a teardown
  # should not need the objects cleared by hand first.
  force_destroy = true
}

resource "google_storage_bucket_object" "database_dump" {
  name   = "seed/wordpress.sql"
  bucket = google_storage_bucket.assets.name
  source = "${path.module}/../../data/wordpress.sql"
}

# Cloud SQL mints this identity with the instance and replaces it if the
# instance is recreated, so the grant belongs to the instance, not to a
# long-lived account.
resource "google_storage_bucket_iam_member" "sql_import_reader" {
  bucket = google_storage_bucket.assets.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_sql_database_instance.wordpress.service_account_email_address}"
}

# Uploads live separately from the private database seed data because the load
# balancer's backend bucket reads objects anonymously. Keeping this bucket
# media-only makes that public access boundary explicit. Prevention is inherited
# rather than enforced because the allUsers grant below is the point of this
# bucket.
resource "google_storage_bucket" "uploads" {
  name                        = "${local.project_id}-uploads"
  location                    = local.region
  uniform_bucket_level_access = true
  public_access_prevention    = "inherited"

  # Media here is re-uploadable from the supplied tree in this slice, so
  # teardown should not need objects cleared by hand first.
  force_destroy = true
}

# GCS FUSE mounts only this prefix. The marker makes the prefix available on a
# first boot before `make seed` has copied the supplied media into the bucket.
# The content is non-empty because the provider rejects an empty string as an
# unset argument, and it is world-readable like everything else in this bucket.
resource "google_storage_bucket_object" "uploads_prefix" {
  name    = "wp-content/uploads/.keep"
  bucket  = google_storage_bucket.uploads.name
  content = "Marks the uploads prefix for the GCS FUSE mount.\n"
}

# Backend buckets fetch objects anonymously. objectViewer is intentionally
# used instead of a legacy-prefixed role; its list permission means this
# media-only bucket is public and enumerable, as documented in the README.
resource "google_storage_bucket_iam_member" "public_uploads_reader" {
  bucket = google_storage_bucket.uploads.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# WordPress instances can manage objects in this bucket and nowhere else in
# Cloud Storage. objectUser permits thumbnail updates and media deletion as
# well as creation, while the bucket-level grant keeps the scope narrow.
resource "google_storage_bucket_iam_member" "wordpress_uploads_writer" {
  bucket = google_storage_bucket.uploads.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.wordpress.email}"
}
