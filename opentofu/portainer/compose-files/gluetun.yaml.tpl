services:
  gluetun:
    image: qmcgaw/gluetun:latest
    hostname: gluetun
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    volumes:
      - ${docker_config_path}/gluetun/config:/gluetun
    environment:
      - VPN_SERVICE_PROVIDER=airvpn
      - SERVER_COUNTRIES=Netherlands
      - FIREWALL_VPN_INPUT_PORTS=${vpn_input_port}
      - FIREWALL_OUTBOUND_SUBNETS=${outbound_subnet}
    ports:
      - "53594:53594/tcp"   # AirVPN forwarded port
      - "53594:53594/udp"   # AirVPN forwarded port
      - "8585:8585/tcp"     # qbittorrent WebUI
      - "6868:6868/tcp"     # profilarr
      - "5055:5055/tcp"     # jellyseerr
      - "7878:7878/tcp"     # radarr
      - "9696:9696/tcp"     # prowlarr
      - "8191:8191/tcp"     # flaresolverr
      - "8989:8989/tcp"     # sonarr
      - "6767:6767/tcp"     # bazarr
      - "3080:3000/tcp"     # librewolf WebUI
    restart: always

  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - TZ=${docker_timezone}
      - WEBUI_PORT=8585
    volumes:
      - ${docker_config_path}/qbittorrent/config:/config
      - ${docker_downloads_path}:/downloads
    restart: always

  jellyseerr:
    image: fallenbagel/jellyseerr:latest
    container_name: jellyseerr
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    environment:
      - TZ=${docker_timezone}
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
    volumes:
      - ${docker_config_path}/jellyseerr/config:/app/config
    restart: always

  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - TZ=${docker_timezone}
    volumes:
      - ${docker_config_path}/prowlarr/config:/config
    restart: always

  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - TZ=${docker_timezone}
    volumes:
      - ${docker_config_path}/flaresolverr/config:/config
    restart: always

  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - TZ=${docker_timezone}
    volumes:
      - ${docker_config_path}/radarr/config:/config
      - ${docker_media_path}/movies:/movies
      - ${docker_downloads_path}:/downloads
    restart: always

  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - TZ=${docker_timezone}
    volumes:
      - ${docker_config_path}/sonarr/config:/config
      - ${docker_media_path}/tv:/tv
      - ${docker_downloads_path}:/downloads
    restart: always

  bazarr:
    image: lscr.io/linuxserver/bazarr:latest
    container_name: bazarr
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - TZ=${docker_timezone}
    volumes:
      - ${docker_config_path}/bazarr/config:/config
      - ${docker_media_path}/movies:/movies
      - ${docker_media_path}/tv:/tv
    restart: always

  librewolf:
    image: lscr.io/linuxserver/librewolf:latest
    container_name: librewolf
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    security_opt:
      - seccomp:unconfined
    environment:
      - PUID=${docker_user_puid}
      - PGID=${docker_user_pgid}
      - TZ=${docker_timezone}
    volumes:
      - ${docker_config_path}/librewolf/config:/config
    shm_size: "2gb"
    restart: always

  profilarr:
    image: santiagosayshey/profilarr:latest
    container_name: profilarr
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    volumes:
      - ${docker_config_path}/profilarr/config:/config
    environment:
      - TZ=${docker_timezone}
    restart: always
