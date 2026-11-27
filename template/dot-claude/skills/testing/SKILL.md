---
name: testing
description: How to write and run tests here (bun test via createApp().request, Vitest + React Testing Library + msw, separate test DB). Use when writing test cases or automated tests.
---
# Testing
The template has test config but no tests yet; T-002 creates the missing pieces (setup file, .env.test).
- Backend (backend): files in src/__tests__/<feature>.test.ts. Run: `cd backend && bun run test <file>`.
  Needs .env.test (untracked) with a SEPARATE database `<project>_test`; migrate it once (DATABASE_URL=<test url> bun run db:migrate).
  Test without a server: `createApp().request('/api/...')`. Log in with POST /api/auth/login (seeded admin) and send the
  returned Set-Cookie (app_token) as the Cookie header. Clean up rows a test creates. Never touch the dev database.
- Frontend (frontend): Vitest + jsdom + React Testing Library + msw. Only src/__tests__/**/*.test.tsx are picked up;
  src/__tests__/setup.ts must exist. Run: `cd frontend && bun run test <file>`.
  Query by role or label, never class names. Mock HTTP with msw, not fetch internals.
- Playwright e2e: shipped config and specs are stale CRM leftovers (ports 3000/5173; app is 3005/5175). Do not use until T-003 fixes them.
- Per task: happy path, 1+ validation/negative case, 1 permission case (user without the module gets 403), 1 edge case
  (empty, duplicate, soft-deleted). Test names: "does X when Y".
- Report: PASS/FAIL, failing test, expected vs actual, one-line likely cause.
