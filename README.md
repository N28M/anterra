# Anterra

Infrastructure as Code (IaC) repository combining Ansible for configuration management and OpenTofu for infrastructure provisioning, with integrated Bitwarden Secrets Manager for secure credential management.

## Overview

This repository implements a dual-tool IaC approach:
- **Ansible**: Configuration management and software installation
- **OpenTofu**: Infrastructure provisioning (Cloudflare, Portainer)
- **Bitwarden Secrets Manager**: Runtime secret retrieval (no hardcoded credentials)

## Project Structure

```
anterra/
├── ansible/
│   ├── ansible.cfg                       # Auto-configured vault password location
│   ├── inventory/
│   │   ├── hosts.yaml                    # Target hosts
│   │   ├── group_vars/all/secrets.yaml   # Encrypted secrets (Ansible Vault)
│   │   └── host_vars/                    # Host-specific variables
│   ├── playbooks/common/
│   │   ├── install_opentofu.yaml
│   │   ├── install_tailscale.yaml
│   │   ├── install_bitwarden.yaml
│   │   └── install_caddy.yaml
│   └── vault/.vault_password             # Vault password (gitignored)
└── opentofu/
    ├── cloudflare/                       # DNS, CDN, security
    └── portainer/                        # Container orchestration
```

## Prerequisites

- **ansible** (installed via pipx)
- **opentofu**
- **Bitwarden Secrets Manager** account with machine account configured

## Secrets Management Architecture

### Ansible Vault
- Used for: Ansible-specific secrets, short-lived credentials (e.g., Tailscale auth keys)
- Password file: `ansible/vault/.vault_password` (auto-loaded, gitignored)
- Encrypted file: `ansible/inventory/group_vars/all/secrets.yaml`

### Bitwarden Secrets Manager
- Used for: Cross-tool secrets, API tokens, long-lived credentials
- Integration: Both Ansible playbooks and OpenTofu configurations
- Provider: `maxlaverse/bitwarden` with embedded client (no CLI dependency)

## Bitwarden + OpenTofu Integration

This setup uniquely integrates Bitwarden Secrets Manager directly into OpenTofu using the `maxlaverse/bitwarden` provider with embedded client mode.

### Initial Setup (One-time)

1. **Create Machine Account in Bitwarden**:
   - Navigate to Settings > Machine Accounts
   - Generate access token
   - **CRITICAL**: Grant machine account access to Projects containing secrets

2. **Store Secrets in Bitwarden**:
   - Organize secrets within Projects
   - Note Secret IDs (UUIDs) for OpenTofu configuration

3. **Configure Access Token**:
   ```bash
   # Add to ~/.bashrc (or ~/.zshrc)
   export TF_VAR_bws_access_token="your-access-token-here"

   # Reload shell
   source ~/.bashrc
   ```

### How It Works

**Authentication Flow**:
1. OpenTofu reads `TF_VAR_bws_access_token` from environment
2. Connects to Bitwarden via embedded client (no external CLI)
3. Fetches secrets using Secret IDs from `tofu.auto.tfvars`
4. Uses retrieved credentials to authenticate with infrastructure providers

**Key Files**:
- `providers.tofu`: Defines Cloudflare + Bitwarden providers
- `bitwarden.tofu`: Configures Bitwarden provider, fetches secrets via data sources
- `variables.tofu`: Variable declarations
- `tofu.auto.tfvars`: Secret IDs and zone IDs (safe to commit)
- `dns_records.tofu`: DNS A records defined in code (safe to commit)

**What Gets Committed**:
- ✅ Secret IDs (UUIDs) - just identifiers
- ✅ DNS records in code
- ✅ All `.tofu` configuration files
- ❌ Access tokens (environment variable only)
- ❌ Actual secret values (fetched at runtime)

## Cloudflare DNS Management

DNS records are defined in code using a `for_each` pattern in `opentofu/cloudflare/dns_records.tofu`:

```hcl
locals {
  a_records = {
    "subdomain" = {
      content = "192.0.2.1"
      proxied = true   # Cloudflare proxy (orange cloud)
      ttl     = 1      # Auto
    }
  }
}
```

This approach allows:
- Version-controlled infrastructure
- No secrets in configuration files
- Dynamic record creation from a map structure

## Available Playbooks

### OpenTofu Installation
**File**: `playbooks/common/install_opentofu.yaml`

Installs OpenTofu via official installer script using system package manager (apt).

### Tailscale VPN
**File**: `playbooks/common/install_tailscale.yaml`

