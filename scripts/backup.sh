#!/usr/bin/env bash
# Back up the n8n volume (includes SQLite and the encryption key)
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
VOLUME_NAME="${VOLUME_NAME:-n8n-self-hosted-lab_data}"

mkdir -p "$BACKUP_DIR"

echo "→ Stopping n8n..."
docker compose stop n8n 2>/dev/null || true

echo "→ Backing up volume $VOLUME_NAME → $BACKUP_DIR/n8n-backup-$TIMESTAMP.tar.gz"
docker run --rm \
  -v "${VOLUME_NAME}:/data" \
  -v "$(pwd)/${BACKUP_DIR}:/backup" \
  alpine \
  tar czf "/backup/n8n-backup-${TIMESTAMP}.tar.gz" -C /data .

echo "→ Restarting n8n..."
docker compose start n8n 2>/dev/null || docker compose up -d

echo "✓ Backup ready: $BACKUP_DIR/n8n-backup-$TIMESTAMP.tar.gz"
