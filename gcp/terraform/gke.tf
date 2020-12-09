resource "google_container_cluster" "primary" {
    name                     = "kidsloop"
    description              = "Kubernetes cluster for KidsLoop deployment"
    location                 = var.gcp_region
    
    enable_shielded_nodes = true
    network               = google_compute_network.network.name
    subnetwork            = google_compute_subnetwork.subnetwork.name
    logging_service       = "logging.googleapis.com/kubernetes"
    monitoring_service    = "monitoring.googleapis.com/kubernetes" 

    maintenance_policy {
      daily_maintenance_window {
        start_time = "03:00"
      }
    }

    master_auth {
      client_certificate_config {
        issue_client_certificate = true
      }
    }

    release_channel {
      channel = "STABLE"
    }

    # Must be set and then deleted for some reason
    initial_node_count       = 1
    remove_default_node_pool = true
}

       
resource "google_container_node_pool" "primary" {
  cluster    = google_container_cluster.primary.name
  name       = "kidsloop"
  location   = var.gcp_region
  node_count = 1
  
  node_config {
    disk_size_gb = 80
    disk_type    = "pd-standard"
    machine_type = "e2-standard-4"
    preemptible  = false # Don't want nodes failing during calls particularly

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}