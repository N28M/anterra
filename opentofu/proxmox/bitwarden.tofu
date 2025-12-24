provider "bitwarden" {
  access_token = var.bws_access_token

  experimental {
    embedded_client = true
  }
}

# Fetch all Proxmox configuration from Bitwarden Secrets Manager
data "bitwarden_secret" "proxmox_endpoint" {
  id = var.proxmox_endpoint_secret_id
}

data "bitwarden_secret" "proxmox_api_token" {
  id = var.proxmox_api_token_secret_id
}

data "bitwarden_secret" "proxmox_ssh_username" {
  id = var.proxmox_ssh_username_secret_id
}
