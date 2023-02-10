resource "google_compute_network" "p-vpc" {
  project                 = var.project_name
  name                    = var.vpc_name
  auto_create_subnetworks = var.subnets_auto_create_state
  routing_mode            = var.routing_mode
  # depends_on              = [var.depends_on_list]
}

resource "google_compute_subnetwork" "management_subnet" {
  name                     = var.subnet_name_1
  ip_cidr_range            = var.subnet_cidr_1
  region                   = var.subnet_region_1
  network                  = google_compute_network.p-vpc.id
  private_ip_google_access = var.private_ip_google_access



}
resource "google_compute_subnetwork" "restricted_subnet" {
  name                     = var.subnet_name_2
  ip_cidr_range            = var.subnet_cidr_2
  region                   = var.subnet_region_2
  network                  = google_compute_network.p-vpc.id
  private_ip_google_access = var.private_ip_google_access

  secondary_ip_range {
    range_name    = var.secondary_pods_ip_range_name
    ip_cidr_range = var.secondary_pods_ip_cidr_range
  }

  secondary_ip_range {
    range_name    = var.secondary_svc_ip_range_name
    ip_cidr_range = var.secondary_svc_ip_cidr_range
  }


}


resource "google_compute_router" "router" {
  name    = var.router_name
  region  = google_compute_subnetwork.management_subnet.region
  network = google_compute_network.p-vpc.id

}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.management_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  nat_ips = [google_compute_address.nat.self_link]

}

resource "google_compute_address" "nat" {
  name         = "nat"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  # depends_on = [module.svc.compute_api]

}


resource "google_compute_firewall" "all-ingress" {
  name    = "allow-http-ssh"
  network = google_compute_network.p-vpc.name


  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}
