#!/bin/bash
set -e

echo "Waiting for PostgreSQL..."

until pg_isready \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER"
do
    sleep 2
done

echo "PostgreSQL is ready."

export PGPASSWORD="$DB_PASSWORD"

psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 \
    -c "
CREATE TABLE IF NOT EXISTS schema_migrations (
    filename TEXT PRIMARY KEY,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
"

for file in $(find /migrations -maxdepth 1 -name '*.sql' | sort); do

    name=$(basename "$file")

    applied=$(psql \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        -tAc \
        "SELECT COUNT(*) FROM schema_migrations WHERE filename='$name';")

    if [ "$applied" = "1" ]; then
        echo "[skip] $name"
        continue
    fi

    echo "[apply] $name"

    psql \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        -v ON_ERROR_STOP=1 \
        -f "$file"

    psql \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        -c \
        "INSERT INTO schema_migrations(filename)
         VALUES ('$name')
         ON CONFLICT DO NOTHING;"
done

echo "Database migrations complete."
