services:
  postgres:
    image: postgres:16-alpine
    container_name: reactive-resume-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${db_password}
    volumes:
      - ${docker_data_path}/reactive-resume/postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres", "-d", "postgres"]
      start_period: 10s
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - reactive-resume

  browserless:
    image: ghcr.io/browserless/chromium:latest
    container_name: reactive-resume-browserless
    restart: unless-stopped
    environment:
      - QUEUED=30
      - TIMEOUT=300000
      - HEALTH=true
      - CONCURRENT=20
      - TOKEN=reactive-resume-token
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/pressure?token=reactive-resume-token"]
      interval: 10s
      timeout: 5s
      retries: 10
    networks:
      - reactive-resume

  seaweedfs:
    image: chrislusf/seaweedfs:latest
    container_name: reactive-resume-seaweedfs
    restart: unless-stopped
    command: server -s3 -filer -dir=/data -ip=0.0.0.0
    environment:
      - AWS_ACCESS_KEY_ID=seaweedfs
      - AWS_SECRET_ACCESS_KEY=seaweedfs
    volumes:
      - ${docker_data_path}/reactive-resume/seaweedfs:/data
    healthcheck:
      test: ["CMD", "wget", "-q", "-O", "/dev/null", "http://localhost:8888"]
      start_period: 10s
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - reactive-resume

  seaweedfs-create-bucket:
    image: quay.io/minio/mc:latest
    container_name: reactive-resume-seaweedfs-create-bucket
    restart: on-failure
    entrypoint: >
      /bin/sh -c "
      sleep 5;
      mc alias set seaweedfs http://reactive-resume-seaweedfs:8333 seaweedfs seaweedfs;
      mc mb seaweedfs/reactive-resume;
      exit 0;
      "
    depends_on:
      seaweedfs:
        condition: service_healthy
    networks:
      - reactive-resume

  app:
    image: amruthpillai/reactive-resume:latest
    container_name: reactive-resume
    restart: unless-stopped
    ports:
      - 3100:3000
    environment:
      - TZ=${docker_timezone}
      - NODE_ENV=production
      - APP_URL=${app_url}
      - PRINTER_APP_URL=http://reactive-resume:3000
      - PRINTER_ENDPOINT=ws://reactive-resume-browserless:3000?token=reactive-resume-token
      - DATABASE_URL=postgresql://postgres:${db_password}@reactive-resume-postgres:5432/postgres
      - AUTH_SECRET=${auth_secret}
      - S3_ACCESS_KEY_ID=seaweedfs
      - S3_SECRET_ACCESS_KEY=seaweedfs
      - S3_ENDPOINT=http://reactive-resume-seaweedfs:8333
      - S3_BUCKET=reactive-resume
      - S3_FORCE_PATH_STYLE=true
    volumes:
      - ${docker_data_path}/reactive-resume/data:/app/data
    depends_on:
      postgres:
        condition: service_healthy
      browserless:
        condition: service_healthy
      seaweedfs-create-bucket:
        condition: service_completed_successfully
    healthcheck:
      test: ["CMD", "node", "-e", "require('http').get('http://localhost:3000/api/health', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"]
      start_period: 10s
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - reactive-resume

networks:
  reactive-resume:
    name: reactive-resume
    driver: bridge
