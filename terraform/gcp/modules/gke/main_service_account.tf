# Cluster

resource "google_service_account" "cluster" {
  account_id   = var.service_account_name_cluster
  display_name = var.service_account_name_cluster
  project      = var.project
}

locals {
  cluster_service_account_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ]
}

resource "google_project_iam_member" "cluster" {
  for_each = toset(local.cluster_service_account_roles)
  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

resource "google_service_account_key" "cluster" {
  service_account_id = google_service_account.cluster.email
  key_algorithm    = "KEY_ALG_RSA_2048"
  public_key_type  = "TYPE_X509_PEM_FILE"
  private_key_type = "TYPE_GOOGLE_CREDENTIALS_FILE"
}


# Config Connector


resource "google_service_account" "config_connector" {
  account_id   = var.service_account_name_config_connector
  display_name = var.service_account_name_config_connector
  project      = var.project
}

locals {
  config_connector_service_account_roles = [
    "roles/compute.publicIpAdmin",
    "roles/cloudsql.admin",
    "roles/redis.admin",
    "roles/iam.serviceAccountAdmin"
  ]
}

resource "google_project_iam_member" "config_connector" {
  for_each = toset(local.config_connector_service_account_roles)
  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.config_connector.email}"
}


resource "google_service_account_iam_member" "config_connector" {
  service_account_id = google_service_account.config_connector.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[cnrm-system/cnrm-controller-manager]"
  depends_on = [google_container_cluster.cluster]
}


# Cloud SQL Proxy


resource "google_service_account" "cloudsql_proxy" {
  account_id   = "cloudsql-proxy"
  display_name = "cloudsql-proxy"
  project      = var.project
}

locals {
  cloudsql_proxy_service_account_roles = [
    "roles/cloudsql.admin"
  ]
}

resource "google_project_iam_member" "cloudsql_proxy" {
  for_each = toset(local.cloudsql_proxy_service_account_roles)
  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloudsql_proxy.email}"
}


