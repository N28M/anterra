services:
  jotty:
    image: ghcr.io/fccview/jotty:latest
    container_name: jotty
    restart: unless-stopped
    user: "${docker_user_puid}:${docker_user_pgid}"
    environment:
      - NODE_ENV=production
      - TZ=${docker_timezone}
      - SSO_MODE=oidc
      - OIDC_ISSUER=${oidc_issuer}
      - OIDC_CLIENT_ID=${oidc_client_id}
      - OIDC_CLIENT_SECRET=${oidc_client_secret}
      - APP_URL=https://rw.${domain_name}
      - INTERNAL_API_URL=http://localhost:3000
      - SSO_FALLBACK_LOCAL=false
    volumes:
      - ${docker_data_path}/jotty/data:/app/data
      - ${docker_data_path}/jotty/config:/app/config
      - ${docker_data_path}/jotty/cache:/app/.next/cache
    ports:
      - "9200:3000"
    networks:
      - jotty

networks:
  jotty:
    name: jotty
    driver: bridge
