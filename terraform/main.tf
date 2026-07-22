terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

# ------------------------------------------------------------------------------
# 1. NETWORKING: LOGICAL MULTI-TENANT ISOLATED VPC
# ------------------------------------------------------------------------------
resource "google_compute_network" "demo_vpc" {
  name                    = "vpc-${var.prospect_name_slug}-${var.blueprint_id}"
  auto_create_subnetworks = false
  description             = "VPC isolata per la sessione di demo del prospect ${var.prospect_name_slug}"
}

resource "google_compute_subnetwork" "demo_subnet" {
  name          = "sb-${var.prospect_name_slug}-${var.gcp_region}"
  ip_cidr_range = var.subnet_cidr
  region        = var.gcp_region
  network       = google_compute_network.demo_vpc.id
}

# ------------------------------------------------------------------------------
# 2. FIREWALL RULES: INGRESS / EGRESS CONTROL
# ------------------------------------------------------------------------------
# Ingress per la gestione amministrativa (SSH, Rancher UI / Harvester UI, K8s API)
resource "google_compute_firewall" "allow_admin_access" {
  name    = "fw-allow-admin-${var.prospect_name_slug}"
  network = google_compute_network.demo_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "6443"] # SSH, Web UI, K8s API
  }

  source_ranges = var.allowed_admin_cidrs
  target_tags   = ["rancher-management-node"]
}

# Ingress per la comunicazione tra cluster downstream / nodi di demo
resource "google_compute_firewall" "allow_cluster_internal" {
  name    = "fw-allow-cluster-${var.prospect_name_slug}"
  network = google_compute_network.demo_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["9345", "8472", "30000-32767"] # RKE2 node join, VXLAN, NodePorts
  }

  allow {
    protocol = "udp"
    ports    = ["8472"] # Flannel / Canal VXLAN
  }

  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["rancher-management-node"]
}

# ------------------------------------------------------------------------------
# 3. PUBLIC STATIC IP RESERVATION
# ------------------------------------------------------------------------------
resource "google_compute_address" "demo_public_ip" {
  name        = "ip-${var.prospect_name_slug}"
  region      = var.gcp_region
  description = "IP pubblico statico riservato per accedere alla demo UI e Ansible execution"
}

# ------------------------------------------------------------------------------
# 4. COMPUTE ENGINE: RANCHER / HARVESTER NODE (WITH NESTED VIRTUALIZATION)
# ------------------------------------------------------------------------------
resource "google_compute_instance" "rancher_node" {
  name         = "node-${var.prospect_name_slug}"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  tags = ["rancher-management-node"]

  # Boot Disk configurato per sostenere i carichi di K3s/RKE2 e immagini VM di mock
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.boot_disk_size_gb
      type  = "pd-ssd"
    }
  }

  # CRITICO PER DEMO SUSE VIRTUALIZATION / HARVESTER: Abilita KVM Nesting su GCP
  advanced_machine_features {
    enable_nested_virtualization = var.enable_nested_virtualization
  }

  network_interface {
    network    = google_compute_network.demo_vpc.id
    subnetwork = google_compute_subnetwork.demo_subnet.id

    access_config {
      nat_ip = google_compute_address.demo_public_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.public_key_path)}"
    # Cloud-init baseline script per preparare l'ambiente all'arrivo di Ansible
    user-data = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - curl
        - iptables
        - open-iscsi
      runcmd:
        - systemctl enable --now iscsid
    EOF
  }

  # ----------------------------------------------------------------------------
  # GOVERNANCE, AUDITING & AUTO-KILL SWITCH LABELS
  # ----------------------------------------------------------------------------
  labels = {
    prospect     = var.prospect_name_slug
    blueprint    = var.blueprint_id
    ttl_hours    = tostring(var.ttl_hours)
    environment  = var.environment
    managed_by   = "opentofu-n8n-pipeline"
  }
}
