#!/usr/bin/env bash
set -euo pipefail

VERSION="${LOCALDROID_VERSION:-1.9.0}"
ARCH="${LOCALDROID_ARCH:-amd64}"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_DIR="$ROOT_DIR/vendor"
DEST_DIR="$VENDOR_DIR/localdroid"

mkdir -p "$VENDOR_DIR"

if [ -x "$DEST_DIR/server/localdroid-server" ]; then
    echo "LocalDroid runtime already present."
    exit 0
fi

case "$VERSION-$ARCH" in
    1.9.0-amd64)
        FILE="localdroid-native-linux-amd64-20260923-055537.tar.gz"
        SHA256="3c50a83840d37fb9f3ce89799b34167e6dbc80b927c1ef75e70d1b3ebe9d9ccc"
        ;;
    *)
        echo "Unsupported LocalDroid version/architecture: $VERSION/$ARCH"
        exit 1
        ;;
esac

URL="https://github.com/localdroidapp/localdroid-installers/releases/download/v${VERSION}/${FILE}"
ARCHIVE="$VENDOR_DIR/$FILE"

echo "Downloading LocalDroid v$VERSION..."

curl -fL "$URL" -o "$ARCHIVE"

echo "$SHA256  $ARCHIVE" | sha256sum -c -

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

tar -xzf "$ARCHIVE" -C "$TMP_DIR"

EXTRACTED="$(find "$TMP_DIR" -maxdepth 1 -type d -name 'localdroid-native-*' | head -1)"

if [ -z "$EXTRACTED" ]; then
    echo "Could not locate extracted LocalDroid directory."
    exit 1
fi

rm -rf "$DEST_DIR"
mv "$EXTRACTED" "$DEST_DIR"

rm -f "$ARCHIVE"

echo "LocalDroid v$VERSION installed into $DEST_DIR"
