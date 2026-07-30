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

  # Shared by autohealing and autoscaling; shorter values misclassify boot time
  # as either an unhealthy instance or visitor-driven CPU load.
  instance_warmup_seconds = 600

  certificate_hostname = "wideops-wordpress.invalid"

  artifact_registry_host = "${local.region}-docker.pkg.dev"
  wordpress_image        = "${local.artifact_registry_host}/${local.project_id}/${local.repository_id}/wordpress:${var.image_tag}"
}
