services:
  zerobyte:
    image: ghcr.io/nicotsx/zerobyte:latest
    container_name: zerobyte
    restart: unless-stopped
    environment:
      - TZ=${docker_timezone}
    volumes:
      - /var/lib/zerobyte:/var/lib/zerobyte
      - /home/dockeruser/.config/rclone:/root/.config/rclone:ro
      - ${docker_documents_path}:/mnt/documents:ro
      - /mnt/backup:/mnt/backup
    ports:
      - "4096:4096"
    cap_add:
      - SYS_ADMIN
      - SYS_PTRACE
    devices:
      - /dev/fuse:/dev/fuse
    security_opt:
      - apparmor:unconfined
      - seccomp:unconfined
    networks:
      - zerobyte

networks:
  zerobyte:
    name: zerobyte
    driver: bridge
