# n8n

n8n is a workflow automation platform that allows you to connect various services and automate tasks. It provides a visual workflow builder with support for hundreds of integrations.

## Deployment Details

- **URL**: https://n8n.example.com
- **Stack Location**: `opentofu/portainer/compose-files/n8n.yaml.tpl`
- **Deployment Endpoint**: docker_pve
- **DNS Management**: Cloudflare (proxied)
- **Reverse Proxy**: VPS Caddy instance via Tailscale
- **Container Port**: 5678
- **Network Mode**: Tailscale sidecar (shared network namespace)

## Stack Components

| Container | Image | Purpose |
|-----------|-------|---------|
| n8n-tailscale | tailscale/tailscale:latest | Tailscale VPN sidecar |
| n8n | docker.io/n8nio/n8n | Main workflow engine |
| n8n-postgres | postgres:16-alpine | PostgreSQL database |
| n8n-browserless | ghcr.io/browserless/chromium:latest | Browser automation service (Playwright/Puppeteer) |

All containers share the Tailscale network namespace via `network_mode: service:tailscale`, allowing n8n to access Tailscale devices (e.g., Ollama on a laptop) while maintaining local database connectivity.

## Required Bitwarden Secrets

| Secret Variable | Description |
|-----------------|-------------|
| `n8n_db_password` | PostgreSQL database password |
| `n8n_encryption_key` | Encryption key for credentials storage |
| `n8n_tailscale_auth_key` | Tailscale auth key for sidecar container |

**Generating Encryption Key**:
```bash
openssl rand -hex 32
```

**Creating Tailscale Auth Key**:
1. Go to https://login.tailscale.com/admin/settings/keys
2. Generate a new auth key with:
   - Reusable: Yes (allows container recreation)
   - Ephemeral: No (keeps node registered permanently)
   - Expiration: 90+ days
3. Store in Bitwarden Secrets Manager
4. Add the secret UUID to `opentofu/portainer/tofu.auto.tfvars`

## Initial Setup

1. Generate and store secrets in Bitwarden
2. Configure secret UUIDs in `opentofu/portainer/tofu.auto.tfvars`
3. Deploy the stack:
   ```bash
   cd opentofu/portainer
   tofu apply
   ```
4. Access https://n8n.example.com and create admin account
5. Configure integrations as needed

## Configuration

### Environment Variables

**n8n Container**:
| Variable | Value | Description |
|----------|-------|-------------|
| `DB_TYPE` | postgresdb | Database backend |
| `N8N_HOST` | n8n.${domain_name} | Public hostname |
| `N8N_PROTOCOL` | https | Protocol for webhooks |
| `WEBHOOK_URL` | https://n8n.${domain_name}/ | Webhook base URL |
| `NODE_ENV` | production | Runtime environment |
| `N8N_PROXY_HOPS` | 1 | Trust X-Forwarded-For from reverse proxy |

**Tailscale Container**:
| Variable | Value | Description |
|----------|-------|-------------|
| `TS_AUTHKEY` | ${tailscale_auth_key} | Tailscale authentication key |
| `TS_HOSTNAME` | n8n | Persistent hostname in tailnet |
| `TS_AUTO_UPDATE` | true | Enable Tailscale auto-updates |
| `TS_STATE_DIR` | /var/lib/tailscale | State persistence directory |

### Version Control

Version is controlled via `n8n_version` variable in OpenTofu. Update and run `tofu apply` to upgrade.

## Volume Mounts

| Purpose | Location |
|---------|----------|
| n8n data | `${n8n_data_path}` |
| Tailscale state | `${n8n_data_path}/tailscale` |
| Database | `${n8n_db_data_location}` |
| Timezone | `/etc/localtime` (read-only) |

## Connecting to Ollama via Tailscale

The Tailscale sidecar enables n8n to connect to Ollama running on other devices in your tailnet (e.g., a Windows laptop).

### Windows Ollama Setup

**1. Configure Ollama to Listen on All Interfaces**

Run PowerShell as Administrator:
```powershell
[System.Environment]::SetEnvironmentVariable('OLLAMA_HOST', '0.0.0.0', 'User')
```

**2. Restart Ollama**
- Right-click Ollama system tray icon → Exit
- Start Ollama again from Start menu

**3. Verify Ollama is Listening**
```powershell
netstat -an | findstr 11434
# Should show: TCP    0.0.0.0:11434
```

**4. Add Windows Firewall Rule**

Run PowerShell as Administrator:
```powershell
New-NetFirewallRule -DisplayName "Ollama API (Tailscale)" -Direction Inbound -Protocol TCP -LocalPort 11434 -Action Allow -RemoteAddress 100.64.0.0/10 -Profile Any
```

This allows incoming connections only from Tailscale network (100.64.0.0/10), maintaining security.

### n8n Configuration

**1. Find Your Device's Tailscale IP**

On Windows:
```powershell
tailscale ip -4
```

On Linux:
```bash
tailscale ip -4
```

**2. Configure Ollama Node in n8n**

