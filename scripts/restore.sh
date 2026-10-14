#!/usr/bin/env bash
# Przywracanie backupu volume n8n
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Użycie: $0 <ścieżka-do-backup.tar.gz>"
  exit 1
fi

BACKUP_FILE="$1"
VOLUME_NAME="${VOLUME_NAME:-jb_n8n_data}"

if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "Błąd: plik $BACKUP_FILE nie istnieje"
  exit 1
fi

echo "⚠  To nadpisze dane w volume $VOLUME_NAME"
read -r -p "Kontynuować? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Anulowano."
  exit 0
fi

echo "→ Zatrzymuję n8n..."
docker compose stop n8n 2>/dev/null || true

echo "→ Przywracam backup..."
docker run --rm \
  -v "${VOLUME_NAME}:/data" \
  -v "$(realpath "$BACKUP_FILE"):/backup.tar.gz:ro" \
  alpine \
  sh -c "rm -rf /data/* /data/.[!.]* 2>/dev/null; tar xzf /backup.tar.gz -C /data"

echo "→ Uruchamiam n8n..."
docker compose start n8n 2>/dev/null || docker compose up -d

echo "✓ Przywrócono z $BACKUP_FILE"
