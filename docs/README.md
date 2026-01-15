# Service Documentation

This directory contains detailed documentation for all deployed services in the Anterra homelab.

## Services by Category

### Home Automation

| Service | Description | Deployment |
|---------|-------------|------------|
| [Home Assistant](services/homeassistant.md) | Home automation platform | Proxmox VM |

### Media Management

| Service | Description | Deployment |
|---------|-------------|------------|
| [Immich](services/immich.md) | Photo and video management with AI | docker_pve |
| [Jellyfin](services/jellyfin.md) | Media streaming server with hardware transcoding | Proxmox VM (mediacenter) |
| [Karakeep](services/karakeep.md) | Bookmark manager with AI tagging | docker_pve2 |
| Plex Media Server | Media streaming server with hardware transcoding | Proxmox VM (mediacenter) |
| [Zerobyte](services/zerobyte.md) | Backup and snapshot solution | docker_pve2 |

### Automation

| Service | Description | Deployment |
|---------|-------------|------------|
| [n8n](services/n8n.md) | Workflow automation platform with Tailscale sidecar | docker_pve |
| [Watchtower](services/watchtower.md) | Container auto-updater | Both endpoints |

### Utilities

| Service | Description | Deployment |
|---------|-------------|------------|
| [BentoPDF](services/bentopdf.md) | Client-side PDF manipulation | docker_pve2 |
| [FileBrowser](services/filebrowser.md) | Web-based file management | docker_pve2 |

### Networking

| Service | Description | Deployment |
|---------|-------------|------------|
| [Gluetun](services/gluetun.md) | VPN container with 9 tunneled services | docker_pve2 |
| [Tailscale + AirVPN](services/tailscale-airvpn.md) | Secure exit node via VPN | docker_pve2 |

## Deployment Endpoints

| Endpoint | Description | Services |
|----------|-------------|----------|
| docker_pve | Primary Docker host | Immich, n8n, Watchtower |
| docker_pve2 | Secondary Docker host | Most services |
| Proxmox VM | Standalone virtual machine | Home Assistant |

## Quick Reference

### Services with External Access (VPS Reverse Proxy)

- Home Assistant (homeassistant.example.com)
- Immich (immich.example.com) - DNS-only mode
- Jellyfin (jellyfin.example.com) - DNS-only mode
- Karakeep (keep.example.com)
- n8n (n8n.example.com)
- Plex (plex.example.com) - DNS-only mode
- BentoPDF (bento.example.com)
- FileBrowser (files.example.com)
- Jellyseerr (seerr.example.com)

### Services with Internal Access Only (Homelab Reverse Proxy)

- Zerobyte
- Gluetun stack services (Radarr, Sonarr, Prowlarr, etc.)

### Services Without Web Interface

- Watchtower (background service)
- Tailscale + AirVPN (accessed via Tailscale network)

## Adding New Service Documentation

When adding a new service, create a markdown file in `services/` following this template:

```markdown
# Service Name

Brief description of the service.

## Deployment Details

- **URL**: https://service.example.com
- **Stack Location**: `opentofu/portainer/compose-files/service.yaml.tpl`
- **Deployment Endpoint**: docker_pve2
- **DNS Management**: Cloudflare (proxied/DNS-only)
- **Reverse Proxy**: VPS/Homelab Caddy
- **Container Port**: XXXX

## Stack Components

[List of containers]

## Required Bitwarden Secrets

[Secret variables and descriptions]

## Initial Setup

[Numbered setup steps]

## Important Notes

[Critical information]

## References

[Official documentation links]
```

Then update this README to include the new service in the appropriate category.
