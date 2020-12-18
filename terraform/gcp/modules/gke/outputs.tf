output "service_account_config_connector" {
  value = google_service_account.config_connector.email
}

output "service_account_cluster" {
  value = google_service_account.cluster.email
}
