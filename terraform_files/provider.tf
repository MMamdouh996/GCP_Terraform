provider "google" {
  project = "mm-iti-cairo-2023"
  # credentials = file("least-rules.json")
  region = "us-east1"
}
terraform {
  backend "gcs" {
    bucket = "mohamed-mamdouh-gcp-terraform"
    prefix = "terraform/state"
  }
}

