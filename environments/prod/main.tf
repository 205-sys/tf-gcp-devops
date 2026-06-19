provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "network" {
  source      = "../../modules/network"
  vpc_name    = "prod-vpc"
  subnet_name = "prod-subnet"
  cidr        = "10.10.0.0/24"
  region      = var.region
}

module "compute" {
  source    = "../../modules/compute"
  vm_name   = "prod-vm"
  zone      = var.zone
  subnet_id = module.network.subnet_id
}

terraform {
  backend "gcs" {
    bucket  = "office-tf-state-2026-001"
    prefix = "prod"
  }
}

