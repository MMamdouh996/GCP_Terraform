resource "google_compute_instance" "managment_instnace" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.instance_zone
  boot_disk {
    initialize_params {
      image = var.instnace_image
    }
  }
  network_interface {
    network    = var.vpc_self_link
    subnetwork = var.subnet_self_link


  }
  metadata_startup_script = <<EOF
#!/bin/bash
sudo apt update
echo test > ~/filetest
sudo apt-get install apt-transport-https ca-certificates gnupg -y
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-cli-cloud-cli

sudo apt-get install google-cloud-cli-gke-gcloud-auth-plugin
grep -rhE ^deb /etc/apt/sources.list* | grep "cloud-sdk"
sudo apt-get install kubectl -y

sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

gcloud container clusters get-credentials private-cluster --zone us-east1-b --project mm-iti-cairo-2023

  EOF

  service_account {
    email  = "terraform-sa@mm-iti-cairo-2023.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
