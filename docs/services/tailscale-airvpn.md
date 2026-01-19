# Tailscale + AirVPN Exit Node

This stack combines Gluetun VPN with Tailscale to create a secure exit node. Traffic from Tailscale clients using this exit node is routed through AirVPN, providing an additional layer of privacy.

## Deployment Details

- **Stack Location**: `opentofu/portainer/compose-files/tailscale-airvpn.yaml.tpl`
- **Deployment Endpoint**: docker_pve2
- **DNS Management**: Not required (accessed via Tailscale network)
- **Tailscale Hostname**: tailscale-airvpn

## Architecture

```
Tailscale Client -> Tailscale Exit Node -> Gluetun VPN -> AirVPN -> Internet
```

- **Gluetun Container**: Handles VPN connectivity via AirVPN (WireGuard protocol)
- **Tailscale Container**: Runs in `network_mode: "service:gluetun"` to route all traffic through the VPN

## Stack Components

| Container | Image | Purpose |
|-----------|-------|---------|
| gluetun | qmcgaw/gluetun:latest | VPN tunnel to AirVPN |
| tailscale | tailscale/tailscale:latest | Exit node for Tailscale network |

Container names use `-ts` suffix to distinguish from the regular gluetun stack:
- `gluetun-ts`
- `tailscale-ts`

## Required Bitwarden Secrets

| Secret Variable | Description |
|-----------------|-------------|
| `tailscale_auth_key_uuid` | Tailscale authentication key |
| `ts_wireguard_private_key` | WireGuard private key from AirVPN config generator |
| `ts_wireguard_preshared_key` | WireGuard preshared key from AirVPN config generator |
| `ts_wireguard_addresses` | WireGuard VPN address (e.g., 10.128.x.x/32) |

## AirVPN WireGuard Setup

This stack uses separate AirVPN WireGuard credentials from the regular gluetun stack:

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
   ts_wireguard_private_key_secret_id   = "your-uuid-here"
   ts_wireguard_preshared_key_secret_id = "your-uuid-here"
   ts_wireguard_addresses_secret_id     = "your-uuid-here"
   ```

## Initial Setup

1. Generate WireGuard configuration from AirVPN (see WireGuard Setup above)
2. Store WireGuard credentials in Bitwarden Secrets Manager
3. Create a reusable Tailscale auth key:
   - Go to Tailscale admin console > Settings > Keys
   - Create a reusable auth key
   - Store in Bitwarden and note the UUID
4. Update `opentofu/portainer/tofu.auto.tfvars` with all secret UUIDs:
   ```hcl
   tailscale_auth_key_uuid              = "your-bitwarden-uuid"
   ts_wireguard_private_key_secret_id   = "your-uuid-here"
   ts_wireguard_preshared_key_secret_id = "your-uuid-here"
   ts_wireguard_addresses_secret_id     = "your-uuid-here"
   ```
5. Deploy the stack:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
6. Verify VPN connection in gluetun-ts container logs (look for WireGuard handshake success)
7. In Tailscale admin console:
   - Verify the exit node is visible and online
   - Enable it as an exit node (requires manual approval)
8. On Tailscale clients, select this exit node in Settings

## Volume Mounts

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/gluetun` | `${docker_config_path}/tailscale-airvpn/gluetun` | VPN configuration |
| `/var/lib/tailscale` | `${docker_config_path}/tailscale-airvpn/tailscale` | Tailscale state |

## Tailscale Configuration

| Setting | Value | Description |
|---------|-------|-------------|
| `TS_HOSTNAME` | tailscale-airvpn | Device name in Tailscale |
| `TS_EXTRA_ARGS` | --advertise-exit-node | Advertise as exit node |
| `TS_STATE_DIR` | /var/lib/tailscale | Persistent state location |

## Important Notes

- Uses **separate AirVPN WireGuard credentials** from the regular gluetun stack
- Each stack can use a different AirVPN account if needed
- Exit node must be manually enabled in Tailscale admin console
- Tailscale auth keys expire separately from node keys
- If auth key expires, generate a new one and redeploy
- WireGuard provides better performance and stability than OpenVPN

## Troubleshooting

**Exit node not appearing in Tailscale**:
1. Check gluetun-ts logs for WireGuard handshake success
2. Check tailscale-ts logs for authentication errors
3. Verify auth key is valid and not expired

**VPN not connecting**:
1. Verify WireGuard credentials are correct in Bitwarden
2. Check that all three WireGuard secrets are set (private key, preshared key, address)
3. Review gluetun-ts container logs for connection errors

## References

- [Tailscale Exit Nodes](https://tailscale.com/kb/1103/exit-nodes/)
- [Gluetun Documentation](https://github.com/qdm12/gluetun-wiki)
- [AirVPN](https://airvpn.org/)
- [Architecture Guide](https://fathi.me/unlock-secure-freedom-route-all-traffic-through-tailscale-gluetun/)
