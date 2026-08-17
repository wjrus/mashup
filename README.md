# Mashup Bookings

A Rails booking management system for nonprofit theatre operations.

## Current scope

- Google-account sign-in via OmniAuth.
- Patrons with contacts, address, phone, email, notes, and patron type.
- Bookings for performances, rehearsals, parties, special events, maintenance, classes/workshops, and other uses.
- Multi-run scheduling across spaces, with overlap validation.
- Contract/document tracking with local uploads and Google Drive URL fields.
- Google sync records ready for Calendar and Drive integrations.

## Local Docker

Copy the env template and fill in Google OAuth credentials when you have them:

```sh
cp .env.example .env
```

Boot the app and PostgreSQL:

```sh
docker compose up --build
```

The app will be available at http://localhost:3000 by default.

## Local Ruby

This app uses Ruby 3.4.9 and Rails 8.1.3.

```sh
bundle install
bin/rails db:prepare
bin/rails test
```

## Google OAuth

Create OAuth credentials in Google Cloud and set:

```sh
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
AUTH_DOMAIN=
```

Use `AUTH_DOMAIN` only if you want to restrict sign-ins to a Google Workspace domain.
