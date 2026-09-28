#!/bin/bash
set -e

mkdir -p /app/storage/agent
mkdir -p /mosquitto/auth

if [ -f /seed/localdroid-agent.apk ] && \
   [ ! -f /app/storage/agent/localdroid-agent.apk ]; then
    cp /seed/localdroid-agent.apk \
       /app/storage/agent/localdroid-agent.apk
fi

if [ -f /seed/localdroid-agent.exe ] && \
   [ ! -f /app/storage/agent/localdroid-agent.exe ]; then
    cp /seed/localdroid-agent.exe \
       /app/storage/agent/localdroid-agent.exe
fi

if [ -f /seed/localdroid-agent.apk.cert-sha256 ]; then
    export APK_SIGNATURE_CHECKSUM="$(
        tr -d '[:space:]' \
        < /seed/localdroid-agent.apk.cert-sha256
    )"
fi

cd /app

exec ./localdroid-server
