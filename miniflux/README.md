# Miniflux

Self-hosted RSS feed reader.

## Setup

Copy `.env.example` to `.env` and fill in the values:

```
PORT=8080
POSTGRES_USER=miniflux
POSTGRES_PASSWORD=changeme
POSTGRES_DB=miniflux
ADMIN_USERNAME=admin
ADMIN_PASSWORD=changeme
```

Then start the stack:

```
docker compose up -d
```

On first run, `CREATE_ADMIN=1` creates the admin user automatically. After that you can remove `CREATE_ADMIN`, `ADMIN_USERNAME`, and `ADMIN_PASSWORD` from the compose file.

Miniflux will be available at `http://<host>:<PORT>`.
