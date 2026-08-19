# Production deployment

Production runs from `/apps/mashup` as a Docker Compose stack:

- `web`: Rails, Puma, Thruster, and in-Puma Solid Queue
- `db`: PostgreSQL 18 with primary, cache, queue, and cable databases
- `app_storage`: persistent protected uploads
- host nginx: TLS termination and proxying to `127.0.0.1:3020`

## First setup

Copy `.env.production.example` to `.env.production` and
`.env.postgres.example` to `.env.postgres`. Generate independent secrets with
`openssl rand -hex 64` and `openssl rand -hex 32`. Use the 64-byte value for
`SECRET_KEY_BASE`; use the 32-byte value for both `POSTGRES_PASSWORD` and
`MASHUP_DATABASE_PASSWORD`.

Set Google OAuth and SMTP credentials when those login methods are enabled.
The production Google redirect URIs are:

```text
https://bookthematch.com/auth/google_oauth2/callback
https://bookthematch.com/auth/google_calendar/callback
```

Deploy and inspect logs:

```sh
./scripts/deploy
./scripts/logs
./scripts/logs all
```

Open a Rails console with:

```sh
docker compose -f compose.production.yml exec web ./bin/rails console
```

Back up the `mashup_postgres_data` and `mashup_app_storage` Docker volumes.
