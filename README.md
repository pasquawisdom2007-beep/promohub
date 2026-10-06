# PROMOHUB — Phase 1

> **Advertise anywhere. Grow everywhere.**

Production foundation for a Telegram-based community advertising marketplace. This phase establishes real domain services, a relational Prisma schema, an immutable wallet ledger boundary, RBAC primitives, moderation, support, notifications, and the Telegram `/start` interface.

## Architecture

- `src/bot`: Telegram adapter and presentation only.
- `src/services`: business workflows for users, campaigns, wallets, moderation, support, and notifications.
- `src/security`: reusable authorization and rate limiting primitives.
- `src/config`: validated environment configuration; secrets are never committed.
- `prisma/schema.prisma`: relational model and migration source.

## Local setup

```bash
cp .env.example .env
# set TELEGRAM_BOT_TOKEN and DATABASE_URL
npm install
npm run db:generate
npm run db:migrate -- --name init
npm run typecheck
npm test
npm run dev
```

For PostgreSQL, change the Prisma datasource provider and use a PostgreSQL `DATABASE_URL` before creating a deployment migration. SQLite is used for the local foundation and tests.

## Configuration

Financial values are basis points or integer minor units and are loaded from environment variables. See `.env.example`. Never put bot tokens, payment credentials, API keys, or encryption secrets in source control.

## Verification

- `npm test` runs the automated security foundation tests.
- `npm run typecheck` validates TypeScript.
- `npm run db:generate` validates the Prisma client/schema.
- `npm run db:migrate` applies the relational migration.
- `npm run dev` starts the real grammY Telegram bot and registers `/start`.

The remaining integration verification (Telegram network handshake, full advertiser conversation, and live database transaction tests) requires a configured bot token and database environment; it is not claimed as tested by this repository initialization.

## Phase boundaries

Phase 1 intentionally provides the production-oriented foundation and service boundaries. Phase 2 can add admin UI, payment provider adapters, publisher inventory discovery, analytics ingestion, and complete multi-step Telegram conversations without collapsing the architecture.

## Phase 2 services

Phase 2 extends the foundation without replacing it:

- `publishers.ts` and `agents.ts`: persisted onboarding profiles, statuses, availability, categories, and dashboards.
- `matching.ts`: explainable scoring using platform, category, country, budget, availability, accepted categories, reputation-ready data, and daily placement limits.
- `distribution.ts`: transaction-backed placement opportunities and Telegram posting state; no permission bypass is implemented.
- `agent-workflow.ts`: explicit offer, accept/decline, proof submission, and admin review states for WhatsApp agents. PROMOHUB does not send unsolicited bulk WhatsApp messages.
- `tracking.ts` and `analytics.ts`: per-placement links, click events, estimated reach, and conservative conversion reporting.
- `allocations.ts` and `withdrawals.ts`: configurable basis-point allocation, idempotent ledger entries, and guarded withdrawal requests.
- `payments.ts`: replaceable provider interface with webhook signature-validation boundary; a live provider is intentionally not claimed until configured and tested.
- `ratings.ts`, `referrals.ts`, and `admin.ts`: persisted reputation/referral primitives and real-data aggregate metrics.

When data is unavailable, analytics return zero/null values rather than fabricated records. The Telegram adapter remains deliberately thin; live Telegram permission verification, payment-provider integration, and end-to-end network tests require configured external credentials.

## Phase 3 hardening

Phase 3 remains on the consolidated `feature/promohub-phase-1` branch. It adds payment lifecycle records, payment methods, audit logs, risk flags, disputes, idempotent background-job records, notification preferences, performance scores, posting attempts, admin control services, structured redacted logging, CI checks, and operational documentation. See [`docs/phase3.md`](docs/phase3.md).

The codebase does not claim live provider integrations, a deployed admin frontend, or production Telegram/WhatsApp connectivity without configured credentials and an actual deployment environment.
