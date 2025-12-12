provider "bitwarden" {
  access_token = var.bws_access_token

  experimental {
    embedded_client = true
  }
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

# Fetch Docker user PUID from Bitwarden Secrets Manager
data "bitwarden_secret" "docker_user_puid" {
  id = var.docker_user_puid_secret_id
}

# Fetch Docker user PGID from Bitwarden Secrets Manager
data "bitwarden_secret" "docker_user_pgid" {
  id = var.docker_user_pgid_secret_id
}

# Fetch Karakeep NextAuth URL from Bitwarden Secrets Manager
data "bitwarden_secret" "karakeep_nextauth_url" {
  id = var.karakeep_nextauth_url_secret_id
}

# Fetch Karakeep NextAuth secret from Bitwarden Secrets Manager
data "bitwarden_secret" "karakeep_nextauth_secret" {
  id = var.karakeep_nextauth_secret_id
}

# Fetch Karakeep Meilisearch master key from Bitwarden Secrets Manager
data "bitwarden_secret" "karakeep_meilisearch_key" {
  id = var.karakeep_meilisearch_key_secret_id
}

# Fetch Karakeep OpenAI API key from Bitwarden Secrets Manager (optional)
data "bitwarden_secret" "karakeep_openai_api_key" {
  id = var.karakeep_openai_api_key_secret_id
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

# Fetch Jotty OIDC issuer from Bitwarden Secrets Manager
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

# Fetch domain name from Bitwarden Secrets Manager
data "bitwarden_secret" "domain_name" {
  id = var.domain_name_secret_id
}
