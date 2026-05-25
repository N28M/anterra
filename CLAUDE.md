# CLAUDE.md

Anterra: Infrastructure as Code repository using Ansible + OpenTofu + Bitwarden Secrets Manager.

## Execution Policy

**NEVER execute automation commands without explicit user permission.**

- DO NOT run `ansible-playbook`, `tofu apply`, `tofu destroy`, or any system-changing commands
- DO prepare commands for the user to run and explain what they do
- Read-only commands are fine without permission: file reads, `grep`/`ls`, `git status|diff|log`, `tofu plan|validate|show|output`, and read-only state inspection over SSH (`zpool status`, `zfs list|get`, `docker ps|inspect|logs`, `qm/pct config|list|status`, `systemctl status`, `journalctl`, `smartctl -a`). System-changing variants of these still require permission.

## Vault Access Policy

**DO NOT view, read, or decrypt the vault file under any circumstances.**

- Never use `ansible-vault view` or read the secrets file or vault password file
- Ask the user for vault variable names if needed

## Architecture

- **OpenTofu** (`opentofu/`): Infrastructure provisioning
  - `cloudflare/`: DNS records (defined in `dns_records.tofu` with `for_each`)
  - `portainer/`: Container stacks (compose templates in `compose-files/`, deployed via `stacks.tofu`)
- **Ansible** (`ansible/`): Configuration management
  - Run all commands from `ansible/` directory
  - Playbooks organized by: `common/`, `caddy/`, `proxmox/`, `gluetun/`, `issue-fixes/`
  - Caddy reverse proxy config managed via Jinja2 template + YAML data file
- **Bitwarden**: All secrets fetched at runtime; zero credentials in repo
- **Proxmox**: Manual VM creation; Ansible handles post-creation config

## Commands

### Ansible (from `ansible/` directory)

```bash
ansible-playbook -i inventory/hosts.yaml playbooks/<playbook>.yaml
ansible-playbook --check -i inventory/hosts.yaml playbooks/<playbook>.yaml  # dry run
ansible-vault edit inventory/group_vars/all/secrets.yaml
```

### OpenTofu

```bash
cd opentofu/cloudflare && tofu init && tofu plan && tofu apply
cd opentofu/portainer && tofu init && tofu plan && tofu apply
```

## Deployment Order (New Services)

1. Caddy -- update reverse proxy config
2. Cloudflare -- deploy DNS records
3. Portainer -- deploy container stack

## Gotchas

- **pve Intel NIC (e1000e)**: The Intel I219 NIC on pve suffers from "Detected Hardware Unit Hang" under sustained load (e.g. Plex streaming). Fix applied via `playbooks/proxmox/server/pve_fix_intel_nic_issue.yaml` -- disables TSO/GSO/GRO, increases ring buffers to 4096, disables EEE advertisement. A systemd service persists the settings across reboots. pve2 uses a Realtek NIC and is not affected.
- **Cloudflare proxy**: Media services (Plex, Jellyfin, Immich) MUST use DNS-only (`proxied = false`). Cloudflare ToS prohibits video/media through free CDN.
- **SMB mounts**: Setup playbooks create systemd mount units. Docker/Plex won't start without successful mounts.
- **Automation first**: Fix issues through playbooks/OpenTofu, not manual changes. Rerun automation before debugging.
- **Docker Compose**: Omit `version:` field (deprecated).
- **Playbook style**: No long `debug: msg:` blocks; use YAML comments instead.
- **Bitwarden access**: Machine accounts need project-level access in Bitwarden Secrets Manager, not just a valid token.

## Key Files

- `ansible/ansible.cfg` -- vault password file location
- `ansible/inventory/hosts.yaml` -- managed hosts
- `ansible/inventory/group_vars/all/secrets.yaml` -- encrypted secrets
- `opentofu/cloudflare/dns_records.tofu` -- all DNS A records
- `opentofu/portainer/stacks.tofu` -- container stack definitions
- `opentofu/portainer/compose-files/` -- Docker Compose templates

## Managed Hosts

Hosts with SMB mount dependencies: `docker_pve`, `docker_pve2`, `mediacenter` (Plex)

## Code Style

No emoji in documentation, code, or commits.

## Documentation

- Service docs: `docs/services/` (one file per service)
- Do NOT create subdirectory READMEs or document basic Ansible/OpenTofu usage
