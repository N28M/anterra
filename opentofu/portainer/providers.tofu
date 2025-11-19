terraform {
  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = "~> 1.0"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "~> 0.12"
    }
  }
}

# Extract all infrastructure configuration from Bitwarden secrets
locals {
  portainer_api_key = data.bitwarden_secret.portainer_api_key.value
}

provider "portainer" {
  endpoint = var.portainer_url
  api_key  = local.portainer_api_key
}
