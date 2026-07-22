resource "google_compute_address" "static_ip" {
  name   = "ip-${var.prospect_slug}"
  region = var.region
}

resource "google_compute_instance" "vm_instance" {
  name         = "node-${var.prospect_slug}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = var.target_tags

  boot_disk {
    initialize_params {
      image = var.disk_image
      size  = var.disk_size_gb
      type  = "pd-ssd"
    }
  }

  # FONDAMENTALE PER SUSE HARVESTER / VIRTUALIZZAZIONE NIDIFICATA
  advanced_machine_features {
    enable_nested_virtualization = var.enable_nested_virtualization
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.subnet_id

    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_path)}"
  }

  labels = {
    prospect    = var.prospect_slug
    blueprint   = var.blueprint_id
    ttl_hours   = tostring(var.ttl_hours)
    environment = var.environment
    managed_by  = "opentofu-dac-engine"
  }
}
