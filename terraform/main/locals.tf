data "terraform_remote_state" "bootstrap" {
  backend = "local"

  config = {
    path = "${path.module}/../bootstrap/terraform.tfstate"
  }
}

locals {
  project_id    = data.terraform_remote_state.bootstrap.outputs.project_id
  region        = data.terraform_remote_state.bootstrap.outputs.region
  repository_id = data.terraform_remote_state.bootstrap.outputs.repository_id

  artifact_registry_host = "${local.region}-docker.pkg.dev"
  wordpress_image        = "${local.artifact_registry_host}/${local.project_id}/${local.repository_id}/wordpress:${var.image_tag}"
}
