output "assets_uri" {
  description = "Cloud Storage URI of the private bucket that make seed stages the rewrite in."
  value       = "gs://${google_storage_bucket.assets.name}"
}

output "database_dump_uri" {
  description = "Cloud Storage URI of the supplied dump that make seed imports."
  value       = "gs://${google_storage_bucket.assets.name}/${google_storage_bucket_object.database_dump.name}"
}

output "instance_group_name" {
  description = "Regional managed instance group containing the WordPress server."
  value       = google_compute_region_instance_group_manager.wordpress.name
}

output "project_id" {
  description = "GCP project inherited from the bootstrap stack."
  value       = local.project_id
}

output "region" {
  description = "GCP region inherited from the bootstrap stack."
  value       = local.region
}

output "sql_instance_name" {
  description = "Cloud SQL instance that make seed imports into."
  value       = google_sql_database_instance.wordpress.name
}

output "uploads_uri" {
  description = "Cloud Storage URI whose prefix matches the public WordPress uploads path."
  value       = "gs://${google_storage_bucket.uploads.name}/wp-content/uploads"
}

output "wordpress_url" {
  description = "Public HTTPS URL of the migrated WordPress site."
  value       = "https://${google_compute_global_address.wordpress.address}"
}
