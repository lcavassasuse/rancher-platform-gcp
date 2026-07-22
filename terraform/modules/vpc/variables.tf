variable "prospect_slug" {
  description = "Slug univoco del prospect (utilizzato per naming e multi-tenancy)"
  type        = string
}

variable "blueprint_id" {
  description = "ID del blueprint della demo (es. vmw-to-harvester-migration)"
  type        = string
}

variable "region" {
  description = "Regione GCP di deployment (es. europe-west3)"
  type        = string
  default     = "europe-west3"
}

variable "subnet_cidr" {
  description = "Range CIDR allocato per la subnetwork"
  type        = string
  default     = "10.0.10.0/24"
}
