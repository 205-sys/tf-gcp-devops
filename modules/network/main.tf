resource "google_compute_network" "vpc" {
  name = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name = var.subnet_name
  ip_cidr_range = var.cidr
  region = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_firewall" "ssh" {
  name = "${var.vpc_name}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}