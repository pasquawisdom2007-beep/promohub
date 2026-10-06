# Development workflow

Use `feature/promohub-phase-1` for Phase 1 work. Keep modules small, add service-level tests for each new workflow, create a Prisma migration for schema changes, and run `npm run typecheck && npm test` before commits. Never commit `.env`, database files, tokens, or generated secrets.
