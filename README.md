# Anterra

Infrastructure as Code (IaC) repository for managing and provisioning infrastructure using Ansible and OpenTofu.

## Overview

Anterra provides a centralized platform for:
- Configuration management and automation via Ansible
- Infrastructure provisioning for Cloudflare and Portainer via OpenTofu
- Secure secrets management using Ansible Vault and Bitwarden Secrets Manager

## Project Structure

```
anterra/
├── ansible/                              # Ansible configuration management
│   ├── ansible.cfg                       # Ansible configuration
│   ├── inventory/                        # Host and group definitions
│   │   ├── hosts.yaml                    # Inventory of target hosts
│   │   ├── group_vars/all/secrets.yaml   # Encrypted group variables (Ansible Vault)
│   │   └── host_vars/                    # Host-specific variables
│   ├── playbooks/                        # Ansible playbooks
│   │   └── common/                       # Common playbooks for all hosts
│   │       ├── install_tailscale.yaml    # Tailscale installation and configuration
│   │       └── install_bitwarden.yaml    # Bitwarden Secrets Manager CLI installation
│   └── vault/                            # Ansible vault configuration
│       └── .vault_password               # Vault password file (gitignored)
└── opentofu/                             # OpenTofu infrastructure as code
    ├── cloudflare/                       # Cloudflare infrastructure
    └── portainer/                        # Portainer container orchestration
```

## Prerequisites

The following dependencies are required for this setup:

- **git** - Version control
- **tree** - Directory structure visualization
- **btop** - System resource monitoring
- **npm** - Node package manager (used for installing Claude Code)
- **pipx** - Python application installer (for installing Ansible in isolated environments)
- **ansible** - Configuration management (installed via pipx without sudo)
- **opentofu** - Infrastructure provisioning (open-source Terraform alternative)
- Access credentials for target infrastructure (Cloudflare, Portainer, etc.)

## Getting Started

### Ansible Configuration

1. Configure target hosts in `ansible/inventory/hosts.yaml`
2. Set vault password in `ansible/vault/.vault_password`
3. Create playbooks in `ansible/playbooks/`
4. Store secrets in `ansible/inventory/group_vars/all/secrets.yaml` (encrypted with Ansible Vault)

### Running Ansible Playbooks

```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/<playbook-name>.yaml
```

### Available Playbooks

#### Tailscale Installation and Configuration

**File**: `ansible/playbooks/common/install_tailscale.yaml`

Installs and configures Tailscale with support for:
- Automatic updates
- Subnet routing with automatic IP forwarding
- Exit node functionality
- UDP GRO forwarding optimization for improved performance on international connections

**Prerequisites**:

Before running the playbook, generate an authentication key:
1. Visit: https://login.tailscale.com/admin/settings/keys
2. Create a new authentication key
3. Add it to your vault secrets:
   ```bash
   cd ansible
   ansible-vault edit inventory/group_vars/all/secrets.yaml
   ```
4. Add the key: `tailscale_auth_key: "tskey-your-key-here"`
5. (Optional) Add subnet routes: `tailscale_subnet_routes: "192.0.2.0/24,198.51.100.0/24"`

**Basic Usage**:

Run the playbook with default configuration:
```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/common/install_tailscale.yaml
```

Disable features as needed:
```bash
# Disable subnet router
ansible-playbook -i inventory/hosts.yaml playbooks/common/install_tailscale.yaml \
  -e "enable_subnet_router=false"

# Disable exit node
ansible-playbook -i inventory/hosts.yaml playbooks/common/install_tailscale.yaml \
  -e "enable_exit_node=false"
```

**Post-Playbook Setup**:

After running the playbook, complete these steps in the Tailscale admin console:

1. Visit: https://login.tailscale.com/admin/machines
2. Find your device and open its settings
3. Navigate to "Route settings"
4. Approve the advertised subnet routes
5. Approve the exit node setting

**For Headless/Unattended Devices**:
- In device settings, toggle OFF "Key expiry" to prevent authentication failures
- This is recommended for servers and Raspberry Pi running Tailscale unattended

**Performance Optimization**:
The playbook automatically optimizes UDP GRO forwarding for improved throughput on exit node and subnet router traffic, especially beneficial for international connections.

**Notes**:
- If running locally on the device, you may experience brief network disconnection - this is normal
- Auth keys expire separately from node keys - renew them when needed
- **Why store Tailscale auth key in Ansible Vault instead of Bitwarden**: While it's possible to fetch the auth key from Bitwarden Secrets Manager, it's not recommended because:
  - Tailscale auth keys are short-lived
  - Auth keys are only used once during initial node connection
  - Once connected, Tailscale uses machine-generated keys for ongoing authentication
  - Storing in Ansible Vault is simpler and avoids unnecessary dependency on external secrets management
