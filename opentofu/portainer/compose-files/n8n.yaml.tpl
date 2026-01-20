# Tailscale sidecar provides VPN connectivity to n8n
# All containers share the Tailscale network namespace via network_mode: service:tailscale
# This allows n8n to access Tailscale devices (e.g., Ollama on laptop) while maintaining local database connectivity
services:
  tailscale:
    container_name: n8n-tailscale
    image: tailscale/tailscale:latest
    restart: always
    hostname: n8n
    environment:
      - TS_AUTHKEY=${tailscale_auth_key}
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_HOSTNAME=n8n
      - TS_USERSPACE=false
      - TS_AUTO_UPDATE=true
    volumes:
      - ${n8n_data_path}/tailscale:/var/lib/tailscale
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    ports:
      - "5678:5678"
      - "3000:3000"

  n8n:
    container_name: n8n
    image: docker.io/n8nio/n8n:${n8n_version}
    restart: always
    network_mode: service:tailscale
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=localhost
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=${n8n_db_password}
      - N8N_ENCRYPTION_KEY=${n8n_encryption_key}
      - N8N_HOST=n8n.${domain_name}
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://n8n.${domain_name}/
      - GENERIC_TIMEZONE=${docker_timezone}
      - TZ=${docker_timezone}
      - NODE_ENV=production
      - N8N_PROXY_HOPS=1
    volumes:
      - ${n8n_data_path}:/home/node/.n8n
      - /etc/localtime:/etc/localtime:ro
    depends_on:
      tailscale:
        condition: service_started
      n8n-postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget --spider -q http://localhost:5678/healthz || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  n8n-postgres:
    container_name: n8n_postgres
    image: postgres:16-alpine
    restart: always
    network_mode: service:tailscale
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - POSTGRES_DB=n8n
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=${n8n_db_password}
      - POSTGRES_NON_ROOT_USER=n8n
      - POSTGRES_NON_ROOT_PASSWORD=${n8n_db_password}
    volumes:
      - ${n8n_db_data_location}:/var/lib/postgresql/data
    depends_on:
      tailscale:
        condition: service_started
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8n -d n8n"]
      interval: 10s
      timeout: 5s
      retries: 5

  browserless:
    container_name: n8n-browserless
    image: ghcr.io/browserless/chromium:latest
    restart: always
    network_mode: service:tailscale
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - TIMEOUT=30000
      - CONCURRENT=3
      - MAX_QUEUE_LENGTH=10
      - PREBOOT_CHROME=true
      - KEEP_ALIVE=true
      - ENABLE_CORS=true
    depends_on:
      tailscale:
        condition: service_started
    healthcheck:
      test: ["CMD-SHELL", "wget --spider -q http://localhost:3000/pressure || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
