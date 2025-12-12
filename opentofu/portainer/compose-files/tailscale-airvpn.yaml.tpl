services:
  gluetun:
    image: qmcgaw/gluetun:latest
    container_name: gluetun-ts
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    volumes:
      - ${docker_config_path}/tailscale-airvpn/gluetun:/gluetun
    environment:
      - VPN_SERVICE_PROVIDER=airvpn
    restart: always

  tailscale:
    image: tailscale/tailscale:latest
    container_name: tailscale-ts
    network_mode: "service:gluetun"
    depends_on: [gluetun]
    cap_add:
      - NET_ADMIN
      - SYS_ADMIN
    volumes:
      - ${docker_config_path}/tailscale-airvpn/tailscale:/var/lib/tailscale
    environment:
      - TS_AUTHKEY=${tailscale_auth_key_value}
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_HOSTNAME=tailscale-airvpn
      - TS_EXTRA_ARGS=--advertise-exit-node
    restart: always
