# Watchtower stack - automatically updates Docker containers on docker_pve2 (1:30 AM)
resource "portainer_stack" "watchtower" {
  name            = "watchtower"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/watchtower.yaml.tpl", {
    docker_user_puid    = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid    = data.bitwarden_secret.docker_user_pgid.value
    docker_timezone     = var.docker_timezone
    docker_config_path  = var.docker_config_path
    watchtower_schedule = "0 30 1 * * *"
  })
}

# Watchtower stack - automatically updates Docker containers on docker_pve (3:30 AM, 2 hours after docker_pve2)
resource "portainer_stack" "watchtower_docker_pve" {
  name            = "watchtower"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/watchtower.yaml.tpl", {
    docker_user_puid    = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid    = data.bitwarden_secret.docker_user_pgid.value
    docker_timezone     = var.docker_timezone
    docker_config_path  = var.docker_config_path
    watchtower_schedule = "0 30 3 * * *"
  })
}

# Gluetun stack - VPN container with multiple services tunneled through it
resource "portainer_stack" "gluetun" {
  name            = "gluetun"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/gluetun.yaml.tpl", {
    docker_user_puid       = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid       = data.bitwarden_secret.docker_user_pgid.value
    docker_timezone        = var.docker_timezone
    docker_config_path     = var.docker_config_path
    docker_media_path      = var.docker_media_path
    docker_downloads_path  = var.docker_downloads_path
    vpn_input_port         = data.bitwarden_secret.vpn_input_port.value
    outbound_subnet        = data.bitwarden_secret.outbound_subnet.value
    wireguard_private_key  = data.bitwarden_secret.wireguard_private_key.value
    wireguard_preshared_key = data.bitwarden_secret.wireguard_preshared_key.value
    wireguard_addresses    = data.bitwarden_secret.wireguard_addresses.value
    git_user_name          = data.bitwarden_secret.git_user_name.value
    git_user_email         = data.bitwarden_secret.git_user_email.value
    profilarr_pat          = data.bitwarden_secret.profilarr_pat.value
  })
}

# Tailscale + AirVPN stack - Gluetun VPN container with Tailscale as exit node
resource "portainer_stack" "tailscale_airvpn" {
  name            = "tailscale-airvpn"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/tailscale-airvpn.yaml.tpl", {
    docker_config_path       = var.docker_config_path
    vpn_input_port           = data.bitwarden_secret.vpn_input_port.value
    outbound_subnet          = data.bitwarden_secret.outbound_subnet.value
    tailscale_auth_key_value = data.bitwarden_secret.tailscale_auth_key.value
    wireguard_private_key    = data.bitwarden_secret.ts_wireguard_private_key.value
    wireguard_preshared_key  = data.bitwarden_secret.ts_wireguard_preshared_key.value
    wireguard_addresses      = data.bitwarden_secret.ts_wireguard_addresses.value
  })
}


# Immich stack - self-hosted photo and video management solution
resource "portainer_stack" "immich" {
  name            = "immich"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/immich.yaml.tpl", {
    docker_timezone         = var.docker_timezone
    immich_version          = var.immich_version
    immich_upload_location  = var.immich_upload_location
    immich_db_data_location = var.immich_db_data_location
    immich_db_password      = data.bitwarden_secret.immich_db_password.value
  })
}

# n8n stack - workflow automation platform with PostgreSQL and Tailscale sidecar
resource "portainer_stack" "n8n" {
  name            = "n8n"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/n8n.yaml.tpl", {
    docker_timezone        = var.docker_timezone
    docker_user_puid      = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid      = data.bitwarden_secret.docker_user_pgid.value
    n8n_version            = var.n8n_version
    n8n_data_path          = var.n8n_data_path
    n8n_db_data_location   = var.n8n_db_data_location
    n8n_db_password        = data.bitwarden_secret.n8n_db_password.value
    n8n_encryption_key     = data.bitwarden_secret.n8n_encryption_key.value
    domain_name            = local.domain_name
    tailscale_auth_key     = data.bitwarden_secret.n8n_tailscale_auth_key.value
  })
}

# FileBrowser stack - web-based file management interface
resource "portainer_stack" "filebrowser" {
  name            = "filebrowser"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/filebrowser.yaml.tpl", {
    docker_user_puid      = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid      = data.bitwarden_secret.docker_user_pgid.value
    docker_timezone       = var.docker_timezone
    docker_documents_path = var.docker_documents_path
    docker_config_path    = var.docker_config_path
  })
}

# Jotty stack - self-hosted notes and checklists with Cloudflare Zero Trust OIDC
resource "portainer_stack" "jotty" {
  name            = "jotty"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/jotty.yaml.tpl", {
    docker_user_puid         = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid         = data.bitwarden_secret.docker_user_pgid.value
    docker_timezone          = var.docker_timezone
    docker_data_path         = var.docker_data_path
    domain_name              = local.domain_name
    jotty_oidc_issuer        = data.bitwarden_secret.jotty_oidc_issuer.value
    jotty_oidc_client_id     = data.bitwarden_secret.jotty_oidc_client_id.value
    jotty_oidc_client_secret = data.bitwarden_secret.jotty_oidc_client_secret.value
  })
}

# Domain Locker stack - domain management and expiration tracking
resource "portainer_stack" "domain_locker" {
  name            = "domain-locker"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/domain-locker.yaml.tpl", {
    docker_data_path = var.docker_data_path
    db_password      = data.bitwarden_secret.domain_locker_db_password.value
  })
}

# Whoa Nihongo stack - Japanese language learning web application
resource "portainer_stack" "whoa_nihongo" {
  name            = "whoa-nihongo"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/whoa-nihongo.yaml.tpl", {
    docker_data_path = var.docker_data_path
    secret_key       = data.bitwarden_secret.whoa_nihongo_secret_key.value
  })
}

# Reactive Resume stack - free and open-source resume builder
resource "portainer_stack" "reactive_resume" {
  name            = "reactive-resume"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/reactive-resume.yaml.tpl", {
    docker_data_path = var.docker_data_path
    docker_timezone  = var.docker_timezone
    db_password      = data.bitwarden_secret.reactive_resume_db_password.value
    auth_secret      = data.bitwarden_secret.reactive_resume_auth_secret.value
    app_url          = data.bitwarden_secret.reactive_resume_app_url.value
  })
}

# Chessalytic stack - self-hosted chess.com game review frontend
resource "portainer_stack" "chessalytic" {
  name            = "chessalytic"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/chessalytic.yaml.tpl", {
    docker_data_path  = var.docker_data_path
    db_password       = data.bitwarden_secret.chessalytic_db_password.value
    ai_encryption_key = data.bitwarden_secret.chessalytic_ai_encryption_key.value
  })
}

# Meilisearch stack - full-text search engine for Karakeep
resource "portainer_stack" "meilisearch" {
  name            = "meilisearch"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/meilisearch.yaml.tpl", {
    docker_data_path = var.docker_data_path
    meili_master_key = data.bitwarden_secret.meili_master_key.value
  })
}

