#!/usr/bin/env bash
# Prosty backup volume n8n (zawiera SQLite + encryption key)
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
VOLUME_NAME="${VOLUME_NAME:-jb_n8n_data}"

mkdir -p "$BACKUP_DIR"

echo "→ Zatrzymuję n8n..."
docker compose stop n8n 2>/dev/null || true

echo "→ Tworzę backup volume $VOLUME_NAME → $BACKUP_DIR/n8n-backup-$TIMESTAMP.tar.gz"
docker run --rm \
  -v "${VOLUME_NAME}:/data" \
  -v "$(pwd)/${BACKUP_DIR}:/backup" \
  alpine \
  tar czf "/backup/n8n-backup-${TIMESTAMP}.tar.gz" -C /data .

echo "→ Uruchamiam n8n ponownie..."
docker compose start n8n 2>/dev/null || docker compose up -d

echo "✓ Backup gotowy: $BACKUP_DIR/n8n-backup-$TIMESTAMP.tar.gz"
