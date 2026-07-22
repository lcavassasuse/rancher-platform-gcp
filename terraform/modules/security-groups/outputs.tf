output "admin_firewall_name" {
  description = "Nome della regola Firewall per gli accessi admin"
  value       = google_compute_firewall.allow_admin.name
}

output "cluster_firewall_name" {
  description = "Nome della regola Firewall per il traffico cluster interno"
  value       = google_compute_firewall.allow_cluster_traffic.name
}
