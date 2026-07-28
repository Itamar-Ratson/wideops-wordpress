output "build_service_account" {
  description = "Service account used by Cloud Build in this project."
  value       = local.build_service_account
}

output "project_number" {
  description = "Numeric project ID used in default service-account names."
  value       = data.google_project.current.number
}

output "repository_id" {
  description = "Artifact Registry repository that holds the WordPress image."
  value       = google_artifact_registry_repository.wordpress.repository_id
}
