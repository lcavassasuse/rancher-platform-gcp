# --- INGRESS REGENCY: ADMIN & DEMO OPERATOR ACCESS ---
resource "google_compute_firewall" "allow_admin" {
  name    = "fw-allow-admin-${var.prospect_slug}"
  network = var.network_name

  description = "Permette l'accesso amministrativo SSH e Web UI per la demo"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "6443"] # SSH, HTTP/HTTPS, Kubernetes API
  }

  source_ranges = var.allowed_admin_cidrs
  target_tags   = var.target_tags
}

# --- INGRESS REGENCY: DOWNSTREAM CLUSTER & INTER-NODE COMMUNICATION ---
resource "google_compute_firewall" "allow_cluster_traffic" {
  name    = "fw-allow-cluster-${var.prospect_slug}"
  network = var.network_name

  description = "Porte di comunicazione interne per nodi downstream RKE2 / Harvester CAPI"

  allow {
    protocol = "tcp"
    ports    = ["9345", "8472", "30000-32767"] # RKE2 Join, VXLAN overlay, NodePorts
  }

  allow {
    protocol = "udp"
    ports    = ["8472"] # Canal / Flannel VXLAN
  }

  source_ranges = var.allowed_cluster_cidrs
  target_tags   = var.target_tags
}
