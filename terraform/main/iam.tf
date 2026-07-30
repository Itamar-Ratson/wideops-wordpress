resource "google_service_account" "wordpress" {
  account_id   = "wordpress-vm"
  display_name = "WordPress instances"
}

resource "google_project_iam_member" "wordpress" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/cloudsql.client",
  ])

  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.wordpress.email}"
}
