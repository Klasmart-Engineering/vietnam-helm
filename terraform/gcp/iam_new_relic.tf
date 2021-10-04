# IAM Role for external New Relic monitoring service.
# See here for documentation:
# https://docs.newrelic.com/docs/integrations/google-cloud-platform-integrations/get-started/connect-google-cloud-platform-services-new-relic/#service

# Note - each project needs it's own service account, and the name must be generated in advance by New Relic.

locals {
  new_relic_service_account_roles = [
    "roles/viewer",
    "roles/serviceusage.serviceUsageConsumer"
  ]
}

resource "google_project_iam_member" "new_relic" {
  project  = var.terraform_project
  for_each = toset(
      # Only grant access if the New Relic IAM role email has been set
      var.new_relic_iam_role_email == "" ? [] : local.new_relic_service_account_roles
    )
  role     = each.value
  member   = "serviceAccount:${var.new_relic_iam_role_email}"
}
