services:
  filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: filebrowser
    restart: unless-stopped
    user: "${docker_user_puid}:${docker_user_pgid}"
    ports:
      - "9200:80"
    volumes:
      - ${docker_documents_path}/Filebrowser:/srv
      - ${docker_config_path}/filebrowser:/database
    environment:
      - TZ=${docker_timezone}
    networks:
      - filebrowser

networks:
  filebrowser:
    name: filebrowser
    driver: bridge
