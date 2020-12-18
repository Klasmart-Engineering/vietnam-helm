data "google_container_engine_versions" "gke" {
  location = var.region
  project  = var.project
}
       
data "google_project" "kl" {
  project_id = var.project
}
