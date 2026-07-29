data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance_template" "wordpress" {
  name_prefix  = "wp-"
  machine_type = var.machine_type
  tags         = ["wordpress"]

  metadata = {
    enable-oslogin = "TRUE"
  }

  # The compose file is rendered first and embedded whole, so the two templates
  # stay separate files instead of one shell script quoting YAML.
  metadata_startup_script = templatefile("${path.module}/startup.sh.tftpl", {
    artifact_registry_host = local.artifact_registry_host
    uploads_bucket_name    = google_storage_bucket.uploads.name

    compose_file = templatefile("${path.module}/compose.yaml.tftpl", {
      sql_connection_name = google_sql_database_instance.wordpress.connection_name
      wordpress_image     = local.wordpress_image
    })
  })

  disk {
    auto_delete  = true
    boot         = true
    disk_size_gb = 20
    disk_type    = "pd-balanced"
    source_image = data.google_compute_image.ubuntu.self_link
  }

  network_interface {
    subnetwork = google_compute_subnetwork.wordpress.id
    # Deliberately no access_config block: instances receive no external IP.
  }

  service_account {
    email  = google_service_account.wordpress.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "wordpress" {
  # Boot must not race the bucket permission or the prefix marker that GCS FUSE
  # needs before the supplied uploads are seeded. This group, not the template,
  # is what creates the instances that mount the bucket.
  depends_on = [
    google_storage_bucket_iam_member.wordpress_uploads_writer,
    google_storage_bucket_object.uploads_prefix,
  ]

  name               = "wp-mig"
  base_instance_name = "wp"
  region             = local.region

  version {
    instance_template = google_compute_instance_template.wordpress.id
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.wordpress.id
    initial_delay_sec = local.instance_warmup_seconds
  }
}

resource "google_compute_region_autoscaler" "wordpress" {
  name   = "wp-autoscaler"
  region = local.region
  target = google_compute_region_instance_group_manager.wordpress.id

  autoscaling_policy {
    min_replicas    = 2
    max_replicas    = 5
    cooldown_period = local.instance_warmup_seconds

    cpu_utilization {
      target = 0.6
    }
  }
}
