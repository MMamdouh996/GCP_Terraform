# resource "google_project_service" "compute_api" {
#   service = "compute.googleapis.com"
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# resource "google_project_service" "container_api" {
#   service = "container.googleapis.com"
#   # disable_dependent_services = true
#   depends_on = [
#     google_project_service.compute_api
#   ]
#   #   #  lifecycle {
#   #   #    prevent_destroy = true
#   #   #  }
# }
