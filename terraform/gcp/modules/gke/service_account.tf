resource "google_service_account" "cluster" {
  account_id   = "kidsloop-cluster"
  display_name = "kidsloop_cluster"
  project      = var.project
}

locals {
  all_service_account_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ]
}

resource "google_project_iam_member" "cluster" {
  for_each = toset(local.all_service_account_roles)
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
