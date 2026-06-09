services:
  db:
    image: postgres:17
    container_name: chessalytic-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: chessalytic
      POSTGRES_USER: chessalytic
      POSTGRES_PASSWORD: ${db_password}
    volumes:
      - ${docker_data_path}/chessalytic/postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U chessalytic"]
      interval: 5s
      timeout: 5s
      retries: 10
    networks:
      - chessalytic

  app:
    image: ghcr.io/iteratium/chessalytic:latest
    container_name: chessalytic
    restart: unless-stopped
    ports:
      - "3001:3001"
    environment:
      DB_HOST: chessalytic-db
      DB_PORT: 5432
      DB_NAME: chessalytic
      DB_USER: chessalytic
      DB_PASSWORD: ${db_password}
      SERVER_PORT: 3001
      NODE_ENV: production
      AI_ENCRYPTION_KEY: ${ai_encryption_key}
    depends_on:
      db:
        condition: service_healthy
    networks:
      - chessalytic

networks:
  chessalytic:
    name: chessalytic
    driver: bridge
