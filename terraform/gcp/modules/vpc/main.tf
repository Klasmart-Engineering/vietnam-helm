
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  project                 = var.project
  auto_create_subnetworks = "false"       # We don't want global subnetworks
  routing_mode            = "REGIONAL"    # Only want regional routing for GKE
}


resource "google_compute_router" "vpc" {
  name    = var.network_name    # Give everything the network name for clarity
  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link
}


resource "google_compute_subnetwork" "vpc" {
  name          = var.network_name
  project       = var.project
  region        = var.region
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.vpc.self_link
  private_ip_google_access = true # We must have private google access, don't want to traverse public internet
  log_config {
    aggregation_interval = var.flowlogs_interval
    flow_sampling        = var.flowlogs_sampling
    metadata             = "INCLUDE_ALL_METADATA" # Yes, all metadata
  }
}


resource "google_compute_router_nat" "vpc" {
  name    = var.network_name
  project = var.project
  region  = var.region
  router  = google_compute_router.vpc.name
  nat_ip_allocate_option = "AUTO_ONLY" # Can we be bothered? No - let GCP allocate NAT IPs
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS" # Allow our subnet to access the NAT
  subnetwork {
    name                    = google_compute_subnetwork.vpc.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"] # We'll allow all IP ranges, in case we add secondary IP range to the subnet and forget
  }
  log_config {
    enable = true
    filter = "ALL"  # We want all logs (for everything) for now - could reduce this to errors later when the system is more stable.
  }
}


resource "google_compute_firewall" "vpc" {
  name          = var.network_name
  project       = var.project
  network       = google_compute_network.vpc.self_link
  target_tags   = ["gke-public"]
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"] # Allow from all - don't know where traffic wil be coming from
  priority      = "1000"
  allow {
    protocol = "all"  # TODO Must restrict to essential access (e.g. SFU) to GKE later
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA" # We want all logs (for everything) for now 
  }
}


# Create VPC peering range for private connectivity to GCP services
resource "google_compute_global_address" "vpc" {
  name          = var.network_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.vpc_peering_range_size
  project       = var.project
  network       = google_compute_network.vpc.self_link
}


# Assign range for service networking (https://cloud.google.com/service-infrastructure/docs/service-networking/getting-started)
resource "google_service_networking_connection" "vpc" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.vpc.name]
}
