# Database setup

1. Set `DATABASE_URL` in `.env`.
2. Run `npm run db:generate`.
3. For local development run `npm run db:migrate -- --name init`.
4. For deployment run `npm run db:deploy` against the reviewed migration directory.

The schema includes users/roles, marketplace entities, campaign lifecycle, wallet/transactions, moderation, support, notifications, and configuration settings. Financial operations must use a database transaction and a unique idempotency key.
