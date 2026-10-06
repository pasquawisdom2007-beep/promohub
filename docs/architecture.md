# Architecture

PROMOHUB uses ports-and-adapters boundaries: Telegram is an adapter; services own use cases; Prisma is the persistence adapter. Domain enums and constraints live in the schema. Financial writes use Prisma transactions and idempotency keys. Historical ledger entries are append-only; balances are updated in the same transaction and should be reconciled from the ledger in an operational job.

## Security boundaries

All external input is validated at service boundaries. URLs are parsed and restricted to HTTP(S); role checks are explicit; rate limiting is reusable; secrets come only from environment variables. Production deployment should add structured redacted logging, centralized error reporting, and provider-specific webhook signature validation.
