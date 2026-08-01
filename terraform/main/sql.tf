resource "google_sql_database_instance" "wordpress" {
  name             = "wp-primary"
  database_version = "MYSQL_8_0"
  region           = local.region

  depends_on = [google_service_networking_connection.cloud_sql]

  deletion_protection = false

  settings {
    availability_type = "ZONAL"
    tier              = var.database_tier

    backup_configuration {
      binary_log_enabled = true
      enabled            = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.wordpress.id
      # WordPress talks to the private IP directly, so the instance itself has
      # to reject cleartext; nothing else terminates TLS on that path.
      ssl_mode = "ENCRYPTED_ONLY"
    }
  }
}

resource "google_sql_database_instance" "wordpress_replica" {
  name                 = "wp-replica"
  database_version     = "MYSQL_8_0"
  master_instance_name = google_sql_database_instance.wordpress.name
  region               = local.region

  deletion_protection = false

  settings {
    availability_type = "ZONAL"
    tier              = var.database_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.wordpress.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }
  }
}

resource "google_sql_database" "wordpress" {
  name      = "wordpress"
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
  instance  = google_sql_database_instance.wordpress.name
}

resource "google_sql_user" "wordpress" {
  name     = "wordpress"
  host     = "%"
  instance = google_sql_database_instance.wordpress.name
  password = var.database_password
}
