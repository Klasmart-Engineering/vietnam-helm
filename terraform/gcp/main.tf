
terraform {
  required_version = ">= 0.12.24"
  backend "gcs" {
    #bucket = [passed via -backend-config on command line]
    prefix  = "main"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.74.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.74.0"
    }
  }
}

provider "google" {
  region  = var.terraform_region
  project = var.terraform_project
}

provider "google-beta" {
  project = var.terraform_project
  region  = var.terraform_region
}

module "vpc" {
  source  = "./modules/vpc"
  project = var.terraform_project
  region  = var.terraform_region
}

module "gke" {
  source    = "./modules/gke"
  project   = var.terraform_project
  region    = var.terraform_region
  vpc       = module.vpc.vpc
  subnet    = module.vpc.subnet
  node_type = var.node_type
}
