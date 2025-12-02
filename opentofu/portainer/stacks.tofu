# Watchtower stack - automatically updates Docker containers
resource "portainer_stack" "watchtower" {
  name            = "watchtower"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/watchtower.yaml.tpl", {
    docker_user_puid   = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid   = data.bitwarden_secret.docker_user_pgid.value
    docker_timezone    = var.docker_timezone
    docker_config_path = var.docker_config_path
  })
}

# Gluetun stack - VPN container with multiple services tunneled through it
resource "portainer_stack" "gluetun" {
  name            = "gluetun"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/gluetun.yaml.tpl", {
    docker_user_puid      = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid      = data.bitwarden_secret.docker_user_pgid.value
    docker_timezone       = var.docker_timezone
    docker_config_path    = var.docker_config_path
    docker_media_path     = var.docker_media_path
    docker_downloads_path = var.docker_downloads_path
    vpn_input_port        = data.bitwarden_secret.vpn_input_port.value
    outbound_subnet       = data.bitwarden_secret.outbound_subnet.value
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
    tailscale_auth_key_value = data.bitwarden_secret.tailscale_auth_key.value
  })
}

# Karakeep stack - self-hosted bookmark manager with AI tagging
resource "portainer_stack" "karakeep" {
  name            = "karakeep"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/karakeep.yaml.tpl", {
    docker_user_puid       = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid       = data.bitwarden_secret.docker_user_pgid.value
    docker_timezone        = var.docker_timezone
    docker_data_path       = var.docker_data_path
    karakeep_version       = var.karakeep_version
    nextauth_secret        = data.bitwarden_secret.karakeep_nextauth_secret.value
    nextauth_url           = data.bitwarden_secret.karakeep_nextauth_url.value
    meilisearch_master_key = data.bitwarden_secret.karakeep_meilisearch_key.value
    openai_api_key         = data.bitwarden_secret.karakeep_openai_api_key.value
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

# n8n stack - workflow automation platform with PostgreSQL
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
  })
}

# BentoPDF stack - client-side PDF manipulation tool
resource "portainer_stack" "bentopdf" {
  name            = "bentopdf"
  deployment_type = "standalone"
  method          = "string"
  endpoint_id     = var.docker_pve2_portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/bentopdf.yaml.tpl", {
    docker_user_puid   = data.bitwarden_secret.docker_user_puid.value
    docker_user_pgid   = data.bitwarden_secret.docker_user_pgid.value
    docker_timezone    = var.docker_timezone
  })
}
