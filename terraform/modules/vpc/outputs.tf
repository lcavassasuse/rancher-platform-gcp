output "network_id" {
  description = "ID unico della VPC creata su GCP"
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "Nome della VPC GCP creata"
  value       = google_compute_network.vpc.name
}

output "subnetwork_id" {
  description = "ID della subnetwork GCP"
  value       = google_compute_subnetwork.subnet.id
}

output "public_ip_address" {
  description = "Indirizzo IP pubblico statico riservato alla demo"
  value       = google_compute_address.public_ip.address
}
