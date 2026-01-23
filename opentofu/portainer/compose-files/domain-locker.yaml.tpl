services:
  db:
    image: postgres:15-alpine
    container_name: domain-locker-db
    restart: unless-stopped
    environment:
      - POSTGRES_USER=domain_locker
      - POSTGRES_PASSWORD=${db_password}
      - POSTGRES_DB=domain_locker
    volumes:
      - ${docker_data_path}/domain-locker/postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U domain_locker"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - domain-locker

  app:
    image: lissy93/domain-locker:latest
    container_name: domain-locker
    restart: unless-stopped
    ports:
      - 3030:3000
    environment:
      - DL_PG_HOST=domain-locker-db
      - DL_PG_PORT=5432
      - DL_PG_USER=domain_locker
      - DL_PG_NAME=domain_locker
      - DL_PG_PASSWORD=${db_password}
    depends_on:
      db:
        condition: service_healthy
    networks:
      - domain-locker

  updater:
    image: alpine:latest
    container_name: domain-locker-updater
    restart: unless-stopped
    command: >
      sh -c "echo '0 3 * * * wget -qO- http://domain-locker:3000/api/domain-updater' > /etc/crontabs/root &&
             echo '0 4 * * * wget -qO- http://domain-locker:3000/api/expiration-reminders' >> /etc/crontabs/root &&
             crond -f -l 2"
    depends_on:
      - app
    networks:
      - domain-locker

networks:
  domain-locker:
    name: domain-locker
    driver: bridge
