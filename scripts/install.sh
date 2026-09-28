#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is not installed."
    exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
    echo "ERROR: Docker Compose is not installed."
    exit 1
fi

if [ ! -f .env ]; then
    cp .env.example .env

    echo
    echo ".env was created from .env.example."
    echo "Edit it and run this script again:"
    echo
    echo "  nano .env"
    echo
    exit 1
fi

set -a
source .env
set +a

required=(
    SERVER_IP
    DB_PASSWORD
    LOCALDROID_ADMIN_EMAIL
    LOCALDROID_ADMIN_PASSWORD
    JWT_SECRET
)

for var in "${required[@]}"; do
    if [ -z "${!var:-}" ] || [ "${!var}" = "CHANGE_ME" ]; then
        echo "ERROR: $var must be configured in .env"
        exit 1
    fi
done

./scripts/download-localdroid.sh

echo
echo "Building LocalDroid..."
docker compose build

echo
echo "Starting LocalDroid..."
docker compose up -d

echo
docker compose ps

echo
echo "LocalDroid:"
echo "  http://${SERVER_IP}:8080"
