FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        adb \
        ca-certificates \
        curl \
        postgresql-client && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY vendor/localdroid/server/ /app/
COPY vendor/localdroid/seed/ /seed/

RUN chmod +x /app/localdroid-server

COPY localdroid/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
