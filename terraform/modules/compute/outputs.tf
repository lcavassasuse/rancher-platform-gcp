variable "prospect_slug" { type = string }
variable "blueprint_id"   { type = string }
variable "ttl_hours"      { type = number }
variable "environment"    { type = string, default = "demo" }

variable "region"         { type = string }
variable "zone"           { type = string }
variable "vpc_id"         { type = string }
variable "subnet_id"      { type = string }

variable "machine_type"   { type = string, default = "n2-standard-4" }
variable "disk_image"     { type = string, default = "ubuntu-os-cloud/ubuntu-2204-lts" }
variable "disk_size_gb"   { type = number, default = 100 }

variable "enable_nested_virtualization" { type = bool, default = true }
variable "target_tags"                  { type = list(string), default = ["rancher-node"] }

variable "ssh_user"        { type = string, default = "suse-admin" }
variable "ssh_pub_key_path"{ type = string }
