# jb_n8n – PoC środowiska n8n

Prosty, gotowy do uruchomienia **Proof of Concept** self-hosted [n8n](https://n8n.io) w Dockerze.

Repozytorium: [JeanneBM/jb_n8n](https://github.com/JeanneBM/jb_n8n)

---

## Wymagania

- Docker + Docker Compose (v2+)
- ~512 MB RAM (minimum), lepiej 1–2 GB

---

## Szybki start (SQLite)

```bash
git clone https://github.com/JeanneBM/jb_n8n.git
cd jb_n8n

cp .env.example .env
# (opcjonalnie) edytuj .env

docker compose up -d
```

Po starcie otwórz: **http://localhost:5678**

Pierwsze uruchomienie – utwórz konto właściciela (owner).

---

## Wariant z PostgreSQL (zalecany na dłużej)

```bash
cp .env.example .env
# Ustaw silne hasło:
# POSTGRES_PASSWORD=twoje_silne_haslo

docker compose -f compose.postgres.yml up -d
```

---

## Struktura repozytorium

```
jb_n8n/
├── compose.yml              # Podstawowa konfiguracja (SQLite)
├── compose.postgres.yml     # Wariant z PostgreSQL
├── .env.example             # Szablon zmiennych środowiskowych
├── .gitignore
├── local-files/             # Katalog montowany do /files w kontenerze
├── scripts/
│   ├── backup.sh            # Backup volume n8n
│   └── restore.sh           # Przywracanie backupu
└── README.md
```

---

## Przydatne komendy

| Akcja                    | Komenda                                      |
|--------------------------|----------------------------------------------|
| Start                    | `docker compose up -d`                       |
| Stop                     | `docker compose down`                        |
| Logi                     | `docker compose logs -f n8n`                 |
| Status                   | `docker compose ps`                          |
| Update n8n               | `docker compose pull && docker compose up -d`|
| Backup                   | `./scripts/backup.sh`                        |
| Restore                  | `./scripts/restore.sh backups/xxx.tar.gz`    |

---

## Konfiguracja

Wszystkie kluczowe zmienne znajdują się w `.env` (skopiuj z `.env.example`).

Najważniejsze:

| Zmienna              | Opis                                      | Domyślnie          |
|----------------------|-------------------------------------------|--------------------|
| `GENERIC_TIMEZONE`   | Strefa czasowa dla Schedule Trigger       | `Europe/Warsaw`    |
| `N8N_PORT`           | Port hosta                                | `5678`             |
| `N8N_WEBHOOK_URL`    | Publiczny URL (za reverse proxy)          | –                  |
| `N8N_ENCRYPTION_KEY` | Klucz szyfrowania credentials             | generowany         |

> **Uwaga:** Volume `jb_n8n_data` zawiera bazę SQLite **oraz** klucz szyfrowania.  
> Przywrócenie workflowów na inną instancję bez tego klucza uniemożliwia odczyt credentials.

---

## Produkcja – co warto dodać

- Reverse proxy (Traefik / Caddy / Nginx) + HTTPS
- `N8N_WEBHOOK_URL` i `N8N_EDITOR_BASE_URL` wskazujące na domenę
- Stały `N8N_ENCRYPTION_KEY`
- Regularne backupy (`scripts/backup.sh` + cron)
- Ograniczenie dostępu (VPN / basic auth / IP whitelist)

Oficjalna dokumentacja:  
https://docs.n8n.io/hosting/

---

## Licencja

MIT (jak n8n – możesz dowolnie używać i modyfikować).
