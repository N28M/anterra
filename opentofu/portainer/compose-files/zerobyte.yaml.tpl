services:
  zerobyte:
    image: ghcr.io/nicotsx/zerobyte:v0.19
    container_name: zerobyte
    restart: unless-stopped
    environment:
      - TZ=${docker_timezone}
    volumes:
      - /var/lib/zerobyte:/var/lib/zerobyte
      - /home/dockeruser/.config/rclone:/root/.config/rclone:ro
    ports:
      - "4096:4096"
    cap_add:
      - SYS_ADMIN
    devices:
      - /dev/fuse:/dev/fuse
    security_opt:
      - apparmor:unconfined
    networks:
      - zerobyte

networks:
  zerobyte:
    name: zerobyte
    driver: bridge
