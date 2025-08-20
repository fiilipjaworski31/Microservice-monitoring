terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "handy-math-425518-k9" //Tutaj ID mojego projektu
  region  = "europe-central2" // Warszawa
}

resource "google_compute_network" "vpc_network" {
  name = "devops-sprint-network"
}

resource "google_compute_firewall" "allow_http_ssh" {
  name    = "allow-http-ssh-monitoring"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "9090", "3000"] # SSH, HTTP, App, Prometheus, Grafana
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "devops-server"
  machine_type = "e2-micro"
  zone         = "europe-central2-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.id
    access_config {
      // Pusty blok oznacza efemeryczny (tymczasowy) adres IP
    }
  }

  // Skrypt startowy instalujący Docker i Git
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io git
    systemctl start docker
    systemctl enable docker
  EOT
}