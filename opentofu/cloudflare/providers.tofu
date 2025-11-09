terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "~> 0.12"
    }
  }
}

# Extract all infrastructure configuration from Bitwarden secrets
locals {
  cloudflare_api_token      = data.bitwarden_secret.cloudflare_api_token.value
  cloudflare_account_id     = data.bitwarden_secret.cloudflare_account_id.value
  cloudflare_zone_id        = data.bitwarden_secret.cloudflare_zone_id.value
  homelab_reverse_proxy_ip  = data.bitwarden_secret.homelab_reverse_proxy_ip.value
  vps_reverse_proxy_ip      = data.bitwarden_secret.vps_reverse_proxy_ip.value
}

provider "cloudflare" {
  api_token = local.cloudflare_api_token
}