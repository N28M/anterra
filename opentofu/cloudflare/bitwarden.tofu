provider "bitwarden" {
  access_token = var.bws_access_token

  experimental {
    embedded_client = true
  }
}

# Fetch all infrastructure configuration from Bitwarden Secrets Manager
data "bitwarden_secret" "cloudflare_api_token" {
  id = var.cloudflare_api_token_secret_id
}

data "bitwarden_secret" "cloudflare_account_id" {
  id = var.cloudflare_account_id_secret_id
}

data "bitwarden_secret" "cloudflare_zone_id" {
  id = var.cloudflare_zone_id_secret_id
}

data "bitwarden_secret" "homelab_reverse_proxy_ip" {
  id = var.homelab_reverse_proxy_ip_secret_id
}

data "bitwarden_secret" "vps_reverse_proxy_ip" {
  id = var.vps_reverse_proxy_ip_secret_id
}
