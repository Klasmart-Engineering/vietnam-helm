
terraform {
  required_version = ">= 0.12.24"
  backend "gcs" {
    #bucket = [passed via -backend-config on command line]
    prefix  = "main"
  }
}

provider "google" {
  version = "~> 3.50.0"
  project = var.project
  region  = var.region
}

provider "google-beta" {
  version = "~> 3.50.0"
  project = var.project
  region  = var.region
}

module "vpc" {
  source  = "./modules/vpc"
  project = var.project
  region  = var.region
}

module "gke" {
  source  = "./modules/gke"
  project = var.project
  region  = var.region
  vpc     = module.vpc.vpc
  subnet  = module.vpc.subnet
}