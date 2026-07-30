resource "tls_private_key" "wordpress" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "wordpress" {
  private_key_pem       = tls_private_key.wordpress.private_key_pem
  validity_period_hours = 24 * 365
  early_renewal_hours   = 24 * 30
  dns_names             = [local.certificate_hostname]
  allowed_uses          = ["digital_signature", "key_encipherment", "server_auth"]

  subject {
    common_name = local.certificate_hostname
  }
}

resource "google_compute_ssl_certificate" "wordpress" {
  name_prefix = "wp-self-signed-"
  certificate = tls_self_signed_cert.wordpress.cert_pem
  private_key = tls_private_key.wordpress.private_key_pem

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_global_address" "wordpress" {
  name = "wp-public-ip"
}

# Keep this TCP-only: probing PHP would turn a database outage into VM churn.
resource "google_compute_health_check" "wordpress" {
  name                = "wp-tcp-health"
  check_interval_sec  = 5
  healthy_threshold   = 2
  timeout_sec         = 5
  unhealthy_threshold = 2

  tcp_health_check {
    port = 80
  }
}

resource "google_compute_backend_service" "wordpress" {
  name                  = "wp-backend"
  health_checks         = [google_compute_health_check.wordpress.id]
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 30

  backend {
    group = google_compute_region_instance_group_manager.wordpress.instance_group
  }
}

resource "google_compute_backend_bucket" "uploads" {
  name        = "wp-uploads-backend"
  bucket_name = google_storage_bucket.uploads.name
  enable_cdn  = true
}

resource "google_compute_url_map" "wordpress" {
  name            = "wp-url-map"
  default_service = google_compute_backend_service.wordpress.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "wordpress"
  }

  path_matcher {
    name            = "wordpress"
    default_service = google_compute_backend_service.wordpress.id

    path_rule {
      paths   = ["/wp-content/uploads/*"]
      service = google_compute_backend_bucket.uploads.id
    }
  }
}

resource "google_compute_target_https_proxy" "wordpress" {
  name             = "wp-https-proxy"
  ssl_certificates = [google_compute_ssl_certificate.wordpress.id]
  url_map          = google_compute_url_map.wordpress.id
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "wp-https"
  ip_address            = google_compute_global_address.wordpress.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.wordpress.id
}

resource "google_compute_url_map" "http_redirect" {
  name = "wp-http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "http_redirect" {
  name    = "wp-http-redirect-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "wp-http"
  ip_address            = google_compute_global_address.wordpress.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.http_redirect.id
}
