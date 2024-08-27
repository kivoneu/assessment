# main.tf

# Konfiguracja dostawcy Google Cloud
provider "google" {
  project = var.project_id
  region  = var.region
}

# Sieć VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
}

# Podsieć
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = "10.0.0.0/24"
}

# Grupa instancji zarządzanych dla serwera webowego
resource "google_compute_instance_template" "web_server" {
  name_prefix  = "web-server-template-"
  machine_type = "e2-medium"
  tags         = ["web-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {
      # Ephemeral IP
    }
  }

  metadata_startup_script = <<-EOF
              #!/bin/bash
              apt update
              apt install -y nginx
              echo "Hello from $(hostname)" > /var/www/html/index.html
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Grupa instancji zarządzanych
resource "google_compute_instance_group_manager" "web_server" {
  name               = "web-server-igm"
  base_instance_name = "web-server"
  zone               = "${var.region}-a"
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.web_server.self_link
  }

  named_port {
    name = "http"
    port = 80
  }
}

# Load Balancer
resource "google_compute_global_forwarding_rule" "web_server" {
  name       = "web-server-lb"
  target     = google_compute_target_http_proxy.web_server.self_link
  port_range = "80"
}

resource "google_compute_target_http_proxy" "web_server" {
  name    = "web-server-proxy"
  url_map = google_compute_url_map.web_server.self_link
}

resource "google_compute_url_map" "web_server" {
  name            = "web-server-url-map"
  default_service = google_compute_backend_service.web_server.self_link
}

resource "google_compute_backend_service" "web_server" {
  name        = "web-server-backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_health_check.web_server.self_link]

  backend {
    group = google_compute_instance_group_manager.web_server.instance_group
  }
}

resource "google_compute_health_check" "web_server" {
  name               = "web-server-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  http_health_check {
    port = 80
  }
}

# Cloud SQL (PostgreSQL)
resource "google_sql_database_instance" "db" {
  name             = "webapp-db-instance"
  database_version = "POSTGRES_13"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "web-server"
        value = google_compute_subnetwork.subnet.ip_cidr_range
      }
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "db" {
  name     = "webapp_db"
  instance = google_sql_database_instance.db.name
}

# Google Cloud Storage
resource "google_storage_bucket" "webapp_storage" {
  name          = "${var.project_id}-webapp-storage"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}

# Firewall
resource "google_compute_firewall" "web_server" {
  name    = "allow-http"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}
