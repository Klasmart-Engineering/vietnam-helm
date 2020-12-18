output "vpc" {
  value = google_compute_network.vpc.self_link
}

output "subnet" {
  value = google_compute_subnetwork.vpc.self_link
}