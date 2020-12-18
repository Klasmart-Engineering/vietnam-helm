resource "google_container_cluster" "cluster" {
  provider      = google-beta
  name          = var.cluster_name
  location      = var.region
  project       = var.project
  network       = var.vpc
  subnetwork    = var.subnet
    
  logging_service    = "logging.googleapis.com/kubernetes"     # Lets use Stackdriver
  monitoring_service = "monitoring.googleapis.com/kubernetes"  # Lets use Stackdriver
  min_master_version = data.google_container_engine_versions.gke.latest_master_version
  
  enable_shielded_nodes       = true          # https://cloud.google.com/kubernetes-engine/docs/how-to/shielded-gke-nodes
  enable_intranode_visibility = true          # https://cloud.google.com/kubernetes-engine/docs/how-to/intranode-visibility
  networking_mode             = "VPC_NATIVE"  # Required for private service networking to services
                                              # https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
  network_policy {
    enabled = true                            # Networking policy will allow us to go multi-tenant but lay dormant otherwise
    provider = "CALICO"                       # https://cloud.google.com/kubernetes-engine/docs/how-to/network-policy
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "" # Let GCP choose
    services_ipv4_cidr_block = "" # Let GCP choose
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = true   # We'd like certificate, not basic authentication
    }
  }

  workload_identity_config {
    identity_namespace = "${var.project}.svc.id.goog"   # https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
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
    enabled = true
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

}

