# API list and build identity
locals {
  apis = [
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
  ]

  build_service_account = "${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}

# API enablement
resource "google_project_service" "enabled" {
  for_each = toset(local.apis)

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

data "google_project" "current" {
  project_id = var.project_id

  depends_on = [google_project_service.enabled]
}

# Image repository
resource "google_artifact_registry_repository" "wordpress" {
  project       = var.project_id
  location      = var.region
  repository_id = "wordpress"
  description   = "WordPress application image"
  format        = "DOCKER"

  depends_on = [google_project_service.enabled]
}

# Cloud Build permissions
resource "google_project_iam_member" "build_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${local.build_service_account}"
}

resource "google_project_iam_member" "build_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${local.build_service_account}"
}
