# Portainer configuration
docker_pve2_portainer_endpoint_id = 3
docker_pve_portainer_endpoint_id  = 6

# Bitwarden secret IDs for Portainer API key
portainer_api_key_secret_id = "2012023b-8e2f-4f50-81d6-b39a004d5051"

# Bitwarden secret IDs for Docker user configuration
docker_user_puid_secret_id = "ebc00a81-e41d-4700-83ec-b39a005d61c1"
docker_user_pgid_secret_id = "fee8aa06-03bc-4ef6-bcd0-b39a005d9064"

# Docker timezone - used for cron schedule interpretation
docker_timezone = "Asia/Kolkata"

# Docker paths
docker_config_path    = "/mnt/docker/config"
docker_data_path      = "/mnt/docker/appdata"
docker_media_path     = "/mnt/docker/media"
docker_downloads_path = "/mnt/docker/downloads"

# Bitwarden secret IDs for Gluetun configuration
vpn_input_port_secret_id  = "95a1d37d-700b-4898-9578-b39a005cb0ce"
outbound_subnet_secret_id = "f58eec00-2682-4a82-81f5-b39a005ce2cd"

# Bitwarden secret IDs for karakeep
karakeep_nextauth_url_secret_id    = "a648d8c6-60d7-4690-a116-b39a00dc5d27"
karakeep_nextauth_secret_id        = "33da07f9-acf3-435c-b126-b39a00da782d"
karakeep_meilisearch_key_secret_id = "baa723ce-256a-4422-9ea2-b39a00daac32"
karakeep_openai_api_key_secret_id  = "a6c19765-5f3a-4fe6-ab83-b39a00e2e32f"

# Bitwarden secret UUID for Tailscale auth key
tailscale_auth_key_uuid = "201cdbb6-177f-4188-9a26-b39f002fc4a3"

# Immich configuration
immich_version               = "v2"
immich_upload_location       = "/mnt/docker/pictures"
immich_db_data_location      = "/mnt/docker/appdata/immich/postgres"
immich_db_password_secret_id = "38452888-85ea-4cdb-8013-b3a3006db7d5"

# n8n configuration
n8n_version                      = "latest"
n8n_data_path                    = "/mnt/docker/appdata/n8n"
n8n_db_data_location             = "/mnt/docker/appdata/n8n/postgres"
n8n_db_password_secret_id        = "2ecd207d-97f8-4756-8312-b3a4006eb641"
n8n_encryption_key_secret_id     = "c04cdd36-24f3-442b-994e-b3a4006ed76b"

# Jotty configuration
jotty_oidc_issuer_secret_id        = "0498fc2b-33dd-45f9-9c4e-b3aa004ab7c9"
jotty_oidc_client_id_secret_id     = "a4fee8b4-703d-4b91-b186-b3aa004aceed"
jotty_oidc_client_secret_secret_id = "2aa97515-6dc9-47a3-9d25-b3aa004af0ee"

# Domain name
domain_name_secret_id = "ad518b08-eb55-4eb3-a040-b3b10077183d"