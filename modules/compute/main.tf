# Instance Template
resource "google_compute_instance_template" "template" {
  name_prefix  = "web-template-"
  machine_type = "e2-micro"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt update
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Load Balanced Web Server 🚀</h1>" > /var/www/html/index.html
  EOF

  tags = ["http-server"]
}

# Managed Instance Group
resource "google_compute_instance_group_manager" "group" {
  name               = "web-group"
  base_instance_name = "web"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.template.id
  }

  target_size = 1
}

# Named port (required for load balancer)
resource "google_compute_instance_group_named_port" "http" {
  group = google_compute_instance_group_manager.group.name
  zone  = var.zone

  name = "http"
  port = 80
}