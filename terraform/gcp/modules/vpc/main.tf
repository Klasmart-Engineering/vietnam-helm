
resource "google_compute_network" "vpc" {
  name                    = "kl-network"
  project                 = var.project
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL"
}


resource "google_compute_router" "vpc_router" {
  name = "kl-router"
  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link
}


resource "google_compute_subnetwork" "vpc_subnet" {
  name    = "kl-public"
  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link
  ip_cidr_range = "10.0.0.0/16"
  private_ip_google_access   = true
  #private_ipv6_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}


resource "google_compute_router_nat" "vpc_nat" {
  name = "kl-nat"
  project = var.project
  region  = var.region
  router  = google_compute_router.vpc_router.name
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.vpc_subnet.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  log_config {
    enable = true
    filter = "ALL"
  }
}


resource "google_compute_firewall" "gke_public" {
  name          = "kl-gke-public"
  project       = var.project
  network       = google_compute_network.vpc.self_link
  target_tags   = ["gke-public"]
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  priority      = "1000"

  allow {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}








