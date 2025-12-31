services:
  web:
    image: ghcr.io/karakeep-app/karakeep:${karakeep_version}
    container_name: karakeep
    restart: unless-stopped
    volumes:
      - ${docker_data_path}/karakeep:/data
    ports:
      - 3000:3000
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - TZ=${docker_timezone}
      - MEILI_ADDR=http://karakeep-meilisearch:7700
      - BROWSER_WEB_URL=http://karakeep-chrome:9222
      - DATA_DIR=/data
      - NEXTAUTH_SECRET=${nextauth_secret}
      - NEXTAUTH_URL=${nextauth_url}
      - MEILISEARCH_MASTER_KEY=${meilisearch_master_key}
      - DISABLE_SIGNUPS=true
      - OPENAI_API_KEY=${openai_api_key}
      - INFERENCE_TEXT_MODEL=gpt-4o-mini
      - INFERENCE_IMAGE_MODEL=gpt-4o-mini
    depends_on:
      - chrome
      - meilisearch
    networks:
      - karakeep

  chrome:
    image: gcr.io/zenika-hub/alpine-chrome:latest
    container_name: karakeep-chrome
    restart: unless-stopped
    command:
      - --no-sandbox
      - --disable-gpu
      - --disable-dev-shm-usage
      - --remote-debugging-address=0.0.0.0
      - --remote-debugging-port=9222
      - --hide-scrollbars
    networks:
      - karakeep

  meilisearch:
    image: getmeili/meilisearch:latest
    container_name: karakeep-meilisearch
    restart: unless-stopped
    environment:
      - MEILI_NO_ANALYTICS=true
      - MEILI_MASTER_KEY=${meilisearch_master_key}
    volumes:
      - ${docker_data_path}/karakeep-meilisearch:/meili_data
    networks:
      - karakeep

networks:
  karakeep:
    name: karakeep
    driver: bridge
