# Bitwarden Secrets Manager access token
# This should be provided via environment variable TF_VAR_bws_access_token
variable "bws_access_token" {
  description = "Bitwarden Secrets Manager access token for authentication"
  type        = string
  sensitive   = true
}

# Portainer URL - the base URL of your Portainer installation
variable "portainer_url" {
  description = "The base URL of the Portainer instance (e.g., https://portainer.example.com)"
  type        = string
}

# Bitwarden secret ID for Portainer API key
variable "portainer_api_key_secret_id" {
  description = "The Bitwarden secret ID for the Portainer API key"
  type        = string
  sensitive   = true
}

# Portainer endpoint ID (typically 1 for the primary cluster/node)
variable "portainer_endpoint_id" {
  description = "The Portainer endpoint ID where stacks will be deployed"
  type        = number
  default     = 1
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
