# Gluetun VPN Stack

Gluetun is a VPN container that provides a secure tunnel for multiple services. All containers in this stack route their traffic through the Gluetun VPN connection using `network_mode: "service:gluetun"`.

## Deployment Details

- **Stack Location**: `opentofu/portainer/compose-files/gluetun.yaml.tpl`
- **Deployment Endpoint**: docker_pve2
- **DNS Management**: Individual services have their own DNS records (see below)
- **VPN Provider**: AirVPN (WireGuard protocol)
- **VPN Server Location**: Netherlands

## Stack Components

| Container | Image | Port | DNS Record |
|-----------|-------|------|------------|
| gluetun | qmcgaw/gluetun:latest | - | - |
| qbittorrent | lscr.io/linuxserver/qbittorrent | 8585 | qbittorrent |
| jellyseerr | fallenbagel/jellyseerr | 5055 | seerr |
| prowlarr | lscr.io/linuxserver/prowlarr | 9696 | prowlarr |
| flaresolverr | ghcr.io/flaresolverr/flaresolverr | 8191 | flaresolverr |
| radarr | lscr.io/linuxserver/radarr | 7878 | radarr |
| sonarr | lscr.io/linuxserver/sonarr | 8989 | sonarr |
| bazarr | lscr.io/linuxserver/bazarr | 6767 | bazarr |
| librewolf | lscr.io/linuxserver/librewolf | 3080 | browser |
| profilarr | santiagosayshey/profilarr | 6868 | profilarr |

## Required Bitwarden Secrets

| Secret Variable | Description |
|-----------------|-------------|
| `wireguard_private_key` | WireGuard private key from AirVPN config generator |
| `wireguard_preshared_key` | WireGuard preshared key from AirVPN config generator |
| `wireguard_addresses` | WireGuard VPN address (e.g., 10.128.x.x/32) |
| `vpn_input_port` | AirVPN forwarded port (e.g., 53594) |
| `outbound_subnet` | Allowed outbound subnet for VPN firewall |
| `git_user_name` | Git username for Profilarr |
| `git_user_email` | Git email for Profilarr |
| `profilarr_pat` | Personal Access Token for Profilarr GitHub sync |

## AirVPN WireGuard Setup

AirVPN uses WireGuard for better performance and stability compared to OpenVPN.

1. Go to https://airvpn.org/generator/
2. Select **WireGuard** protocol
3. Choose your preferred server location (Netherlands)
4. Generate and download the configuration
5. Extract these values from the generated config file:
   - `PrivateKey` - Your WireGuard private key
   - `PresharedKey` - The preshared key for additional security
   - `Address` - Your assigned VPN address (e.g., 10.128.x.x/32)
6. Store each value as a separate secret in Bitwarden Secrets Manager
7. Add the Bitwarden secret UUIDs to `opentofu/portainer/tofu.auto.tfvars`:
   ```hcl
   wireguard_private_key_secret_id   = "your-uuid-here"
   wireguard_preshared_key_secret_id = "your-uuid-here"
   wireguard_addresses_secret_id     = "your-uuid-here"
   ```

## Initial Setup

1. Configure AirVPN certificates (see above)
2. Deploy the stack via OpenTofu:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
3. Verify VPN connection in Gluetun container logs
4. Configure individual services through their web interfaces

## Service Configuration Notes

### qBittorrent
- WebUI on port 8585
- Downloads to `${docker_downloads_path}`
- Uses AirVPN forwarded port for better connectivity

### Radarr / Sonarr
- Movie and TV show management
- Connect to qBittorrent for downloads
- Media stored in `${docker_media_path}/movies` and `${docker_media_path}/tv`

### Prowlarr
- Indexer manager for Radarr/Sonarr
- FlareSolverr integration for Cloudflare-protected sites

### Jellyseerr
- Media request management
- Accessible at `seerr.example.com`

### Bazarr
- Subtitle management for Radarr/Sonarr
- Automatic subtitle downloads

### Profilarr
- Quality profile synchronization
- Syncs profiles via GitHub repository

### LibreWolf
- Privacy-focused browser accessible via web
- Useful for accessing sites through VPN

## Important Notes

- All services share Gluetun's network stack
- If Gluetun stops, all tunneled services lose connectivity
- VPN connection verified via container logs: look for WireGuard handshake success
- Port forwarding through AirVPN improves torrent connectivity
- WireGuard provides better performance and stability than OpenVPN, with lower CPU usage and faster reconnections

## References

- [Gluetun Documentation](https://github.com/qdm12/gluetun-wiki)
- [AirVPN](https://airvpn.org/)
- [LinuxServer.io Containers](https://docs.linuxserver.io/)
