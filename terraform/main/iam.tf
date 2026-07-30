# The instances use a dedicated identity instead of the project's broad
# default Compute Engine service account.
resource "google_service_account" "wordpress" {
  account_id   = "wordpress-vm"
  display_name = "WordPress instances"
}

# Docker pulls the image and the proxy authenticates to Cloud SQL. Nothing else
# on the VM needs a project role.
resource "google_project_iam_member" "wordpress" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/cloudsql.client",
  ])

  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.wordpress.email}"
}
