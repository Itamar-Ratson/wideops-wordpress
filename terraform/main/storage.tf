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
