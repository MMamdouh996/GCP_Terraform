resource "google_service_account" "GKE-SA" {
  account_id = "cluster-sa"
}

resource "google_project_iam_member" "cluster-service-account-role" {
  project = var.project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.GKE-SA.email}"
}

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
  node_config {
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    service_account = google_service_account.GKE-SA.email

  }
  # depends_on = var.gke_depend
}

# -----------------------------

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
resource "google_container_node_pool" "general" {
  name       = var.node_pool_name
  location   = var.cluster_location
  cluster    = google_container_cluster.GKE-Cluster.id
  node_count = var.number_of_node

  node_config {
    preemptible  = var.is_node_preemptible
    machine_type = var.node_machine_type


    service_account = google_service_account.GKE-SA.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"

    ]
  }
}
