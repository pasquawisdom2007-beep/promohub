# Phase 3 production hardening

Phase 3 extends the existing PROMOHUB branch with production-oriented primitives. It does not claim that external providers are live or that an admin web frontend exists; the repository now exposes the service/data boundaries needed to build and operate those surfaces safely.

## Admin control and audit

`admin-controls.ts` provides real-data user search/profile, campaign moderation queues, campaign listing, withdrawal listing and state changes. Sensitive actions use `audit.ts` and are stored in append-only `AuditLog` records. User suspension/ban, withdrawal decisions, dispute resolution, and settings changes record before/after state.

## Payments and wallet safety

`phase3-payments.ts` stores provider reference, internal reference, amount, currency, metadata, status, and verification state. A verified payment updates the wallet and appends a unique ledger entry in one database transaction. The existing provider interface remains replaceable, and webhook signature validation remains mandatory. No frontend success signal is treated as payment confirmation.

Withdrawals now support payment methods, fees, currencies, provider references, and controlled status transitions. They remain pending until an admin/provider confirmation. Locked campaign funds must not be represented as available balance.

## Risk, disputes, and performance

`risk.ts` records explainable risk flags without auto-banning accounts. `disputes.ts` supports the requested lifecycle and evidence fields. `performance.ts` calculates a persisted score from actual placements, ratings, and disputes; weights are intended to move into settings rather than remain a permanent code constant.

## Background jobs and observability

`jobs.ts` provides an idempotent queue record with retry count, exponential backoff, failure state, and dead-letter state. It is a persistence foundation for a worker process; this phase does not run a resident worker in the sandbox. `observability.ts` emits JSON logs and filters secret-like field names.

## Telegram and WhatsApp boundaries

`telegram-ops.ts` records posting attempts and retry decisions. Actual Telegram posting must use authorized API access and should mark manual placement when automatic posting is unavailable. WhatsApp remains strictly human-operated: agents accept offers and submit proof; PROMOHUB does not send unsolicited bulk messages.

## Backups and recovery

Production should run encrypted PostgreSQL backups daily, retain at least 30 days plus periodic monthly snapshots, and test restores. Store migration files in version control. Before destructive migrations, take a verified backup; use forward corrective migrations rather than editing applied migration SQL. Recovery order: restore database snapshot, validate migration level, rotate compromised credentials, replay verified provider webhooks using idempotency keys, then enable traffic.

## CI/CD

`.github/workflows/ci.yml` runs install, Prisma generation/migration deployment, lint, type checking, tests, and build. Deployment should be blocked when any required step fails. Production secrets belong in the CI/hosting secret manager, never in the repository.

## Remaining external work

- Admin UI and authentication/session layer require a web/API surface and deployment choice.
- A concrete payment provider must implement `PaymentProvider`, provider-specific signatures, reconciliation, refunds, and payout APIs.
- Telegram health/permission checks require a real bot token and target-community permissions.
- Production PostgreSQL, object storage, monitoring/alerting, and a resident worker require deployment infrastructure.
