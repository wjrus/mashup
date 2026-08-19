# Mashup Bookings Agent Guide

This file is the durable handoff context for Codex agents working in this repository. Read it before making changes, then inspect `README.md`, `git status`, recent commits, and the relevant code. Prefer repository state and tests over assumptions from an earlier chat.

## Product

Mashup Bookings is an internal booking-operations system for a nonprofit theatre company. It is a Rails 8.1 application backed by PostgreSQL.

The near-term goal is a board-ready internal tool. The architecture should remain suitable for later customer self-service, but do not build public customer workflows before their requirements are known.

Core concepts:

- A `Patron` is an organization and has one of four business classifications: nonprofit, for-profit, partner, or Mashup.
- A patron can have multiple contacts and bookings.
- A `Booking` is the overall engagement and may span multiple weeks.
- A `BookingRun` is a specific scheduled use of a space within the booking dates.
- Spaces cannot have overlapping active runs. This is protected in both model validation and PostgreSQL.
- Documents belong to bookings and may be protected local uploads or validated Google Drive links.

Patron organization classifications are business data. They must never grant application permissions or administrator access.

## Access Policy

- `wjr@wjr.us` is the sole default administrator.
- `wjr.us` and `mashuprockandrollmusical.com` are the default staff domains.
- Other users must not silently receive staff or administrator access.
- Configuration overrides use `ADMIN_EMAILS` and `STAFF_DOMAINS`.
- Google login and passwordless email login converge on the same user by verified email.
- Email login tokens expire after 15 minutes, are single-use, and must remain filtered from logs.
- Use conventional session language and routes such as `/login` and `/logout`. Do not expose implementation jargon such as "magic link" in route names.
- Only administrators may connect or replace Google Calendar credentials or access administrative screens.

## Integrations

Google Calendar currently supports outbound synchronization:

- The administrator connects the organization calendar from Settings.
- OAuth credentials are encrypted at rest on the administrator user.
- Each booking run is upserted as a Google Calendar event.
- Google sync records preserve remote event IDs and sync status.
- Calendar authorization is separate from ordinary Google login.

Inbound Calendar import, grouping, and organization matching are intentionally deferred until the user provides a representative test calendar. Do not guess matching rules from event titles.

Ludus patron synchronization is also deferred until a representative export or confirmed API is available. Prefer a documented CSV/export importer if Ludus has no supported API; do not scrape authenticated pages without an explicit decision and test data.

The user expects to provide real booking-request form documents. Use those documents to drive future fields and workflow states rather than inventing a large speculative schema now.

## Local Development

The canonical local startup command is:

```sh
bin/dev
```

The user normally starts this command in their own shell so they can watch logs. Do not start or leave a development server running unless the user explicitly asks. If a server is needed for browser verification, coordinate with the user or stop the agent-owned process before handoff.

Initial setup:

```sh
cp .env.example .env
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

The application uses Ruby 3.4.9. On the original development Mac, Ruby is managed by Homebrew and rbenv. Do not assume identical absolute tool paths on another computer; honor `.ruby-version` and use that machine's normal rbenv setup.

Development email-login messages are written to `tmp/mails`. Never commit `.env`, OAuth credentials, email-login tokens, uploaded documents, or generated mail.

Docker Compose is supported through `compose.yml`, but native `bin/dev` is the user's normal interactive workflow.

Production runs from `/apps/mashup` with `compose.production.yml`, behind host
nginx and Let's Encrypt TLS for `bookthematch.com`. Use `scripts/deploy` for
updates and `scripts/logs` for service logs. Do not commit `.env.production` or
`.env.postgres`; back up both the Postgres and Active Storage Docker volumes.
The user owns production deployments; agents should commit and push completed
work, but must not deploy unless the user explicitly requests it again.

## Verification

Run focused tests while developing and the full CI script before finishing a substantial change:

```sh
bin/rails test
bin/ci
```

`bin/ci` includes setup, RuboCop, dependency audits, Brakeman, Rails tests,
system tests, and seed verification. Keep it green. Add request, model, service,
or browser coverage in proportion to the behavior changed.

For UI changes, verify normal desktop and narrow mobile widths. Forms and navigation must not create horizontal overflow. Preserve the restrained operations-oriented interface rather than turning the app into a marketing site.

## Accessibility

WCAG 2.1 Level AA is a release requirement. Treat accessibility regressions as
functional defects, not optional polish. The current baseline audit and known
remediation work are recorded in `docs/accessibility-audit.md`.

- Prefer native semantic HTML and expose every control's name, role, state, and
  value. Preserve logical headings, landmarks, form labels, table relationships,
  and status messages.
- Every workflow must be fully operable by keyboard with a visible focus
  indicator and deliberate focus restoration after dialogs or dynamic removal.
- Never rely on color alone. Verify 4.5:1 contrast for normal text, 3:1 for
  large text and required component boundaries, and test every supported theme.
- Associate validation errors and instructions with their fields. Announce
  asynchronous results without unexpectedly moving focus.
- Do not introduce an unadjustable time limit unless the same information or
  action remains available elsewhere. Auto-dismissed messages require special
  scrutiny.
- For substantial UI changes, test keyboard-only use, 200% zoom, 320 CSS-pixel
  reflow, desktop and mobile layouts, and at least one screen reader. Automated
  checks and system tests are useful evidence but do not establish conformance.

## Engineering Constraints

- Preserve the distinction between booking date ranges and individual run times.
- A run must remain within its booking dates.
- A booking's primary contact must belong to its selected patron.
- Canceling a booking releases its scheduled runs.
- Keep overlap protection at the database level; model-only checks are not enough for concurrent users.
- Keep document downloads behind authenticated application routes.
- Validate upload size/type and external URL hosts.
- Treat Calendar OAuth refresh tokens and future integration credentials as secrets requiring encryption at rest.
- Prefer explicit import adapters and external-reference records for future Calendar or Ludus matching.
- Use migrations for schema changes and update tests and seeds with the behavior they introduce.

## Git And Handoffs

The user wants completed work committed in small, coherent groups. Establish a passing checkpoint before each commit and use descriptive commit messages.

- Inspect `git status` before editing and preserve unrelated user changes.
- Do not rewrite, squash, amend, reset, or discard prior work unless explicitly requested.
- Do not push until a remote exists and the user has explicitly enabled pushing for this repository.
- Before handoff, leave the working tree clean when practical, report commit hashes and verification results, and call out anything intentionally deferred.
- Update `AGENTS.md` when stable product rules or collaboration conventions change. Put ordinary feature details in code, tests, migrations, and `README.md`, not in a growing chat-history narrative here.

## Session Checklist

At the start of work:

```sh
git status --short --branch
git log --oneline -10
bin/rails db:migrate:status
```

Then read the files and tests that own the requested behavior. Current commit history is the authoritative record of completed implementation work across computers and agents.
