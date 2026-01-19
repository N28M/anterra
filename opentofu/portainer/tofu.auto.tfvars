# Portainer configuration
docker_pve2_portainer_endpoint_id = 3
docker_pve_portainer_endpoint_id  = 5

# Bitwarden secret IDs for Portainer API key
portainer_api_key_secret_id = "2012023b-8e2f-4f50-81d6-b39a004d5051"

# Bitwarden secret IDs for Docker user configuration
docker_user_puid_secret_id = "ebc00a81-e41d-4700-83ec-b39a005d61c1"
docker_user_pgid_secret_id = "fee8aa06-03bc-4ef6-bcd0-b39a005d9064"

# Docker timezone - used for cron schedule interpretation
docker_timezone = "Asia/Kolkata"

# Docker paths
docker_config_path      = "/mnt/docker/config"
docker_data_path        = "/mnt/docker/appdata"
docker_media_path       = "/mnt/docker/media"
docker_downloads_path   = "/mnt/docker/downloads"
docker_documents_path   = "/mnt/docker/documents"
docker_pictures_path    = "/mnt/docker/pictures"

# Bitwarden secret IDs for Gluetun configuration
vpn_input_port_secret_id  = "95a1d37d-700b-4898-9578-b39a005cb0ce"
outbound_subnet_secret_id = "f58eec00-2682-4a82-81f5-b39a005ce2cd"

# Gluetun WireGuard configuration (AirVPN)
wireguard_private_key_secret_id   = "02f3fa48-ea5a-4aa8-8c1f-b3d7000f086e"
wireguard_preshared_key_secret_id = "216d6a97-10be-49f2-97ea-b3d7000f27fb"
wireguard_addresses_secret_id     = "15f6f039-e9fc-48d7-9b3c-b3d7000f4453"

# Tailscale-AirVPN WireGuard configuration (separate AirVPN config)
ts_wireguard_private_key_secret_id   = "789cf967-4187-4858-86f2-b3d700105a23"
ts_wireguard_preshared_key_secret_id = "38a591b6-677d-4ebd-b698-b3d700109cd9"
ts_wireguard_addresses_secret_id     = "4391e20d-8ef6-41ed-8148-b3d70010d095"

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
# TODO: Replace with actual Bitwarden secret ID after creating Tailscale auth key
n8n_tailscale_auth_key_secret_id = "201cdbb6-177f-4188-9a26-b39f002fc4a3"

# Domain name
domain_name_secret_id = "ad518b08-eb55-4eb3-a040-b3b10077183d"

# Profilarr configuration
git_user_name_secret_id = "75c9e41b-7fba-47df-9a9e-b3be00624c2e"
git_user_email_secret_id = "b5166a34-6849-4ab1-aa0d-b3be006292d5"
profilarr_pat_secret_id = "bf724d98-7499-4a0e-ba3f-b3be0063bf14"

# NoteDiscovery configuration
# TODO: Replace with actual Bitwarden secret IDs after creating secrets
notediscovery_secret_key_secret_id    = "24281e4c-a2f2-46d3-af67-b3c8009fffb7"
notediscovery_password_hash_secret_id = "bd289b84-58a8-40f9-8436-b3c800a01612"