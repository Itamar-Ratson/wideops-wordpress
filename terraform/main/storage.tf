# Private bucket for seed data
resource "google_storage_bucket" "assets" {
  name                        = "${local.project_id}-assets"
  location                    = local.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  force_destroy = true
}

resource "google_storage_bucket_object" "database_dump" {
  name   = "seed/wordpress.sql"
  bucket = google_storage_bucket.assets.name
  source = "${path.module}/../../data/wordpress.sql"
}

resource "google_storage_bucket_object" "url_rewrite" {
  name   = "seed/rewrite-urls.sql"
  bucket = google_storage_bucket.assets.name
  source = "${path.module}/../../data/rewrite-urls.sql"
}

resource "google_storage_bucket_iam_member" "sql_import_reader" {
  bucket = google_storage_bucket.assets.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_sql_database_instance.wordpress.service_account_email_address}"
}

# Public bucket for uploads
resource "google_storage_bucket" "uploads" {
  name                        = "${local.project_id}-uploads"
  location                    = local.region
  uniform_bucket_level_access = true
  public_access_prevention    = "inherited"

  force_destroy = true
}

# Keep this marker: GCS FUSE must mount the prefix before uploads are seeded.
resource "google_storage_bucket_object" "uploads_prefix" {
  name    = "wp-content/uploads/.keep"
  bucket  = google_storage_bucket.uploads.name
  content = "Marks the uploads prefix for the GCS FUSE mount.\n"
}

resource "google_storage_bucket_iam_member" "public_uploads_reader" {
  bucket = google_storage_bucket.uploads.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "wordpress_uploads_writer" {
  bucket = google_storage_bucket.uploads.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.wordpress.email}"
}
