provider "bitwarden" {
  access_token = var.bws_access_token

  client_implementation = "embedded"
}

# Fetch Portainer API key from Bitwarden Secrets Manager
data "bitwarden_secret" "portainer_api_key" {
  id = var.portainer_api_key_secret_id
}

# Fetch Gluetun VPN input port from Bitwarden Secrets Manager
data "bitwarden_secret" "vpn_input_port" {
  id = var.vpn_input_port_secret_id
}

# Fetch Gluetun outbound subnet from Bitwarden Secrets Manager
data "bitwarden_secret" "outbound_subnet" {
  id = var.outbound_subnet_secret_id
}

# Fetch Gluetun WireGuard private key from Bitwarden Secrets Manager
data "bitwarden_secret" "wireguard_private_key" {
  id = var.wireguard_private_key_secret_id
}

# Fetch Gluetun WireGuard preshared key from Bitwarden Secrets Manager
data "bitwarden_secret" "wireguard_preshared_key" {
  id = var.wireguard_preshared_key_secret_id
}

# Fetch Gluetun WireGuard address from Bitwarden Secrets Manager
data "bitwarden_secret" "wireguard_addresses" {
  id = var.wireguard_addresses_secret_id
}

# Fetch Tailscale-AirVPN WireGuard private key from Bitwarden Secrets Manager
data "bitwarden_secret" "ts_wireguard_private_key" {
  id = var.ts_wireguard_private_key_secret_id
}

# Fetch Tailscale-AirVPN WireGuard preshared key from Bitwarden Secrets Manager
data "bitwarden_secret" "ts_wireguard_preshared_key" {
  id = var.ts_wireguard_preshared_key_secret_id
}

# Fetch Tailscale-AirVPN WireGuard address from Bitwarden Secrets Manager
data "bitwarden_secret" "ts_wireguard_addresses" {
  id = var.ts_wireguard_addresses_secret_id
}

# Fetch Docker user PUID from Bitwarden Secrets Manager
data "bitwarden_secret" "docker_user_puid" {
  id = var.docker_user_puid_secret_id
}

# Fetch Docker user PGID from Bitwarden Secrets Manager
data "bitwarden_secret" "docker_user_pgid" {
  id = var.docker_user_pgid_secret_id
}


# Fetch Tailscale auth key from Bitwarden Secrets Manager
data "bitwarden_secret" "tailscale_auth_key" {
  id = var.tailscale_auth_key_uuid
}

# Fetch Immich database password from Bitwarden Secrets Manager
data "bitwarden_secret" "immich_db_password" {
  id = var.immich_db_password_secret_id
}

# Fetch n8n database password from Bitwarden Secrets Manager
data "bitwarden_secret" "n8n_db_password" {
  id = var.n8n_db_password_secret_id
}

# Fetch n8n encryption key from Bitwarden Secrets Manager
data "bitwarden_secret" "n8n_encryption_key" {
  id = var.n8n_encryption_key_secret_id
}

# Fetch n8n Tailscale auth key from Bitwarden Secrets Manager
data "bitwarden_secret" "n8n_tailscale_auth_key" {
  id = var.n8n_tailscale_auth_key_secret_id
}

# Fetch domain name from Bitwarden Secrets Manager
data "bitwarden_secret" "domain_name" {
  id = var.domain_name_secret_id
}

# Fetch Profilarr Git user name from Bitwarden Secrets Manager
data "bitwarden_secret" "git_user_name" {
  id = var.git_user_name_secret_id
}

# Fetch Profilarr Git user email from Bitwarden Secrets Manager
data "bitwarden_secret" "git_user_email" {
  id = var.git_user_email_secret_id
}

# Fetch Profilarr personal access token from Bitwarden Secrets Manager
data "bitwarden_secret" "profilarr_pat" {
  id = var.profilarr_pat_secret_id
}

# Fetch Jotty OIDC issuer URL from Bitwarden Secrets Manager
data "bitwarden_secret" "jotty_oidc_issuer" {
  id = var.jotty_oidc_issuer_secret_id
}

# Fetch Jotty OIDC client ID from Bitwarden Secrets Manager
data "bitwarden_secret" "jotty_oidc_client_id" {
  id = var.jotty_oidc_client_id_secret_id
}

# Fetch Jotty OIDC client secret from Bitwarden Secrets Manager
data "bitwarden_secret" "jotty_oidc_client_secret" {
  id = var.jotty_oidc_client_secret_secret_id
}

# Fetch Domain Locker database password from Bitwarden Secrets Manager
data "bitwarden_secret" "domain_locker_db_password" {
  id = var.domain_locker_db_password_secret_id
}

# Fetch Reactive Resume database password from Bitwarden Secrets Manager
data "bitwarden_secret" "reactive_resume_db_password" {
  id = var.reactive_resume_db_password_secret_id
}

# Fetch Reactive Resume auth secret from Bitwarden Secrets Manager
data "bitwarden_secret" "reactive_resume_auth_secret" {
  id = var.reactive_resume_auth_secret_secret_id
}

# Fetch Reactive Resume app URL from Bitwarden Secrets Manager
data "bitwarden_secret" "reactive_resume_app_url" {
  id = var.reactive_resume_app_url_secret_id
}

# Fetch Whoa Nihongo secret key from Bitwarden Secrets Manager
data "bitwarden_secret" "whoa_nihongo_secret_key" {
  id = var.whoa_nihongo_secret_key_secret_id
}

# Fetch Meilisearch master key from Bitwarden Secrets Manager
data "bitwarden_secret" "meili_master_key" {
  id = var.meili_master_key_secret_id
}

# Fetch Chessalytic database password from Bitwarden Secrets Manager
data "bitwarden_secret" "chessalytic_db_password" {
  id = var.chessalytic_db_password_secret_id
}

# Fetch Chessalytic AI encryption key from Bitwarden Secrets Manager
data "bitwarden_secret" "chessalytic_ai_encryption_key" {
  id = var.chessalytic_ai_encryption_key_secret_id
}
