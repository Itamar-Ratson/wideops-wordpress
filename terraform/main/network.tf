data "google_netblock_ip_ranges" "health_checkers" {
  range_type = "health-checkers"
}

data "google_netblock_ip_ranges" "iap" {
  range_type = "iap-forwarders"
}

resource "google_compute_network" "wordpress" {
  name                    = "wp-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "wordpress" {
  name                     = "wp-subnet"
  ip_cidr_range            = var.subnet_cidr
  network                  = google_compute_network.wordpress.id
  private_ip_google_access = true
  region                   = local.region
}

resource "google_compute_router" "wordpress" {
  name    = "wp-router"
  network = google_compute_network.wordpress.id
  region  = local.region
}

resource "google_compute_router_nat" "wordpress" {
  name                               = "wp-nat"
  nat_ip_allocate_option             = "AUTO_ONLY"
  region                             = local.region
  router                             = google_compute_router.wordpress.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Reserved now for the load balancer introduced in issue #6. Until then there
# is no public frontend capable of sending traffic from these ranges.
resource "google_compute_firewall" "allow_load_balancer" {
  name    = "wp-allow-lb"
  network = google_compute_network.wordpress.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = data.google_netblock_ip_ranges.health_checkers.cidr_blocks_ipv4
  target_tags   = ["wordpress"]
}

resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "wp-allow-iap-ssh"
  network = google_compute_network.wordpress.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = data.google_netblock_ip_ranges.iap.cidr_blocks_ipv4
  target_tags   = ["wordpress"]
}

resource "google_compute_global_address" "cloud_sql" {
  name          = "wp-sql-private-range"
  address_type  = "INTERNAL"
  network       = google_compute_network.wordpress.id
  prefix_length = 16
  purpose       = "VPC_PEERING"
}

resource "google_service_networking_connection" "cloud_sql" {
  network                 = google_compute_network.wordpress.id
  reserved_peering_ranges = [google_compute_global_address.cloud_sql.name]
  service                 = "servicenetworking.googleapis.com"
}
