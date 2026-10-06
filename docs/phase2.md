# Phase 2 implementation notes

## External services required

1. **Telegram Bot API** — bot token, community/channel administrative permissions, and a posting strategy (webhook or long polling). PROMOHUB must use only permissions granted by Telegram.
2. **Payment provider** — an implementation of `PaymentProvider` from `src/services/payments.ts`, with provider-specific signature verification, idempotency, deposit verification, refunds, and webhook delivery.
3. **Production database** — PostgreSQL is recommended for deployment; local development currently uses SQLite and Prisma migrations.
4. **Object storage** — optional provider for placement proof screenshots and campaign media; Phase 2 stores URLs, not binary objects.

## Marketplace lifecycle

`ACTIVE` campaigns are matched against active, available publishers. Candidates are scored and filtered by platform, category, target location, accepted categories, budget, and publisher daily limits. Distribution creates placement records and notifies the publisher. Telegram posting is represented by the placement workflow and must be performed through legitimate Telegram APIs.

WhatsApp agents receive marketplace opportunities through the PROMOHUB workflow. They must explicitly accept before submitting a placement. The product does not perform unsolicited bulk WhatsApp messaging.

## Financial safety

Placement earnings are allocated with basis points from configuration. Ledger entries and the allocation record are created in one database transaction with a unique idempotency key. Withdrawals remain `PENDING` until an admin or payment integration changes their status; they are never marked complete automatically.

## Honest analytics

Estimated reach is derived only from recorded community audience sizes for posted placements. Clicks come from recorded tracking events. Verified and self-reported conversions remain separate. If no evidence exists, the analytics API returns `0`/`null` rather than inventing a result.
