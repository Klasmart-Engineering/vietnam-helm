
provider "google" {
  project = var.gcp_project
  region  = "asia-southeast2"
  version = "~> 3.49"
}

terraform {
  backend "gcs" {
    #bucket = [passed via -backend-config on command line]
    prefix  = "main"
  }
}