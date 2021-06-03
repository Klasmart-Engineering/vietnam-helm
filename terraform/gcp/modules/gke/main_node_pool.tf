resource "google_container_node_pool" "primary" {
  provider = google-beta
  cluster  = google_container_cluster.cluster.name
  name     = var.cluster_name
  location = var.region
  project  = var.project
  
  initial_node_count = var.node_count_initial
  autoscaling {
    min_node_count = var.node_count_min
    max_node_count = var.node_count_max
  }
  
  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  node_config {
    image_type   = "COS" 
    machine_type = var.node_type
    preemptible  = false # Don't want nodes failing during calls particularly
    disk_size_gb = var.node_disk_size
    disk_type    = var.node_disk_type
    service_account = google_service_account.cluster.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = [
      "gke-public", # For network firewall
    ]
    
  }
}

resource "google_container_node_pool" "poolsfu" {
  provider = google-beta
  cluster  = google_container_cluster.cluster.name
  name     = var.node_poolsfu
  location = var.region
  project  = var.project
  
  node_count = 1
  
  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  node_config {
    image_type   = "COS" 
    machine_type = var.node_type
    preemptible  = false # Don't want nodes failing during calls particularly
    disk_size_gb = var.node_disk_size
    disk_type    = var.node_disk_type
    service_account = google_service_account.cluster.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      apps = "sfu"
    }

    tags = [
      "gke-public", # For network firewall
    ]
    
  }
}