- See detailed documentation at: [Tailscale Performance Best Practices](https://tailscale.com/kb/1320/performance-best-practices)

**Reference**: [Tailscale Documentation](https://tailscale.com/)

#### Bitwarden Secrets Manager CLI Installation

**File**: `ansible/playbooks/common/install_bitwarden.yaml`

Installs the Bitwarden Secrets Manager CLI (bws) for managing secrets across Ansible playbooks and OpenTofu configurations. This provides an alternative to Ansible Vault for secrets that need to be shared across multiple tools or teams.

**Features**:
- Downloads and installs the ARM64 Linux native binary
- Installs to `/opt/bitwarden/` with system-wide symlink at `/usr/local/bin/bws`
- Verifies installation with version check
- Enables secrets retrieval in both Ansible and OpenTofu workflows

**Prerequisites**:

1. Set up a Bitwarden Secrets Manager machine account:
   - Log in to your Bitwarden organization
   - Navigate to Settings > Machine Accounts
   - Create a new machine account and generate an access token
   - **CRITICAL**: Grant the machine account access to the Projects containing your secrets
     - In Bitwarden Secrets Manager, secrets must be organized within Projects
     - The machine account cannot access any secrets unless explicitly granted access to their Projects
     - Go to the machine account settings and add the required Projects under "Access"
     - Without project access, bws commands will fail even with a valid access token

2. Store the access token in Ansible Vault:
   ```bash
   cd ansible
   ansible-vault edit inventory/group_vars/all/secrets.yaml
   ```
   Add: `bws_access_token: "your-access-token-here"`

**Basic Usage**:

Run the playbook to install the CLI:
```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/common/install_bitwarden.yaml
```

**Using bws in Ansible Playbooks**:

Retrieve secrets directly in tasks:
```yaml
- name: Get database password from Bitwarden
  shell: bws secret get <secret-id> --access-token "{{ bws_access_token }}" --output json
  register: db_password_result
  no_log: true

- name: Parse secret value
  set_fact:
    db_password: "{{ (db_password_result.stdout | from_json).value }}"
  no_log: true
```

Or set the environment variable for simplified access:
```yaml
environment:
  BWS_ACCESS_TOKEN: "{{ bws_access_token }}"
tasks:
  - name: Get secret
    shell: bws secret get <secret-id> --output json
```

**Using bws with OpenTofu**:

**Option 1: External Data Source** (uses bws CLI)
```hcl
data "external" "bitwarden_secret" {
  program = ["bws", "secret", "get", var.secret_id, "--output", "json"]

  # Set access token via environment variable
  environment = {
    BWS_ACCESS_TOKEN = var.bws_access_token
  }
}

# Access the secret value
locals {
  secret_value = data.external.bitwarden_secret.result.value
}
```

**Option 2: Official Provider** (recommended, uses Go SDK)
```hcl
terraform {
  required_providers {
    bitwarden-secrets = {
      source  = "bitwarden/bitwarden-secrets"
      version = "~> 0.1"
    }
  }
}

provider "bitwarden-secrets" {
  access_token = var.bws_access_token
}

data "bitwarden-secrets_secret" "example" {
  id = var.secret_id
}

# Use the secret
resource "example_resource" "foo" {
  password = data.bitwarden-secrets_secret.example.value
}
```

**Notes**:
- The Python SDK (`bitwarden-sdk`) is NOT used due to ARM64 compatibility issues
- Only the native CLI binary is installed
- Secret IDs can be found in the Bitwarden Secrets Manager web interface
- Access tokens should be treated as highly sensitive credentials
- For OpenTofu, the official provider is recommended as it uses the Go SDK internally

**Reference**:
- [Bitwarden Secrets Manager CLI Documentation](https://bitwarden.com/help/secrets-manager-cli/)
- [Bitwarden Terraform Provider](https://github.com/bitwarden/terraform-provider-bitwarden-secrets)

### OpenTofu Configuration

#### Cloudflare
```bash
cd opentofu/cloudflare
tofu init
tofu plan
tofu apply
```

#### Portainer
```bash
cd opentofu/portainer
tofu init
tofu plan
tofu apply
```

## Security

- Ansible Vault is configured for managing sensitive data
- Vault password file is excluded from version control via `.gitignore`
- Never commit unencrypted secrets to the repository

## Contributing

1. Create feature branches for new infrastructure configurations
2. Test playbooks and OpenTofu plans before applying
3. Document any new infrastructure components
4. Ensure secrets are properly encrypted before committing

## License

This repository is for internal infrastructure management.