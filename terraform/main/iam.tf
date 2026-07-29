# The instances use a dedicated identity instead of the project's broad
# default Compute Engine service account.
resource "google_service_account" "wordpress" {
  account_id   = "wordpress-vm"
  display_name = "WordPress instances"
}

# Docker pulls the image, the proxy authenticates to Cloud SQL, and the Ops
# Agent ships logs. Nothing else on the VM needs a project role.
resource "google_project_iam_member" "wordpress" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/cloudsql.client",
    "roles/logging.logWriter",
  ])

  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.wordpress.email}"
}
