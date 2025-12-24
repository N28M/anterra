# Bitwarden secret UUIDs for Proxmox configuration
# These UUIDs are safe to commit - they only identify which secrets to fetch
# The actual secrets are stored securely in Bitwarden Secrets Manager

# TODO: Replace these placeholder UUIDs with your actual Bitwarden secret IDs
proxmox_endpoint_secret_id      = "96e8dd2e-0556-41cb-a187-b3bd0036b45f"
proxmox_api_token_secret_id     = "f8a98e3a-b9ad-462d-bdf3-b3bd00379a27"
proxmox_ssh_username_secret_id  = "c22c73f8-00fd-43e8-a69f-b3bd0037b878"

# Proxmox cluster node names
# Update these to match your actual node names if different
proxmox_node_1 = "pve"
proxmox_node_2 = "pve2"
