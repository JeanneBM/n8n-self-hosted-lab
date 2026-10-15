#!/usr/bin/env bash
# Restore an n8n volume backup
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <path-to-backup.tar.gz>"
  exit 1
fi

BACKUP_FILE="$1"
VOLUME_NAME="${VOLUME_NAME:-n8n-self-hosted-lab_data}"

if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "Error: file $BACKUP_FILE does not exist"
  exit 1
fi

echo "⚠  This will overwrite data in volume $VOLUME_NAME"
read -r -p "Continue? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

echo "→ Stopping n8n..."
docker compose stop n8n 2>/dev/null || true

echo "→ Restoring backup..."
docker run --rm \
  -v "${VOLUME_NAME}:/data" \
  -v "$(realpath "$BACKUP_FILE"):/backup.tar.gz:ro" \
  alpine \
  sh -c "rm -rf /data/* /data/.[!.]* 2>/dev/null; tar xzf /backup.tar.gz -C /data"

echo "→ Starting n8n..."
docker compose start n8n 2>/dev/null || docker compose up -d

echo "✓ Restored from $BACKUP_FILE"
