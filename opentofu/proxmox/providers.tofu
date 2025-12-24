terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.89"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "~> 0.12"
    }
  }
}

# Extract all Proxmox configuration from Bitwarden secrets
locals {
  proxmox_endpoint      = data.bitwarden_secret.proxmox_endpoint.value
  proxmox_api_token     = data.bitwarden_secret.proxmox_api_token.value
  proxmox_ssh_username  = data.bitwarden_secret.proxmox_ssh_username.value
}

provider "proxmox" {
  endpoint  = local.proxmox_endpoint
  api_token = local.proxmox_api_token
  ssh {
    username = local.proxmox_ssh_username
  }
  # Disable TLS verification for self-signed certificates (common in homelabs)
  insecure = true
}
