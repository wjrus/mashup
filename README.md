# Mashup Bookings

Internal booking operations for a nonprofit theatre company, built with Rails 8.1 and PostgreSQL.

## Current capabilities

- Google and one-time email-link login for authorized staff.
- A single configured administrator (`wjr@wjr.us` by default).
- Staff access for `wjr.us` and `mashuprockandrollmusical.com` accounts.
- Patrons and contacts classified as nonprofit, for-profit, partner, or Mashup.
- Multi-week bookings with multiple scheduled runs across managed spaces.
- Database-backed protection against overlapping use of a space.
- Contract and document tracking with protected local downloads or Google Drive links.
- Admin-managed outbound synchronization of booking runs to Google Calendar.

Google Calendar import/matching and Ludus patron import are planned after representative exports are available.

## Local setup

Ruby 3.4.9, PostgreSQL, and Bundler are required.

```sh
cp .env.example .env
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

Open http://localhost:3000.

In development, email sign-in messages are written to `tmp/mails`. Request a link on `/login`, then open the newest generated email file and follow its `/login/email?token=...` URL.

## Docker Compose

Install and start Docker Desktop, then run:

```sh
cp .env.example .env
docker compose up --build
```

The web app is available at http://localhost:3000. PostgreSQL is bound to `127.0.0.1:5432` by default.

Production uses the separate `compose.production.yml` stack behind nginx. See
[`docs/deploy.md`](docs/deploy.md) for deployment, logging, TLS, and backup notes.

## Google setup

Create a Google Cloud OAuth web application and enable the Google Calendar API. For local development, add these authorized redirect URIs:

```text
http://localhost:3000/auth/google_oauth2/callback
http://localhost:3000/auth/google_calendar/callback
```

Configure `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` in `.env`. `GOOGLE_CALENDAR_ID` may be `primary` or the ID of a shared calendar. Calendar authorization is separate from login and is available only from the administrator settings screen.

The default access policy can be overridden with comma-separated `ADMIN_EMAILS` and `STAFF_DOMAINS`. Patron organization types do not grant application access.

## Email delivery

Development writes messages to `tmp/mails`; tests use the in-memory test delivery method. A deployed environment must provide `APP_HOST`, `MAIL_FROM`, and the `SMTP_*` variables from `.env.example`.

## Verification

```sh
bin/rails test
bin/rubocop
bin/brakeman --quiet --no-pager
bin/bundler-audit check --update
bin/ci
```

## Data and files

Development uploads are stored in `storage/`, which is mounted as a Docker volume by `compose.yml`. A production deployment must use durable storage before real contracts are uploaded.
