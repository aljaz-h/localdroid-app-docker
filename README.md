# LocalDroid Docker

Docker-based deployment for [LocalDroid MDM](https://github.com/localdroidapp/localdroid-installers).

This project runs LocalDroid together with:

- PostgreSQL
- Mosquitto MQTT
- LocalDroid server
- Automatic database migrations

The LocalDroid binaries are **not included in this repository**. They are downloaded automatically during installation.

## Requirements

Linux system with:

- Docker Engine
- Docker Compose plugin
- `curl`
- `tar`

Tested on Ubuntu/Kubuntu.

## Installation

Clone the repository:

```bash
git clone https://github.com/aljaz-h/localdroid-app-docker.git
cd localdroid-app-docker
```

Create the configuration file:

```bash
cp .env.example .env
nano .env
```

Configure at least:

```env
SERVER_IP=192.168.1.100

DB_PASSWORD=CHANGE_ME

LOCALDROID_ADMIN_EMAIL=admin@example.com
LOCALDROID_ADMIN_PASSWORD=CHANGE_ME

JWT_SECRET=CHANGE_ME
```

For `SERVER_IP`, use the LAN IP address of the machine running LocalDroid.

Generate a JWT secret with:

```bash
openssl rand -hex 32
```

You can also use the same command to generate a strong database password.

## Deploy

Run:

```bash
./scripts/install.sh
```

The installer will:

1. Check Docker and Docker Compose.
2. Download the configured LocalDroid release.
3. Verify the release checksum.
4. Build the LocalDroid Docker image.
5. Start PostgreSQL, Mosquitto, and LocalDroid.
6. Run the required database migrations.

Check the containers:

```bash
docker compose ps -a
```

LocalDroid should then be available at:

```text
http://SERVER_IP:8080
```

For example:

```text
http://192.168.1.100:8080
```

## Logs

LocalDroid:

```bash
docker compose logs -f localdroid
```

Mosquitto:

```bash
docker compose logs -f mosquitto
```

Database migrations:

```bash
docker compose logs migrate
```

All services:

```bash
docker compose logs --tail=100
```

## Start and Stop

Start:

```bash
docker compose up -d
```

Stop:

```bash
docker compose down
```

Restart:

```bash
docker compose restart
```

## Configuration

Deployment-specific configuration is stored in:

```text
.env
```

Do not commit this file to Git.

The downloaded LocalDroid runtime is stored in:

```text
vendor/localdroid/
```

This directory is also excluded from Git.

Persistent application data is stored in Docker volumes.

## Updating

LocalDroid is currently version-pinned by the download script.

To update to a newer release, update:

```text
scripts/download-localdroid.sh
```

with the new version, release filename, and SHA-256 checksum, then rebuild:

```bash
docker compose build --no-cache localdroid
docker compose up -d
```

## Ports

| Port | Service |
|---|---|
| `8080/tcp` | LocalDroid Web/API |
| `1883/tcp` | Mosquitto MQTT |

## Project Structure

```text
.
├── compose.yaml
├── .env.example
├── localdroid/
│   ├── Dockerfile
│   └── entrypoint.sh
├── mosquitto/
│   └── mosquitto.conf
├── scripts/
│   ├── download-localdroid.sh
│   ├── install.sh
│   └── migrate.sh
└── vendor/
```

## Notes

This deployment currently targets a LAN / air-gapped LocalDroid setup.

For production or internet-facing deployments, additional configuration such as TLS, firewall rules, secure MQTT authentication, a reverse proxy, and TURN may be required.

LocalDroid itself is maintained separately by the LocalDroid project.
