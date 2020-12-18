
terraform {
  required_version = ">= 0.12.24"
  backend "gcs" {
    #bucket = [passed via -backend-config on command line]
    prefix  = "main"
  }
}

provider "google" {
  version = "~> 3.50.0"
  project = var.terraform_project
  region  = var.terraform_region
}

provider "google-beta" {
  version = "~> 3.50.0"
  project = var.terraform_project
  region  = var.terraform_region
}

module "vpc" {
  source  = "./modules/vpc"
  terraform_project = var.terraform_project
  terraform_region  = var.terraform_region
}

module "gke" {
  source  = "./modules/gke"
  terraform_project = var.terraform_project
  terraform_region  = var.terraform_region
  vpc     = module.vpc.vpc
  subnet  = module.vpc.subnet
}