In your n8n workflow:
- Add an Ollama node
- Set Base URL: `http://<device-tailscale-ip>:11434`
- Example: `http://100.x.x.x:11434` (use your device's actual Tailscale IP)

The n8n container can now access Ollama through the Tailscale network without exposing it to the internet.

### Troubleshooting

**Connection Timeout**:
- Verify Ollama is listening on `0.0.0.0:11434` (not `127.0.0.1:11434`)
- Check Windows Firewall rule is active: `Get-NetFirewallRule -DisplayName "Ollama API (Tailscale)"`
- Verify both devices are connected to Tailscale: `tailscale status`

**Test Connection**:
```bash
# On docker_pve host
docker exec -it n8n-tailscale curl http://100.x.x.x:11434/api/tags
# Replace 100.x.x.x with your laptop's actual Tailscale IP
```

## Browser Automation with Browserless

The stack includes Browserless for browser automation tasks like web scraping, screenshots, and PDF generation.

### Browserless Configuration

**Connection Details**:
- Base URL: `http://localhost:3000` (from within n8n workflows)
- API documentation: https://docs.browserless.io/

**Environment Variables**:
| Variable | Value | Description |
|----------|-------|-------------|
| `TIMEOUT` | 30000 | Browser operation timeout (30 seconds) |
| `CONCURRENT` | 3 | Maximum concurrent browser sessions |
| `MAX_QUEUE_LENGTH` | 10 | Maximum queued requests when at capacity |
| `PREBOOT_CHROME` | true | Pre-load Chrome for faster response times |
| `KEEP_ALIVE` | true | Reuse browser instances between requests |
| `ENABLE_CORS` | true | Allow CORS for n8n HTTP requests |

### Using Browserless in n8n Workflows

**HTTP Request Node Configuration**:

1. **Take Screenshot**:
   - Method: POST
   - URL: `http://localhost:3000/screenshot`
   - Body Type: JSON
   - Body:
     ```json
     {
       "url": "https://example.com",
       "options": {
         "fullPage": true,
         "type": "png"
       }
     }
     ```

2. **Generate PDF**:
   - Method: POST
   - URL: `http://localhost:3000/pdf`
   - Body Type: JSON
   - Body:
     ```json
     {
       "url": "https://example.com",
       "options": {
         "format": "A4",
         "printBackground": true
       }
     }
     ```

3. **Execute Custom Playwright Script**:
   - Method: POST
   - URL: `http://localhost:3000/chrome/execute`
   - Headers: `Content-Type: application/javascript`
   - Body: Raw JavaScript
     ```javascript
     export default async ({ page, context }) => {
       await page.goto('https://example.com');
       const title = await page.title();
       return { title };
     };
     ```

### Browserless Health Check

Browserless includes a health check endpoint:
- Endpoint: `/pressure`
- Returns system load and available sessions

### Resource Considerations

Browser automation is memory-intensive:
- Each Chrome instance uses ~100-300MB RAM
- With `CONCURRENT=3`, expect ~300-900MB usage
- Adjust `CONCURRENT` based on available system resources

### Browserless Troubleshooting

**Connection Timeout**:
- Verify browserless container is running: `docker ps | grep n8n-browserless`
- Check health: `docker exec n8n-browserless wget -qO- http://localhost:3000/pressure`
- Review logs: `docker logs n8n-browserless`

**Out of Memory**:
- Reduce `CONCURRENT` value
- Increase Docker host memory
- Check container memory usage: `docker stats n8n-browserless`

**Slow Performance**:
- Ensure `PREBOOT_CHROME=true` is set
- Check system resources on docker_pve
- Consider reducing `TIMEOUT` for faster failures

## Health Checks

All containers include health checks:

**n8n**:
- Endpoint: `/healthz`
- Interval: 30s
- Start period: 60s (allows for startup)

**PostgreSQL**:
- Command: `pg_isready`
- Interval: 10s

**Browserless**:
- Endpoint: `/pressure`
- Interval: 30s
- Start period: 30s

## Container Dependencies

The stack uses container dependencies to ensure proper startup order:

**n8n container** depends on:
- Tailscale (must start first to provide network namespace)
- PostgreSQL (must be healthy before n8n starts)

**PostgreSQL container** depends on:
- Tailscale (must start first to provide network namespace)

All containers share the Tailscale network namespace, which is why database connections use `localhost` instead of container names.

## Auto-Updates

**Container Images** (via Watchtower):
- Runs daily at 3:30 AM on docker_pve
- Automatically updates all containers including n8n, PostgreSQL, and Tailscale

**Tailscale Client** (built-in):
- Enabled via `TS_AUTO_UPDATE=true`
- Automatically updates Tailscale binary inside container
- Ensures latest Tailscale features and security fixes

## Important Notes

- **Encryption key is critical** - losing it means losing access to stored credentials
- **Webhooks** require the correct `WEBHOOK_URL` configuration
- **Database backups** recommended for workflow preservation
- **Tailscale auth key** should be reusable (allows container recreation) and non-ephemeral (persistent node)
- **Tailscale state** persisted to `${n8n_data_path}/tailscale` - maintains node identity across restarts
- **Network isolation** - n8n, PostgreSQL, and Tailscale share network namespace (`localhost` connectivity)
- **Python task runner** warning can be ignored unless you need Python-based n8n nodes

## Common Use Cases

- API integrations and data synchronization
- Scheduled tasks and cron jobs
- Event-driven automation
- Data transformation pipelines
- Notification workflows
- **Ollama/LLM integration** for AI-powered workflows via Tailscale network
- **Web scraping and automation** using Browserless for dynamic content
- **Screenshot and PDF generation** for reports and archival
- **Browser-based testing** for web applications

## References

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Integrations](https://n8n.io/integrations/)
- [n8n Community](https://community.n8n.io/)
- [Browserless Documentation](https://docs.browserless.io/)
- [Browserless GitHub](https://github.com/browserless/browserless)
