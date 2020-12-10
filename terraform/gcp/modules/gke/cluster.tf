resource "google_container_cluster" "cluster" {
  provider      = google-beta
  name          = "kidsloop"
  description   = "Kubernetes cluster for KidsLoop deployment"
  location      = var.region
  project       = var.project
  network       = var.vpc
  subnetwork    = var.subnet
    
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes" 
  min_master_version = data.google_container_engine_versions.location.latest_master_version
  
  enable_shielded_nodes = true
  enable_intranode_visibility = true

  networking_mode = "VPC_NATIVE"
  
  network_policy {
    enabled = true
    provider = "CALICO"
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "" # Let GCP choose
    services_ipv4_cidr_block = "" # Let GCP choose
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }

  workload_identity_config {
    identity_namespace = "${var.project}.svc.id.goog"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_window
    }
  }

  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.cluster.id
  }

  vertical_pod_autoscaling {
    enabled = false
  }
  
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
    dns_cache_config {
      enabled = true
    }
    config_connector_config {
      enabled = true
    }
  }

  # Must be set and then deleted for some reason
  initial_node_count       = 1
  remove_default_node_pool = true
  lifecycle {
    ignore_changes = [
      node_config,
    ]
  }

}

