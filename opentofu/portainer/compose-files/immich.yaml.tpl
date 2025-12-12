services:
  immich-server:
    container_name: immich_server
    image: ghcr.io/immich-app/immich-server:${immich_version}
    volumes:
      - ${immich_upload_location}:/data
      - /etc/localtime:/etc/localtime:ro
    environment:
      - DB_PASSWORD=${immich_db_password}
      - DB_USERNAME=postgres
      - DB_DATABASE_NAME=immich
      - TZ=${docker_timezone}
    ports:
      - '2283:2283'
    depends_on:
      - redis
      - database
    restart: always
    healthcheck:
      disable: false
    labels:
      - "com.centurylinklabs.watchtower.monitor-only=true"

  immich-machine-learning:
    container_name: immich_machine_learning
    image: ghcr.io/immich-app/immich-machine-learning:${immich_version}
    volumes:
      - model-cache:/cache
    environment:
      - DB_PASSWORD=${immich_db_password}
      - DB_USERNAME=postgres
      - DB_DATABASE_NAME=immich
      - TZ=${docker_timezone}
    restart: always
    healthcheck:
      disable: false
    labels:
      - "com.centurylinklabs.watchtower.monitor-only=true"

  redis:
    container_name: immich_redis
    image: docker.io/valkey/valkey:8@sha256:81db6d39e1bba3b3ff32bd3a1b19a6d69690f94a3954ec131277b9a26b95b3aa
    healthcheck:
      test: redis-cli ping || exit 1
    restart: always
    labels:
      - "com.centurylinklabs.watchtower.monitor-only=true"

  database:
    container_name: immich_postgres
    image: ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23
    environment:
      - POSTGRES_PASSWORD=${immich_db_password}
      - POSTGRES_USER=postgres
      - POSTGRES_DB=immich
      - POSTGRES_INITDB_ARGS=--data-checksums
    volumes:
      - ${immich_db_data_location}:/var/lib/postgresql/data
    shm_size: 128mb
    restart: always
    labels:
      - "com.centurylinklabs.watchtower.monitor-only=true"

volumes:
  model-cache:
