data "google_compute_ssl_certificate" "wordpress" {
  name = "wp-self-signed"
}

resource "google_compute_global_address" "wordpress" {
  name = "wp-public-ip"
}

# A TCP probe proves that Apache is accepting connections without executing
# PHP or coupling every server's health to the shared database.
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

resource "google_compute_url_map" "wordpress" {
  name            = "wp-url-map"
  default_service = google_compute_backend_service.wordpress.id
}

resource "google_compute_target_https_proxy" "wordpress" {
  name             = "wp-https-proxy"
  ssl_certificates = [data.google_compute_ssl_certificate.wordpress.id]
  url_map          = google_compute_url_map.wordpress.id
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "wp-https"
  ip_address            = google_compute_global_address.wordpress.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.wordpress.id
}

# Port 80 has its own URL map and can only issue a permanent HTTPS redirect;
# it has no backend service from which it could serve unencrypted content.
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
