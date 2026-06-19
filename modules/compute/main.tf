resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # 🔥 Startup script installs NGINX automatically
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt update
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx

    echo "<h1>Terraform Deployed Web Server 🚀</h1>" > /var/www/html/index.html
  EOF

  network_interface {
    subnetwork = var.subnet_id

    access_config {}
  }

  tags = ["http-server"]
}
