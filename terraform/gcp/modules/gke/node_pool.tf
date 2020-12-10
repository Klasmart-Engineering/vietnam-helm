resource "google_container_node_pool" "primary" {
  provider = google-beta
  cluster  = google_container_cluster.cluster.name
  name     = "kidsloop"
  location = var.region
  project  = var.project
  
  initial_node_count = "1"
   autoscaling {
    min_node_count = "1"
    max_node_count = "5"
  }
  
  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  node_config {
    image_type   = "COS"
    machine_type = "n1-standard-1"
    preemptible  = false # Don't want nodes failing during calls particularly
    disk_size_gb = 20
    disk_type    = "pd-standard"
    service_account = google_service_account.cluster.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = [
      "gke-public",
    ]
    
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }
}

