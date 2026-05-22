services:
  meilisearch:
    image: getmeili/meilisearch:v1.43.0
    container_name: meilisearch
    restart: unless-stopped
    ports:
      - 7700:7700
    environment:
      - MEILI_MASTER_KEY=${meili_master_key}
      - MEILI_ENV=production
      - MEILI_NO_ANALYTICS=true
    volumes:
      - ${docker_data_path}/meilisearch/data:/meili_data
    labels:
      - "com.centurylinklabs.watchtower.monitor-only=true"
