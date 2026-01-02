# Bitwarden Secrets Manager access token
# This should be provided via environment variable TF_VAR_bws_access_token
variable "bws_access_token" {
  description = "Bitwarden Secrets Manager access token for authentication"
  type        = string
  sensitive   = true
}

# Bitwarden secret ID for Portainer API key
variable "portainer_api_key_secret_id" {
  description = "The Bitwarden secret ID for the Portainer API key"
  type        = string
  sensitive   = true
}

# Portainer endpoint ID for docker_pve2 environment
variable "docker_pve2_portainer_endpoint_id" {
  description = "The Portainer endpoint ID for docker_pve2 where stacks will be deployed"
  type        = number
  default     = 3
}

# Portainer endpoint ID for docker_pve environment
variable "docker_pve_portainer_endpoint_id" {
  description = "The Portainer endpoint ID for docker_pve where stacks will be deployed"
  type        = number
  default     = 6
}

# Docker user UID (Bitwarden secret ID)
variable "docker_user_puid_secret_id" {
  description = "The Bitwarden secret ID for Docker user process UID"
  type        = string
  sensitive   = true
}

# Docker user GID (Bitwarden secret ID)
variable "docker_user_pgid_secret_id" {
  description = "The Bitwarden secret ID for Docker user process GID"
  type        = string
  sensitive   = true
}

# Docker timezone
variable "docker_timezone" {
  description = "Timezone for Docker containers"
  type        = string
  default     = "UTC"
}

# Docker config path
variable "docker_config_path" {
  description = "Base path for Docker container configurations"
  type        = string
}

# Docker data path
variable "docker_data_path" {
  description = "Base path for Docker container data (appdata)"
  type        = string
}

# Docker media path (SMB mount for media - movies and TV shows)
variable "docker_media_path" {
  description = "Path for Docker container media data (SMB mount at /mnt/docker/media)"
  type        = string
}

# Docker downloads path (SMB mount for downloads)
variable "docker_downloads_path" {
  description = "Path for Docker container downloads data (SMB mount at /mnt/docker/downloads)"
  type        = string
}

# Docker documents path (SMB mount for documents)
variable "docker_documents_path" {
  description = "Path for Docker container documents data (SMB mount at /mnt/docker/documents)"
  type        = string
}

# Gluetun VPN input port (AirVPN forwarded port)
variable "vpn_input_port_secret_id" {
  description = "The Bitwarden secret ID for the Gluetun VPN input port"
  type        = string
  sensitive   = true
}

# Gluetun outbound subnet (internal network CIDR)
variable "outbound_subnet_secret_id" {
  description = "The Bitwarden secret ID for the Gluetun outbound subnet"
  type        = string
  sensitive   = true
}

# Karakeep version tag
variable "karakeep_version" {
  description = "Docker image tag for Karakeep (e.g., 'release' or specific version)"
  type        = string
  default     = "release"
}

# Karakeep NextAuth URL (Bitwarden secret ID)
variable "karakeep_nextauth_url_secret_id" {
  description = "The Bitwarden secret ID for Karakeep NextAuth URL (e.g., https://karakeep.example.com)"
  type        = string
  sensitive   = true
}

# Karakeep NextAuth secret (Bitwarden secret ID)
variable "karakeep_nextauth_secret_id" {
  description = "The Bitwarden secret ID for Karakeep NextAuth secret (random string for session encryption)"
  type        = string
  sensitive   = true
}

# Karakeep Meilisearch master key (Bitwarden secret ID)
variable "karakeep_meilisearch_key_secret_id" {
  description = "The Bitwarden secret ID for Karakeep Meilisearch master key"
  type        = string
  sensitive   = true
}

# Karakeep OpenAI API key (Bitwarden secret ID) - optional for AI tagging
variable "karakeep_openai_api_key_secret_id" {
  description = "The Bitwarden secret ID for Karakeep OpenAI API key (optional, enables AI-powered tagging)"
  type        = string
  sensitive   = true
}

# Tailscale auth key UUID (Bitwarden secret ID)
variable "tailscale_auth_key_uuid" {
  description = "The Bitwarden secret UUID for Tailscale auth key"
  type        = string
  sensitive   = true
}

# Immich version tag
variable "immich_version" {
  description = "Docker image tag for Immich (e.g., 'v2', 'v2.3.1', or 'release')"
  type        = string
  default     = "v2"
}

# Immich upload location (media storage)
variable "immich_upload_location" {
  description = "Absolute path for Immich media uploads storage"
  type        = string
}

# Immich database data location
variable "immich_db_data_location" {
  description = "Absolute path for Immich PostgreSQL database storage (must be local, not network share)"
  type        = string
}

# Immich database password (Bitwarden secret ID)
variable "immich_db_password_secret_id" {
  description = "The Bitwarden secret ID for Immich database password"
  type        = string
  sensitive   = true
}

# n8n version tag
variable "n8n_version" {
  description = "Docker image tag for n8n (e.g., 'latest', '1.x.x')"
  type        = string
  default     = "latest"
}

# n8n data directory path
variable "n8n_data_path" {
  description = "Absolute path for n8n data storage (.n8n directory with credentials and workflows)"
  type        = string
}

# n8n database data location
variable "n8n_db_data_location" {
  description = "Absolute path for n8n PostgreSQL database storage"
  type        = string
}

# n8n database password (Bitwarden secret ID)
variable "n8n_db_password_secret_id" {
  description = "The Bitwarden secret ID for n8n database password"
  type        = string
  sensitive   = true
}

# n8n encryption key (Bitwarden secret ID)
variable "n8n_encryption_key_secret_id" {
  description = "The Bitwarden secret ID for n8n encryption key"
  type        = string
  sensitive   = true
}

# Domain name (Bitwarden secret ID)
variable "domain_name_secret_id" {
  description = "The Bitwarden secret ID for the base domain name"
  type        = string
  sensitive   = true
}

# Profilarr Git user name (Bitwarden secret ID)
variable "git_user_name_secret_id" {
  description = "The Bitwarden secret ID for Profilarr Git user name"
  type        = string
  sensitive   = true
}

# Profilarr Git user email (Bitwarden secret ID)
variable "git_user_email_secret_id" {
  description = "The Bitwarden secret ID for Profilarr Git user email"
  type        = string
  sensitive   = true
}

# Profilarr personal access token (Bitwarden secret ID)
variable "profilarr_pat_secret_id" {
  description = "The Bitwarden secret ID for Profilarr personal access token"
  type        = string
  sensitive   = true
}
