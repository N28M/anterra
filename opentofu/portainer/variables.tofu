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

# Docker user UID
variable "docker_user_puid" {
  description = "Docker user process UID"
  type        = string
}

# Docker user GID
variable "docker_user_pgid" {
  description = "Docker user process GID"
  type        = string
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
