resource "google_container_cluster" "GKE-Cluster" {
  name                     = var.cluster_name
  location                 = var.cluster_location
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = var.cluster_vpc
  subnetwork               = var.cluster_subnet
  networking_mode          = "VPC_NATIVE"

  addons_config {
    http_load_balancing {
      disabled = true
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.svc_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.access_cidr_block
      display_name = var.access_display_name
    }
  }
}

# -----------------------------

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
resource "google_container_node_pool" "general" {
  name       = "general"
  location   = var.cluster_location
  cluster    = google_container_cluster.GKE-Cluster.id
  node_count = 2

  node_config {
    preemptible  = true
    machine_type = "e2-small"



    service_account = "terraform-sa@mm-iti-cairo-2023.iam.gserviceaccount.com"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
