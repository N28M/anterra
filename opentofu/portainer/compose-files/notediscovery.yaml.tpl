services:
  notediscovery:
    image: ghcr.io/gamosoft/notediscovery:latest
    container_name: notediscovery
    restart: unless-stopped
    user: "${docker_user_puid}:${docker_user_pgid}"
    ports:
      - "9300:8000"
    volumes:
      - ${docker_documents_path}/Filebrowser/Nikhil/notes:/app/data
    environment:
      - TZ=${docker_timezone}
      - AUTHENTICATION_ENABLED=true
      - AUTHENTICATION_SECRET_KEY=${notediscovery_secret_key}
      - AUTHENTICATION_PASSWORD_HASH=${notediscovery_password_hash}
    networks:
      - notediscovery

networks:
  notediscovery:
    name: notediscovery
    driver: bridge
