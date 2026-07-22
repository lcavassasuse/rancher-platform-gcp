output "rancher_public_ip" {
  description = "IP Pubblico Statico (External IP) assegnato all'istanza di management su GCP"
  value       = google_compute_address.demo_public_ip.address
}

output "rancher_url" {
  description = "URL di accesso HTTPS diretto alla console Rancher / Harvester"
  value       = "https://${google_compute_address.demo_public_ip.address}"
}

output "ssh_command" {
  description = "Comando SSH formattato per la connessione rapida dell'operatore o SA"
  value       = "ssh ${var.ssh_user}@${google_compute_address.demo_public_ip.address}"
}

output "session_metadata" {
  description = "Payload JSON dei metadati di sessione consumato da n8n per le notifiche partner e il tracking del ROI"
  value = {
    prospect     = var.prospect_name_slug
    blueprint    = var.blueprint_id
    ttl_hours    = var.ttl_hours
    cluster_ip   = google_compute_address.demo_public_ip.address
    environment  = var.environment
  }
}

output "ansible_next_step" {
  description = "Comando per scatenare il Data Seeding via Ansible con i parametri dinamici del prospect"
  value       = "cd ../ansible && ./manage.sh deploy --extra-vars \"target_host=${google_compute_address.demo_public_ip.address} prospect=${var.prospect_name_slug} industry=${var.blueprint_id}\""
}
