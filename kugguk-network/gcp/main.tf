# Phase 1: one VM runs the 4-validator devnet compose. ~US$50/month estimate.
# Usage: terraform init && terraform apply -var project_id=... -var billing_account=...
terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 6.0" }
  }
}

variable "project_id" { type = string }
variable "billing_account" { type = string }
variable "region" { default = "europe-west1" }
variable "zone" { default = "europe-west1-b" }
variable "monthly_budget_eur" { default = 60 }

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_disk" "chain" {
  name = "kugguk-testnet-chain"
  type = "pd-balanced"
  zone = var.zone
  size = 50
}

resource "google_compute_instance" "testnet" {
  name         = "kugguk-testnet-1"
  machine_type = "e2-standard-2"
  zone         = var.zone
  tags         = ["kugguk-rpc"]

  boot_disk {
    initialize_params { image = "cos-cloud/cos-stable" }
  }
  attached_disk { source = google_compute_disk.chain.id }

  network_interface {
    network = "default"
    access_config {}
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  metadata = { block-project-ssh-keys = "true" }
}

# Only HTTPS reaches the VM; put Caddy/nginx with TLS + rate limiting in front of Besu :8545.
resource "google_compute_firewall" "rpc_https" {
  name          = "kugguk-rpc-https"
  network       = "default"
  target_tags   = ["kugguk-rpc"]
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

data "google_project" "this" {}

resource "google_billing_budget" "testnet" {
  billing_account = var.billing_account
  display_name    = "kugguk-testnet-cap"
  budget_filter { projects = ["projects/${data.google_project.this.number}"] }
  amount {
    specified_amount {
      currency_code = "EUR"
      units         = tostring(var.monthly_budget_eur)
    }
  }
  threshold_rules { threshold_percent = 0.5 }
  threshold_rules { threshold_percent = 0.9 }
  threshold_rules { threshold_percent = 1.0 }
}

output "public_ip" {
  value = google_compute_instance.testnet.network_interface[0].access_config[0].nat_ip
}
