services:
  watchtower:
    image: nickfedor/watchtower
    container_name: watchtower
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      # TZ environment variable sets the timezone for cron schedule interpretation
      # WATCHTOWER_SCHEDULE uses the TZ value, so adjust times accordingly
      - TZ=${docker_timezone}
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_INCLUDE_STOPPED=true
      - WATCHTOWER_REVIVE_STOPPED=false
      - WATCHTOWER_SCHEDULE=${watchtower_schedule}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    network_mode: host
    restart: always
