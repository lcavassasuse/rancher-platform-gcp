# --- GCP VPC NETWORK (MULTI-TENANT ISOLATED) ---
resource "google_compute_network" "vpc" {
  name                    = "vpc-${var.prospect_slug}-${var.blueprint_id}"
  auto_create_subnetworks = false
  description             = "VPC isolata per la sessione demo del prospect ${var.prospect_slug}"
}

# --- REGIONAL SUBNETWORK ---
resource "google_compute_subnetwork" "subnet" {
  name          = "sb-${var.prospect_slug}-${var.region}"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

# --- EXTERNAL STATIC PUBLIC IP FOR DEMO ACCESS ---
resource "google_compute_address" "public_ip" {
  name        = "ip-${var.prospect_slug}"
  region      = var.region
  description = "IP pubblico statico assegnato per la Web UI di Rancher/Harvester e le chiamate Ansible"
}
