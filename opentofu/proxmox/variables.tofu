# Bitwarden access token (provided via environment variable TF_VAR_bws_access_token)
variable "bws_access_token" {
  description = "Bitwarden Secrets Manager access token"
  type        = string
  sensitive   = true
}

# Bitwarden secret IDs for Proxmox configuration
variable "proxmox_endpoint_secret_id" {
  description = "Bitwarden secret ID for Proxmox API endpoint (e.g., https://proxmox.example.com:8006/)"
  type        = string
}

variable "proxmox_api_token_secret_id" {
  description = "Bitwarden secret ID for Proxmox API token (format: username@realm!tokenname=uuid)"
  type        = string
}

variable "proxmox_ssh_username_secret_id" {
  description = "Bitwarden secret ID for Proxmox SSH username"
  type        = string
}

# Proxmox cluster node names
variable "proxmox_node_1" {
  description = "First Proxmox node name"
  type        = string
  default     = "pve"
}

variable "proxmox_node_2" {
  description = "Second Proxmox node name"
  type        = string
  default     = "pve2"
}