Configures Tailscale with:
- Subnet routing with automatic IP forwarding
- Exit node functionality
- UDP GRO forwarding optimization

**Key Variables** (in Ansible Vault):
- `tailscale_auth_key`: Auth key from Tailscale admin console
- `tailscale_subnet_routes`: Comma-separated subnet routes (optional)

**Post-Install**: Approve routes and exit node in Tailscale admin console.

**Note**: Auth keys stored in Ansible Vault (not Bitwarden) because they're short-lived and only used once during initial connection.

### Bitwarden Secrets Manager CLI
**File**: `playbooks/common/install_bitwarden.yaml`

Installs native ARM64 `bws` CLI binary to `/opt/bitwarden/` with symlink at `/usr/local/bin/bws`.

**Key Variables** (in Ansible Vault):
- `bws_access_token`: Machine account access token

**Usage in Ansible**:
```yaml
- name: Get secret from Bitwarden
  shell: bws secret get <secret-id> --access-token "{{ bws_access_token }}" --output json
  register: result
  no_log: true

- name: Parse secret
  set_fact:
    secret_value: "{{ (result.stdout | from_json).value }}"
  no_log: true
```

### Caddy Web Server
**File**: `playbooks/common/install_caddy.yaml`

Installs Caddy with Cloudflare DNS plugin for automatic HTTPS via DNS-01 challenge.

**Installation Only**: Caddyfile configuration managed by OpenTofu (not Ansible).

**Key Variables** (in Ansible Vault):
- `cloudflare_api_token_secret_id`: Bitwarden secret ID
- `bws_access_token`: For fetching token from Bitwarden

**Integration**: OpenTofu manages both DNS records and Caddy reverse proxy configuration together.

## Configuration Files

### Cloudflare OpenTofu Module

All infrastructure configuration is stored in Bitwarden Secrets Manager. Update `opentofu/cloudflare/tofu.auto.tfvars` with Bitwarden secret IDs:

```hcl
# Bitwarden secret IDs for all infrastructure configuration
cloudflare_api_token_secret_id       = "uuid-from-bitwarden"
cloudflare_account_id_secret_id      = "uuid-from-bitwarden"
cloudflare_zone_id_secret_id         = "uuid-from-bitwarden"
homelab_reverse_proxy_ip_secret_id   = "uuid-from-bitwarden"
vps_reverse_proxy_ip_secret_id       = "uuid-from-bitwarden"
```

**Bitwarden Secrets to Create:**
1. Cloudflare API token
2. Cloudflare account ID
3. Cloudflare zone ID
4. Homelab reverse proxy IP address
5. VPS reverse proxy IP address

Add DNS records in `opentofu/cloudflare/dns_records.tofu`:
```hcl
locals {
  a_records = {
    # Internal services (homelab)
    "service1" = { content = local.homelab_reverse_proxy_ip }

    # External services (VPS)
    "service2" = { content = local.vps_reverse_proxy_ip, proxied = true }
  }
}
```

## Security

- **Ansible Vault**: Automatic password loading from `ansible/vault/.vault_password`
- **Bitwarden Access Token**: Environment variable only (`~/.bashrc`)
- **No Hardcoded Secrets**: All credentials fetched at runtime
- **Gitignored Files**: Vault passwords, state files, secrets.auto.tfvars

## Key Differences from Standard Setups

1. **Complete Bitwarden Integration**:
   - All infrastructure credentials in Bitwarden (API tokens, IDs, IP addresses)
   - Zero hardcoded values in repository
   - Repository fully anonymized - no identifying information
   - Dual secrets management: Ansible Vault for playbook secrets, Bitwarden for infrastructure

2. **OpenTofu Bitwarden Integration**:
   - Uses `maxlaverse/bitwarden` provider with embedded client
   - No external CLI dependency for OpenTofu
   - Direct server communication for better performance
   - Fetches 5 secrets at runtime: API token, account ID, zone ID, 2 reverse proxy IPs

3. **DNS Records in Code**:
   - DNS records defined in `.tofu` files using `for_each` pattern
   - IP addresses fetched from Bitwarden (local values, not hardcoded)
   - All configuration version controlled and safe to commit
   - Separation between internal (homelab) and external (VPS) services

4. **Caddy + OpenTofu Integration**:
   - Ansible installs Caddy web server
   - OpenTofu manages Caddyfile configuration (future work)
   - Unified DNS and reverse proxy management

## Reference

- [OpenTofu Documentation](https://opentofu.org/)
- [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/)
- [maxlaverse/bitwarden Provider](https://registry.terraform.io/providers/maxlaverse/bitwarden/latest/docs)
