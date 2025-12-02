# Anterra

Infrastructure as Code (IaC) repository combining Ansible for configuration management and OpenTofu for infrastructure provisioning, with integrated Bitwarden Secrets Manager for secure credential management.

## Overview

This repository implements a dual-tool IaC approach:
- **Ansible**: Configuration management and software installation (all infrastructure platforms)
- **OpenTofu**: Infrastructure provisioning (Cloudflare DNS, Portainer container management)
- **Bitwarden Secrets Manager**: Runtime secret retrieval (no hardcoded credentials)

**Note on Proxmox**: Proxmox VE cluster is managed manually via the web UI. Ansible playbooks handle VM configuration after manual creation. See [Proxmox VM Setup](#proxmox-vm-setup-for-hardware-passthrough) for hardware passthrough instructions (used for media server with GPU transcoding support).

## Architecture

This project is designed with a clear separation of concerns, leveraging the strengths of each tool:

- **OpenTofu for Infrastructure Provisioning**:
  - **Cloudflare**: Manages DNS records. All records are defined in `opentofu/cloudflare/dns_records.tofu` using a `for_each` loop, with IP addresses fetched from Bitwarden at runtime.
  - **Portainer**: Manages container stacks across multiple Docker environments. Stacks are defined as Docker Compose templates in `opentofu/portainer/compose-files/` and deployed via `portainer_stack` resources in `opentofu/portainer/stacks.tofu`. Supports multiple Portainer endpoints (e.g., `docker_pve2_portainer_endpoint_id` and `docker_pve_portainer_endpoint_id`).

- **Ansible for Configuration Management**:
  - **System-level configuration**: Installs and configures software on virtual machines, including Docker, Caddy, and Tailscale.
  - **Caddy reverse proxy**: Manages the Caddyfile configuration, including generating reverse proxy records from a Jinja2 template and a YAML data file.

- **Bitwarden for Secrets Management**:
  - **Centralized secrets**: All secrets, including API tokens, credentials, and IP addresses, are stored in Bitwarden Secrets Manager.
  - **Runtime secret retrieval**: Both OpenTofu and Ansible are configured to fetch secrets from Bitwarden at runtime, so no secrets are ever stored in the repository.

## Getting Started

This guide will walk you through the initial setup of your Anterra homelab environment.

### 1. Prerequisites

Ensure you have the following software installed on your control node (the machine you'll run Ansible and OpenTofu from):

- **Ansible**: Recommended installation via `pipx`.
  ```bash
  pipx install --include-deps ansible
  ```
- **OpenTofu**: Follow the [official installation guide](https://opentofu.org/docs/intro/install/) for your operating system.
- **Bitwarden Account**: You'll need a Bitwarden account with access to the Secrets Manager.

### 2. Clone the Repository

Clone this repository to your local machine:

```bash
git clone <repository-url>
cd anterra
```

### 3. Configure Ansible Vault

Ansible Vault is used to encrypt sensitive data within the repository.

1.  **Create the Vault Password File**:
    The `ansible.cfg` file is pre-configured to look for the vault password at `ansible/vault/.vault_password`. Create this file and add your desired vault password to it.

    ```bash
    mkdir -p ansible/vault
    read -sp "Enter your Ansible Vault password: " vault_password && echo $vault_password > ansible/vault/.vault_password
    echo "" # Add a newline for clarity
    ```

    **Note**: This file is included in `.gitignore` and should never be committed to the repository.

2.  **Create and Encrypt the Secrets File**:
    The main secrets file is `ansible/inventory/group_vars/all/secrets.yaml`. Create this file and add any initial secrets you need. For more details, see the [Ansible Vault Secrets (`secrets.yaml`)](#ansible-vault-secrets-secretsyaml) section.

    Encrypt the file using your vault password:
    ```bash
    ansible-vault encrypt ansible/inventory/group_vars/all/secrets.yaml
    ```

### 4. Set Up Bitwarden Secrets Manager

1.  **Create a Machine Account**:
    - In your Bitwarden web vault, go to **Settings** > **Machine Accounts**.
    - Click **Add machine account** and give it a descriptive name (e.g., `anterra-automation`).
    - After creation, you will be shown a **Client ID** and **Client Secret**. **Copy these immediately**, as they will not be shown again. You will use these to create an access token.

2.  **Generate an Access Token**:
    You can generate an access token using the `bws` CLI or by making a direct API call. The token is what OpenTofu and Ansible will use to authenticate.

3.  **Grant Access to Projects**:
    - Go to the **Projects** tab for your newly created machine account.
    - Grant it access to the Bitwarden Projects that contain the secrets required for this repository (e.g., Cloudflare API token, Portainer API key).

4.  **Store Secrets**:
    Ensure all necessary secrets are stored in your Bitwarden vault and organized into projects that the machine account can access. You will need the **Secret ID** (a UUID) for each secret to configure OpenTofu and Ansible.

### 5. Configure Environment Variables

OpenTofu requires the Bitwarden access token to be set as an environment variable. Add the following to your `~/.bashrc`, `~/.zshrc`, or equivalent shell profile file:

```bash
# Bitwarden Secrets Manager Access Token for OpenTofu
export TF_VAR_bws_access_token="your-bws-access-token-here"
```

Reload your shell for the changes to take effect:
```bash
source ~/.bashrc
```

### 6. Initial Deployment

With the setup complete, you can now run the initial Ansible playbooks to provision your VMs and then run OpenTofu to configure your infrastructure.

1.  **Provision VMs**: Follow the [Proxmox VM Setup](#proxmox-vm-setup-for-hardware-passthrough) guide to create your virtual machines.
2.  **Run Ansible Playbooks**:
    Start by setting up your Docker server, which will host Portainer and other services.
    ```bash
    # Ensure your inventory/hosts.yaml is configured with the correct IP addresses
    ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/proxmox/setup_docker_server.yaml
    ```
3.  **Run OpenTofu**:
    Apply the OpenTofu configuration to set up Cloudflare DNS and deploy your Portainer stacks.
    ```bash
    cd opentofu/cloudflare
    tofu init
    tofu apply

    cd ../portainer
    tofu init
    tofu apply
    ```

You are now ready to manage your homelab using IaC!

## Workflow: Adding a New Service

This workflow outlines the steps to add a new service to your homelab, from DNS configuration to reverse proxy setup.

### 1. Add DNS Record in OpenTofu

First, define a DNS A record for your new service in the Cloudflare module.

1.  **Open the DNS records file**:
    `opentofu/cloudflare/dns_records.tofu`

2.  **Add a new entry to the `a_records` map**:
    ```hcl
    locals {
      a_records = {
        # ... existing records
        "new-service" = {
          content = local.homelab_reverse_proxy_ip
        }
      }
    }
    ```
    - The key (`"new-service"`) will be the subdomain.
    - `content` should be the IP address of your reverse proxy, fetched from Bitwarden via `local.homelab_reverse_proxy_ip`.
    - Set `proxied = true` if the service should be routed through Cloudflare's proxy (for external services).

3.  **Apply the changes**:
    ```bash
    cd opentofu/cloudflare
    tofu apply
    ```

### 2. (Optional) Deploy Container Stack in Portainer

If your new service is a Docker container, add it to the Portainer OpenTofu module.

1.  **Create a Docker Compose template**:
    - Create a new file in `opentofu/portainer/compose-files/` named `new-service.yaml.tpl`.
    - Use template variables like `${docker_user_puid}`, `${docker_user_pgid}`, `${docker_timezone}`, and `${docker_config_path}` for portability.

    **Example `watchtower.yaml.tpl`**:
    ```yaml
    version: '3.7'
    services:
      watchtower:
        image: containrrr/watchtower:latest
        container_name: watchtower
        restart: unless-stopped
        environment:
          - TZ=${docker_timezone}
          - WATCHTOWER_CLEANUP=true
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
    ```

2.  **Define the stack in `stacks.tofu`**:
    - Open `opentofu/portainer/stacks.tofu`.
    - Add a new `portainer_stack` resource.

    ```hcl
    resource "portainer_stack" "new_service" {
      endpoint_id = var.portainer_endpoint_id
      name        = "New Service"
      repository = {
        url = "https://github.com/your-repo/anterra" # Or your fork
        path = "opentofu/portainer/compose-files/new-service.yaml"
        # Add git credentials if needed
      }
      # Or use template_file to render a local compose file
      # content = templatefile("${path.module}/compose-files/new-service.yaml.tpl", { ... })
    }
    ```
    **Finding the `portainer_endpoint_id`**:
    - In the Portainer UI, navigate to **Endpoints**.
    - The ID is the number shown in the "ID" column for your desired endpoint.

3.  **Apply the changes**:
    ```bash
    cd opentofu/portainer
    tofu apply
    ```

### 3. Configure Caddy Reverse Proxy

Finally, configure Caddy to route traffic to your new service.

1.  **Edit the Caddy records file**:
    Open `ansible/playbooks/caddy/caddy_records.yaml`.

2.  **Add a new reverse proxy record**:
    ```yaml
    reverse_proxy_records:
      # ... existing records
      - domain: new-service.your-domain.com
        upstream: 192.168.1.100:8080
    ```
    - `domain`: The fully qualified domain name (FQDN).
    - `upstream`: The IP address and port of the service.
    - Add `tls_skip_verify: true` if the upstream service uses a self-signed certificate.
    - Add `extra_headers` if the upstream service requires original host/IP information (e.g., Home Assistant):
      ```yaml
      extra_headers:
        - "Host {host}"
        - "X-Real-IP {remote_host}"
      ```
      These headers ensure the upstream service receives the original client IP and host information through the proxy, which is critical for services that validate requests based on source IP or require proper host headers for functionality.

3.  **Run the Caddy playbook**:
    ```bash
    ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/caddy/caddy_reverse_proxy.yaml
    ```

Caddy will automatically fetch a TLS certificate for the new domain and begin proxying traffic. Your new service is now live!

## Deployed Services

### Home Assistant

Home Assistant is an open-source home automation platform that provides centralized control for smart home devices.

**Deployment Details**:
- **URL**: https://homeassistant.ketwork.in
- **VM Location**: Proxmox homelab
- **DNS Management**: Cloudflare (proxied through Cloudflare CDN)
- **Reverse Proxy**: VPS Caddy instance via Tailscale
- **Port**: 8123 (internal)

**Reverse Proxy Configuration**:
The reverse proxy includes custom headers (`Host` and `X-Real-IP`) to ensure Home Assistant receives the original client IP and host information. This is essential for Home Assistant's security validation and proper functionality through the proxy.

**Important - Home Assistant Trusted Proxies Configuration**:
To allow Home Assistant to properly receive requests through the reverse proxy, you must configure the `http:` section in Home Assistant's `configuration.yaml` with trusted proxies. Add the following configuration, replacing the IP addresses with your actual reverse proxy IP(s):

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 192.168.1.50  # REPLACE THIS with the actual IP of your reverse proxy
    - 172.16.0.0/12 # Optional: trusted subnet (often used for Docker networks)
    - 127.0.0.1     # Optional: if the proxy is on the same machine (localhost)
```

**Configuration Details**:
- `use_x_forwarded_for: true`: Enables Home Assistant to trust the X-Forwarded-For header from the reverse proxy
- `trusted_proxies`: List of IP addresses/subnets that are allowed to set client IP headers
- Without this configuration, Home Assistant may reject requests from the reverse proxy as a security measure

**Configuration Files**:
- DNS: `opentofu/cloudflare/dns_records.tofu`
- Reverse Proxy: `ansible/playbooks/caddy/caddy_records.yaml`

### Karakeep (Bookmark Manager)

Karakeep is a self-hosted bookmark manager with AI-powered tagging and full-text search capabilities.

**Deployment Details**:
- **URL**: https://keep.ketwork.in
- **Stack Location**: `opentofu/portainer/compose-files/karakeep.yaml.tpl`
- **DNS Management**: Cloudflare (proxied through Cloudflare CDN)
- **Reverse Proxy**: VPS Caddy instance via Tailscale
- **Port**: 3000 (internal)

**Required Bitwarden Secrets**:
1. `karakeep_nextauth_url_secret_id` - Application URL (https://keep.ketwork.in)
2. `karakeep_nextauth_secret_id` - NextAuth session encryption key (generate with `openssl rand -base64 36`)
3. `karakeep_meilisearch_key_secret_id` - Meilisearch master key (generate with `openssl rand -base64 36`)
4. `karakeep_openai_api_key_secret_id` - OpenAI API key for AI-powered automatic tagging (optional)

**Stack Components**:
- **Web**: Main Karakeep application (ghcr.io/karakeep-app/karakeep)
- **Chrome**: Headless Chrome for web scraping and automation
- **Meilisearch**: Full-text search engine

**Initial Setup**:
1. Deploy the stack via OpenTofu Portainer configuration
2. Visit https://keep.ketwork.in and create your admin account
3. After creating your account, signups are automatically disabled (`DISABLE_SIGNUPS=true`)
4. If you need to re-enable signups temporarily, remove the `DISABLE_SIGNUPS` environment variable from the compose template and reapply with `tofu apply`

**AI Configuration**:
- **AI Models**: Configured to use `gpt-4o-mini` for both text and image inference (cost-effective and fast)
- **Alternative Models**: You can change the models by updating `INFERENCE_TEXT_MODEL` and `INFERENCE_IMAGE_MODEL` in the compose template
- **Available Models**: Any OpenAI model (gpt-4, gpt-4-turbo, gpt-4o, gpt-3.5-turbo, etc.)
- **Ollama Support**: For local AI inference, replace `OPENAI_API_KEY` with `OLLAMA_BASE_URL` pointing to your Ollama instance

**Important Security Note**: The stack is configured with `DISABLE_SIGNUPS=true` to prevent unauthorized account creation. Only remove this setting temporarily if you need to create additional accounts, then immediately re-enable it and redeploy.

### Tailscale + AirVPN Exit Node

This stack combines Gluetun VPN with Tailscale to create a secure exit node. All traffic from Tailscale clients using this exit node is routed through the AirVPN provider, providing an additional layer of privacy and security.

**Stack Location**: `opentofu/portainer/compose-files/tailscale-airvpn.yaml.tpl`

**Architecture**:
- **Gluetun Container**: Handles VPN connectivity via AirVPN (WireGuard protocol)
- **Tailscale Container**: Runs in network_mode "service:gluetun" to route all traffic through the VPN

**Deployment Details**:
- **Stack Name**: `tailscale-airvpn`
- **Network Mode**: Both containers use the Gluetun container's network, ensuring all traffic routes through the VPN
- **Exit Node**: Configured with `TS_EXTRA_ARGS=--advertise-exit-node` to advertise itself as an exit node to the Tailscale network

**Required Bitwarden Secrets**:
1. `tailscale_auth_key_uuid` - Tailscale authentication key UUID (generate via Tailscale admin console and store in Bitwarden)

**AirVPN Certificate Setup**:
The tailscale-airvpn stack uses separate AirVPN certificates from the regular gluetun stack:

1. Generate AirVPN certificates from https://client.airvpn.org/
2. Download in OpenVPN 2.6 format and extract `client.crt` and `client.key`
3. Store both files as separate secrets in Bitwarden Secrets Manager
4. Add the secret UUIDs to `ansible/inventory/group_vars/all/secrets.yaml`:
   - `tailscale_airvpn_crt_uuid` - UUID for the Tailscale stack certificate
   - `tailscale_airvpn_key_uuid` - UUID for the Tailscale stack key
5. Run the certificate deployment playbook to deploy certificates to the Docker host:
   ```bash
   ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/gluetun/configure_airvpn_certificates.yaml
   ```

**Initial Setup**:
1. Generate separate AirVPN certificates for the tailscale-airvpn stack (different from the regular gluetun stack)
2. Add the certificate UUIDs to `ansible/inventory/group_vars/all/secrets.yaml`:
   ```yaml
   tailscale_airvpn_crt_uuid: "your-uuid-here"
   tailscale_airvpn_key_uuid: "your-uuid-here"
   ```
3. Create a Tailscale reusable auth key in Tailscale admin console (Settings > Keys)
4. Store the Tailscale auth key in Bitwarden Secrets Manager and note the UUID
5. Update `opentofu/portainer/tofu.auto.tfvars`:
   ```hcl
   tailscale_auth_key_uuid = "your-bitwarden-uuid"
   ```
6. Deploy AirVPN certificates via Ansible playbook:
   ```bash
   ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/gluetun/configure_airvpn_certificates.yaml
   ```
7. Deploy the stack via OpenTofu:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
8. In Portainer, restart the `gluetun-ts` container in the `tailscale-airvpn` stack
9. Verify in container logs that "VPN connected" message appears
10. In the Tailscale admin console:
    - Verify the exit node is visible and online
    - Enable it as an exit node
11. On Tailscale clients, select this exit node in Settings to route all traffic through the VPN

**Important Notes**:
- The tailscale-airvpn stack uses **separate AirVPN certificates** from the regular gluetun stack
- Each stack can authenticate with a different AirVPN account or certificate pair if needed
- AirVPN certificates are deployed to the Docker host via Ansible playbook
- Tailscale auth key is stored in Bitwarden and fetched at OpenTofu deploy time
- The Tailscale exit node must be manually enabled in the Tailscale admin console before clients can use it
- Container names use the suffix `-ts` to distinguish them from the regular gluetun stack (e.g., `gluetun-ts`, `tailscale-ts`)

**Reference**: For detailed architecture and best practices, see [Unlock Secure Freedom: Route All Traffic Through Tailscale + Gluetun](https://fathi.me/unlock-secure-freedom-route-all-traffic-through-tailscale-gluetun/)

## Available Playbooks

This section details the Ansible playbooks available in this repository.

### Common Playbooks (`playbooks/common/`)

These playbooks are intended to be run on all or most of your VMs.

-   **`install_caddy.yaml`**: Installs and configures Caddy as a reverse proxy. Fetches the Cloudflare API token from Bitwarden for DNS-01 ACME challenges.
-   **`install_bitwarden.yaml`**: Installs the Bitwarden Secrets Manager CLI (`bws`).
-   **`install_opentofu.yaml`**: Installs OpenTofu.
-   **`install_tailscale.yaml`**: Installs and configures Tailscale for secure networking.

### Caddy Playbooks (`playbooks/caddy/`)

-   **`caddy_reverse_proxy.yaml`**: Configures Caddy reverse proxy records based on the contents of `caddy_records.yaml`.
-   **`reset_caddyfile.yaml`**: Resets the Caddyfile to a minimal configuration.

### Gluetun Playbook (`playbooks/gluetun/`)

-   **`configure_airvpn_certificates.yaml`**: Deploys AirVPN certificates to the Docker host for both the gluetun and tailscale-airvpn stacks. Manages certificates for all Gluetun containers using AirVPN.

### Proxmox VM Playbooks (`playbooks/proxmox/`)

These playbooks are designed for setting up specific types of Proxmox VMs.

-   **`setup_docker_server.yaml`**:
    -   Installs Docker and Docker Compose.
    -   Creates a `dockeruser` and sets up directories (`/mnt/docker/{appdata,config,media,pictures}`).
    -   Installs and configures Portainer Agent container (exposes port 9001 for remote Portainer management).
    -   Fetches SSH password from Bitwarden for authentication (requires `docker_pve_ssh_password_uuid` in vault).

-   **`setup_media_server.yaml`**:
    -   Sets up a media server, including installing any necessary software.
    -   *Note: This playbook is likely intended to be run on a VM with GPU passthrough for hardware transcoding.*

-   **`setup_samba_server.yaml`**:
    -   Installs and configures a Samba server for network file sharing.
    -   Creates a `samba` user and group.
    -   Sets up two shares:
        -   **`Public`**: A guest-accessible share for general file sharing.
        -   **`Private`**: A secured share accessible only by the `samba` user.
    -   The Samba user's password should be stored in Bitwarden and configured in `group_vars/all/secrets.yaml`.

## Configuration Details

### `ansible.cfg`

The `ansible.cfg` file is the main configuration file for Ansible. This repository's `ansible.cfg` is configured to automatically use the Ansible Vault password file, so you don't need to enter it manually for each command.

```ini
[defaults]
inventory = inventory/
vault_password_file = vault/.vault_password
```

### Ansible Vault Secrets (`secrets.yaml`)

The `ansible/inventory/group_vars/all/secrets.yaml` file is where you should store secrets that are used by Ansible playbooks. This file is encrypted with Ansible Vault.

**Example structure**:
```yaml
# Bitwarden Secret IDs (UUIDs)
# These are used to fetch the actual secrets from Bitwarden
cloudflare_api_token_secret_id: "your-cloudflare-api-token-secret-id"
docker_pve_ssh_password_uuid: "your-docker-pve-ssh-password-secret-id"
docker_pve2_ssh_password_uuid: "your-docker-pve2-ssh-password-secret-id"
samba_password_secret_id: "your-samba-password-secret-id"
bws_access_token: "your-bitwarden-access-token"

# Other Ansible-specific secrets
tailscale_auth_key: "your-tailscale-auth-key"
tailscale_airvpn_crt_uuid: "your-tailscale-airvpn-cert-uuid"
tailscale_airvpn_key_uuid: "your-tailscale-airvpn-key-uuid"
```

## Project Structure

```
anterra/
├── ansible/
│   ├── ansible.cfg                       # Auto-configured vault password location
│   ├── inventory/
│   │   ├── hosts.yaml                    # Target hosts
│   │   ├── group_vars/all/secrets.yaml   # Encrypted secrets (Ansible Vault)
│   │   └── host_vars/
│   │       └── docker.yaml               # Docker host variables
│   ├── playbooks/
│   │   ├── common/
│   │   │   ├── install_opentofu.yaml
│   │   │   ├── install_tailscale.yaml
│   │   │   ├── install_bitwarden.yaml
│   │   │   └── install_caddy.yaml
│   │   ├── caddy/
│   │   │   ├── caddy_reverse_proxy.yaml
│   │   │   ├── reset_caddyfile.yaml
│   │   │   ├── caddy_records.yaml        # Reverse proxy record definitions
│   │   │   └── templates/
│   │   │       └── caddy_reverse_proxy.j2
│   │   ├── gluetun/
│   │   │   ├── README.md                 # Gluetun VPN setup guide
│   │   │   ├── configure_airvpn_certificates.yaml
│   │   │   └── airvpn-certs/            # AirVPN certificates (gitignored)
│   │   └── proxmox/
│   │       ├── setup_docker_server.yaml  # Docker server setup with Portainer
│   │       ├── setup_media_server.yaml
│   │       └── setup_samba_server.yaml
│   └── vault/.vault_password             # Vault password (gitignored)
└── opentofu/
    ├── cloudflare/                       # DNS, CDN, security
    │   ├── providers.tofu
    │   ├── bitwarden.tofu
    │   ├── variables.tofu
    │   ├── dns_records.tofu
    │   ├── outputs.tofu
    │   └── tofu.auto.tfvars
    └── portainer/                        # Container orchestration & stacks
        ├── providers.tofu
        ├── bitwarden.tofu
        ├── variables.tofu
        ├── stacks.tofu
        ├── tofu.auto.tfvars
        └── compose-files/
            ├── watchtower.yaml.tpl       # Container auto-updater
            ├── gluetun.yaml.tpl          # VPN container with tunneled services
            ├── tailscale-airvpn.yaml.tpl # Gluetun + Tailscale exit node
            ├── karakeep.yaml.tpl         # Bookmark manager with AI tagging
            └── bentopdf.yaml.tpl         # Client-side PDF manipulation tool
```

## Security

- **Ansible Vault**: Automatic password loading from `ansible/vault/.vault_password`
- **Bitwarden Access Token**: Environment variable only (`~/.bashrc`)
- **No Hardcoded Secrets**: All credentials fetched at runtime
- **Gitignored Files**: Vault passwords, state files, secrets.auto.tfvars

## Proxmox VM Setup for Hardware Passthrough

This section covers setting up VMs with PCI hardware passthrough (e.g., GPU passthrough for Plex media server with Intel Quick Sync hardware transcoding).

### Prerequisites

#### Enable IOMMU on Proxmox Host

1. **Edit GRUB configuration**:
   ```bash
   nano /etc/default/grub

   # Modify the line:
   GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"

   # Update GRUB
   update-grub
   ```

2. **Load VFIO kernel modules**:
   ```bash
   echo "vfio" >> /etc/modules
   echo "vfio_iommu_type1" >> /etc/modules
   echo "vfio_pci" >> /etc/modules
   echo "vfio_virqfd" >> /etc/modules

   # Update initramfs
   update-initramfs -u -k all
   ```

3. **Blacklist GPU drivers on host** (for GPU passthrough):
   ```bash
   nano /etc/modprobe.d/pve-blacklist.conf

   # Add these lines:
   blacklist i915
   blacklist snd_hda_intel
   blacklist snd_hda_codec_hdmi
   ```

4. **Reboot Proxmox host**:
   ```bash
   reboot
   ```

5. **Verify IOMMU is enabled**:
   ```bash
   dmesg | grep -e DMAR -e IOMMU
   # Should show "DMAR: IOMMU enabled"

   lspci -nn | grep VGA
   # Note the PCI address (e.g., 00:02.0) and device ID (e.g., 8086:3e91)
   ```

### Creating a VM with GPU Passthrough (Plex Example)

#### VM Configuration Settings

**General**:
- VM ID: Choose an ID (e.g., 1002)
- Name: `mediacenter` (or your preferred name)
- Start at boot: ✓

**OS**:
- ISO: Ubuntu Server 22.04 LTS or 24.04 LTS
- Type: Linux
- Version: 6.x - 2.6 Kernel

**System**:
- Machine: q35
- BIOS: OVMF (UEFI)
- Add EFI Disk: ✓
- SCSI Controller: VirtIO SCSI Single
- Qemu Agent: ✓

**Disks**:
- Bus/Device: SCSI 0
- Storage: Your preferred storage
- Disk size: 32-128 GB (64GB+ recommended for Plex metadata)
- Cache: Write back
- Discard: ✓ (if using SSD)
- SSD emulation: ✓ (if storage is SSD)

**CPU**:
- Sockets: 1
- Cores: 4+ (more is better for transcoding)
- Type: **host** (critical for hardware transcoding performance)

**Memory**:
- Memory: 4096 MB minimum, 8192 MB recommended
- Ballooning Device: ✓

**Network**:
- Bridge: vmbr0
- Model: VirtIO (paravirtualized)

**Graphics**:
- Leave as Default during initial setup

#### Installation Process

1. **Create VM with standard settings** (without GPU passthrough initially)

2. **Install Ubuntu Server**:
   - Enable OpenSSH server during installation
   - Note the IP address assigned
   - Complete installation and reboot
   - Test SSH access from control node
   - Shutdown the VM

3. **Add GPU passthrough configuration**:
   ```bash
   # Edit VM configuration file (replace 1002 with your VM ID)
   nano /etc/pve/qemu-server/1002.conf

   # Add these lines:
   hostpci0: 0000:00:02.0,pcie=1,rombar=0
   vga: none

   # Verify CPU is set to host with hidden flag:
   cpu: host,hidden=1,flags=+pcid
   ```

   **Parameters explained**:
   - `hostpci0`: First PCI passthrough device
   - `0000:00:02.0`: PCI address from lspci (adjust for your hardware)
   - `pcie=1`: Present device as PCIe
   - `rombar=0`: Disable ROM bar (required for Intel iGPU)
   - `vga: none`: Disable virtual display
   - `cpu: host,hidden=1`: Better GPU driver compatibility

4. **Start VM and continue with Ansible configuration**

#### Why Install First, Then Add GPU?

Installing Ubuntu first with standard graphics, then adding GPU passthrough after:
- Simplifies installation (can use Proxmox console)
- Ensures SSH is configured before losing console access
- Allows verification that base system works before adding complexity
- Makes troubleshooting easier if issues arise

### Post-Installation

After GPU passthrough is configured:
- Console access through Proxmox web UI will not work (vga: none)
- All access must be via SSH
- Continue configuration with Ansible playbooks
- Verify GPU passthrough in VM: `lspci | grep VGA`

## Key Concepts and Terminology

-   **Control Node**: The machine where you run Ansible and OpenTofu commands.
-   **IaC (Infrastructure as Code)**: Managing and provisioning infrastructure through code instead of manual processes.
-   **Jinja2**: A templating engine for Python, used in Ansible to create dynamic configuration files.
-   **Playbook**: A set of instructions for Ansible to execute.
-   **OpenTofu Module**: A collection of `.tf` files in a directory that defines a set of resources.
-   **Provider**: A plugin for OpenTofu that interacts with a specific API (e.g., Cloudflare, Portainer, Bitwarden).

## Reference

- [OpenTofu Documentation](https://opentofu.org/)
- [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/)
- [maxlaverse/bitwarden Provider](https://registry.terraform.io/providers/maxlaverse/bitwarden/latest/docs)
- [Proxmox PCI Passthrough](https://pve.proxmox.com/wiki/PCI_Passthrough)
