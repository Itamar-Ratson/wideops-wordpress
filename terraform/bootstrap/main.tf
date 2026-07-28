locals {
  # APIs used by this stack and by the main infrastructure stack.
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
}

resource "google_project_service" "enabled" {
  for_each = toset(local.apis)

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

resource "terraform_data" "region_availability" {
  depends_on = [google_project_service.enabled]

  triggers_replace = [var.project_id, var.region]

  provisioner "local-exec" {
    command = "${path.module}/../../scripts/check-region.sh"
  }
}

data "google_project" "current" {
  project_id = var.project_id

  depends_on = [terraform_data.region_availability]
}

resource "google_artifact_registry_repository" "wordpress" {
  project       = var.project_id
  location      = var.region
  repository_id = "wordpress"
  description   = "WordPress application image"
  format        = "DOCKER"

  depends_on = [terraform_data.region_availability]
}

# New projects use the Compute Engine default service account for Cloud Build.
# It needs both permissions explicitly: one for the image and one for its logs.
resource "google_project_iam_member" "build_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "build_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}
