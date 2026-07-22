variable "prospect_slug" {
  description = "Slug del prospect per garantire la tracciabilità e isolamento naming"
  type        = string
}

variable "network_name" {
  description = "Nome della VPC GCP a cui associare le regole Firewall"
  type        = string
}

variable "target_tags" {
  description = "Target Tags applicati alle VM GCP per attivare le regole firewall"
  type        = list(string)
  default     = ["rancher-management-node"]
}

variable "allowed_admin_cidrs" {
  description = "Range IP/CIDR autorizzati ad accedere all'interfaccia di amministrazione"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_cluster_cidrs" {
  description = "Range IP/CIDR autorizzati per la comunicazione di cluster e webhook callbacks"
  type        = list(string)
  default     = ["10.0.0.0/8", "0.0.0.0/0"]
}
