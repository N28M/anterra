# Portainer configuration
portainer_url = "https://portainer.ketwork.in"
portainer_endpoint_id = 3

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
vpn_input_port_secret_id = "95a1d37d-700b-4898-9578-b39a005cb0ce"
outbound_subnet_secret_id = "f58eec00-2682-4a82-81f5-b39a005ce2cd"

# Bitwarden secret IDs for karakeep
karakeep_nextauth_url_secret_id = "a648d8c6-60d7-4690-a116-b39a00dc5d27" 
karakeep_nextauth_secret_id = "33da07f9-acf3-435c-b126-b39a00da782d"
karakeep_meilisearch_key_secret_id = "baa723ce-256a-4422-9ea2-b39a00daac32"