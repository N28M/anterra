services:
  n8n:
    container_name: n8n
    image: docker.io/n8nio/n8n:${n8n_version}
    restart: always
    ports:
      - "5678:5678"
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=n8n-postgres
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
    volumes:
      - ${n8n_data_path}:/home/node/.n8n
      - /etc/localtime:/etc/localtime:ro
    depends_on:
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
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8n -d n8n"]
      interval: 10s
      timeout: 5s
      retries: 5
