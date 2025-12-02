services:
  bentopdf:
    image: bentopdf/bentopdf:latest
    container_name: bentopdf
    restart: unless-stopped
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - TZ=${docker_timezone}
    ports:
      - "9100:8080"
    networks:
      - bentopdf

networks:
  bentopdf:
    name: bentopdf
    driver: bridge
