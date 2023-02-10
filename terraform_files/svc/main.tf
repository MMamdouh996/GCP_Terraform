resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
  # disable_dependent_services = true
}
resource "google_project_service" "container_api" {
  service = "container.googleapis.com"
  #   disable_dependent_services = true
}
