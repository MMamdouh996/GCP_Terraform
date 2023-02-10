output "vpc_self_link" {
  value = google_compute_network.p-vpc.self_link
}
output "management_subnet_self_link" {
  value = google_compute_subnetwork.management_subnet.self_link
}
output "restricted_subnet_self_link" {
  value = google_compute_subnetwork.restricted_subnet.self_link
}
output "nat_ip" {
  value = google_compute_router_nat.nat.nat_ips
}
