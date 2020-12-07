
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  version = "~> 3.49"
}

terraform {
  backend "gcs" {
    #bucket = [passed via -backend-config on command line]
    prefix  = "main"
  }
}