resource "google_compute_network" "network" {
  name                            = "kl-network"
  auto_create_subnetworks         = "false"
  routing_mode                    = "REGIONAL"
}

resource "google_compute_subnetwork" "subnetwork" {
  network       = google_compute_network.network.id
  name          = "kl-subnetwork"
  region        = var.gcp_region
  ip_cidr_range = "10.0.0.0/16"
  private_ip_google_access = true
}