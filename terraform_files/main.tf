# module "services" {
#   source = "./svc"

# }
module "network" {
  source                    = "./networks"
  project_name              = var.project_name
  vpc_name                  = "project-vpc"
  subnets_auto_create_state = "false"
  routing_mode              = "GLOBAL"
  # depends_on_list           = [""]
  # depends_on_list = [module.services.compute_api]

  subnet_name_1            = var.manegement_subnet_name # will have private vm ( private ip ) no public and it will use NAT
  subnet_cidr_1            = var.manegement_subnet_cidr
  subnet_region_1          = "us-east1"
  private_ip_google_access = "true"

  subnet_name_2                = "restricted-subnet" # will have a full private GKE ( private control Plan) and 
  subnet_cidr_2                = "10.6.0.0/24"       # only the mangment subnet only can access its
  subnet_region_2              = "us-east1"
  secondary_pods_ip_range_name = var.secondary_pods_ip_range_name
  secondary_pods_ip_cidr_range = "10.15.0.0/16"
  secondary_svc_ip_range_name  = var.secondary_svc_ip_range_name
  secondary_svc_ip_cidr_range  = "10.16.0.0/16"

  router_name            = "nat-router"
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_name               = "public-nat"
}
# iam roles will be created tf too
module "management_ec2" {
  source           = "./vm"
  vpc_self_link    = module.network.vpc_self_link
  subnet_self_link = module.network.management_subnet_self_link
  instance_zone    = "us-east1-b"
  instance_name    = "manegment-instance"
  machine_type     = "e2-small"
  instnace_image   = "ubuntu-2204-jammy-v20230114"
  nat_ip           = module.network.nat_ip
  # nat_ip           = module.management_ec2.managment_instnace
  project = "mm-iti-cairo-2023"
}


module "Private-GKE" {
  source              = "./GKE"
  cluster_name        = "private-cluster"
  cluster_location    = "us-east1-b"
  cluster_subnet      = module.network.restricted_subnet_self_link
  cluster_vpc         = module.network.vpc_self_link
  pods_range_name     = var.secondary_pods_ip_range_name
  svc_range_name      = var.secondary_svc_ip_range_name
  access_cidr_block   = var.manegement_subnet_cidr
  access_display_name = var.manegement_subnet_name
  # gke_depend = [module.svc.container_api,module.svc.compute_api]
  # depends_on = [
  #   module.services.container_api, module.services.compute_api
  # ]
  node_pool_name      = "node-pool"
  node_machine_type   = "e2-small"
  is_node_preemptible = true
  number_of_node      = 2
  project             = "mm-iti-cairo-2023"
}

