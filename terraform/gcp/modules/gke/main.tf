data "google_container_engine_versions" "location" {
  location = var.terraform_region
  project  = var.terraform_project
}
       
data "google_project" "project" {
  project_id = var.terraform_project
}
