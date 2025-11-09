# Bitwarden Secrets Manager access token
# This should be provided via environment variable TF_VAR_bws_access_token
variable "bws_access_token" {
  description = "Bitwarden Secrets Manager access token for authentication"
  type        = string
  sensitive   = true
}

# Bitwarden secret IDs for fetching all infrastructure credentials and configuration
variable "cloudflare_api_token_secret_id" {
  description = "The Bitwarden secret ID for the Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id_secret_id" {
  description = "The Bitwarden secret ID for the Cloudflare account ID"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id_secret_id" {
  description = "The Bitwarden secret ID for the Cloudflare zone ID"
  type        = string
  sensitive   = true
}

variable "homelab_reverse_proxy_ip_secret_id" {
  description = "The Bitwarden secret ID for the homelab reverse proxy IP address"
  type        = string
  sensitive   = true
}

variable "vps_reverse_proxy_ip_secret_id" {
  description = "The Bitwarden secret ID for the VPS reverse proxy IP address"
  type        = string
  sensitive   = true
}