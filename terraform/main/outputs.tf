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

output "service_account_email" {
  description = "Dedicated identity attached to the WordPress server."
  value       = google_service_account.wordpress.email
}

output "sql_connection_name" {
  description = "Cloud SQL connection name used by the Auth Proxy."
  value       = google_sql_database_instance.wordpress.connection_name
}

output "sql_instance_name" {
  description = "Cloud SQL instance that make seed imports into."
  value       = google_sql_database_instance.wordpress.name
}
