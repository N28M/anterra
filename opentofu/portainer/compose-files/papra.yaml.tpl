services:
  papra:
    image: ghcr.io/papra-hq/papra:latest
    container_name: papra
    restart: unless-stopped
    environment:
      - TZ=${docker_timezone}
      - APP_BASE_URL=https://papra.${domain_name}
      - DOCUMENT_STORAGE_DRIVER=filesystem
      - DOCUMENT_STORAGE_FILESYSTEM_ROOT=/app/app-data/documents
    volumes:
      - papra_data:/app/app-data
      - ${docker_documents_path}:/app/app-data/documents
    ports:
      - "1221:1221"
    networks:
      - papra

volumes:
  papra_data:
    name: papra_data

networks:
  papra:
    name: papra
    driver: bridge
