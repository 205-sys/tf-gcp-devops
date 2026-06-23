provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "network" {
  source      = "../../modules/network"
  vpc_name    = "dev-vpc"
  subnet_name = "dev-subnet"
  cidr        = "10.10.0.0/24"
  region      = var.region
}


module "compute" {
  source    = "../../modules/compute"
  vm_name   = "dev-web-vm"
  zone      = var.zone
  subnet_id = module.network.subnet_id
}

terraform {
  backend "gcs" {
    bucket  = "office-tf-state-2026-001"
    prefix = "dev"
  }
}
# Health check
resource "google_compute_health_check" "http" {
  name = "http-health-check"

  http_health_check {
    port = 80
  }
}

# Backend service
resource "google_compute_backend_service" "web" {
  name                  = "web-backend"
  load_balancing_scheme = "EXTERNAL"  
  protocol              = "HTTP"

  backend {
    group = module.compute.instance_group
  }

  health_checks = [google_compute_health_check.http.id]
}

# URL map
resource "google_compute_url_map" "web" {
  name            = "web-map"
  default_service = google_compute_backend_service.web.id
}

# Target HTTP proxy
resource "google_compute_target_http_proxy" "web" {
  name    = "web-proxy"
  url_map = google_compute_url_map.web.id
}

# Global IP
resource "google_compute_global_address" "web_ip" {
  name = "web-ip"
}

# Forwarding rule
resource "google_compute_global_forwarding_rule" "web" {
  name       = "web-forwarding-rule"
  target     = google_compute_target_http_proxy.web.id
  port_range = "80"
  ip_address = google_compute_globals_address.web_ip.address
}