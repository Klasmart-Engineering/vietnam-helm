data "google_container_engine_versions" "location" {
  location = var.region
  project  = var.project
}
       
data "google_project" "project" {
  project_id = var.project
}
