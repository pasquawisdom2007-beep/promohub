# Deployment

Build with `npm run build`, set production environment variables through the hosting secret manager, run `npm run db:deploy`, then run `npm start`. Use PostgreSQL for production, a process supervisor/container restart policy, encrypted transport, least-privilege database credentials, and redacted structured logs. Telegram webhook or long polling mode should be selected for the target infrastructure in Phase 2.
