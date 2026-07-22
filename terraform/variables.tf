# --- GCP AUTHENTICATION (INJECTED VIA ENV VAR) ---
variable "GCP_CREDENTIALS_JSON" {
  description = "Contenuto JSON della chiave del Service Account GCP passato dalla piattaforma (TF_VAR_gcp_credentials_json)"
  type        = string
  sensitive   = true
  default     = "" # Se vuota, il provider ripiega automaticamente su GOOGLE_APPLICATION_CREDENTIALS
}

# --- GCP PROJECT & LOCATION CONFIGURATION ---
variable "gcp_project_id" {
  description = "ID del progetto GCP in cui verrà creata l'infrastruttura di demo"
  type        = string
}

variable "gcp_region" {
  description = "Regione GCP per le risorse regionali (Subnet, IP Statici Pubblici)"
  type        = string
  default     = "europe-west3" # Frankfurt (scelta ottimale per bassa latenza in EU)
}

variable "gcp_zone" {
  description = "Zona GCP per le istanze di calcolo (deve supportare la nested virtualization se necessaria)"
  type        = string
  default     = "europe-west3-a"
}

# --- DEMO GOVERNANCE & MULTI-TENANCY (Passati da Salesforce / n8n) ---
variable "prospect_name_slug" {
  description = "Slug del prospect (es. 'acme-corp') usato per naming isolato e tagging multi-tenant"
  type        = string
}

variable "blueprint_id" {
  description = "ID del blueprint di demo (es. 'vmw-to-harvester-migration')"
  type        = string
  default     = "vmw-to-harvester-migration"
}

variable "ttl_hours" {
  description = "Durata massima dell'ambiente prima dell'esecuzione del kill-switch automatico (24/48h)"
  type        = number
  default     = 24
}

variable "environment" {
  description = "Etichetta di ambiente applicata come label GCP (es. dev, demo-sandbox)"
  type        = string
  default     = "demo-sandbox"
}

# --- NETWORKING CONFIGURATIONS ---
variable "subnet_cidr" {
  description = "Blocco CIDR per la subnetwork personalizzata GCP"
  type        = string
  default     = "10.0.10.0/24"
}

variable "allowed_admin_cidrs" {
  description = "CIDR autorizzati ad accedere alla Web UI di Rancher/Harvester (porte 80, 443, 6443)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_ssh_cidrs" {
  description = "CIDR autorizzati per la connessione SSH (porta 22)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# --- COMPUTE & STORAGE SPECIFICATIONS ---
variable "machine_type" {
  description = "Tipo di istanza GCP equivalente a t3.xlarge AWS (minimo 4 vCPU, 16 GB RAM per RKE2 + Rancher Prime)"
  type        = string
  default     = "n2-standard-4"
}

variable "boot_disk_size_gb" {
  description = "Dimensione del disco di boot in GiB (pd-ssd o pd-balanced consigliati)"
  type        = number
  default     = 100
}

variable "enable_nested_virtualization" {
  description = "Abilita la Nested Virtualization sull'istanza GCP (critica per demo SUSE Harvester / hypervisor)"
  type        = bool
  default     = true
}

# --- SSH & ACCESS CONTROL ---
variable "ssh_user" {
  description = "Utente SSH configurato sull'immagine Linux"
  type        = string
  default     = "suse-admin"
}

variable "public_key_path" {
  description = "Path della chiave SSH pubblica per l'accesso e la gestione automatizzata via Ansible"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
