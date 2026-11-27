Set up the application template in this project. $ARGUMENTS
The template was copied in by new-project.sh (see docs/.app-template-source). Do NOT build features here.
Authoritative docs: README.md (setup), ARCHITECTURE.md, OVERVIEW.md, root package.json.
IGNORE backend/README.md and frontend/README.md: stale CRM leftovers (wrong ports, modules that do not exist).

1. Prerequisites. Check `bun --version` (>= 1.3), PostgreSQL >= 14 (`psql --version`, `pg_isready`), git.
   Show me ONE table: tool | needed | found | action (e.g. `brew install oven-sh/bun/bun`,
   `brew install postgresql@16 && brew services start postgresql@16`). Install nothing before I say yes.
2. Names and ports. Database name = the project folder name in snake_case (plus `<name>_test` for tests); do not reuse `application`.
   Check ports 3005 and 5175 (`lsof -i :3005`). If taken, propose others and change PORT, FRONTEND_URL, vite.config.ts server.port
   and VITE_API_URL together.
3. After my OK: `bun install` at the repo root (its prepare step installs lefthook git hooks; the git repo already exists),
   `createdb <name>`, copy backend/.env.example to .env and set DATABASE_URL (if postgres:postgres fails, ask me for
   the user/password) and JWT_SECRET (generate with `openssl rand -base64 48`).
   Do NOT copy frontend/.env.example: its VITE_API_URL says :3000 but the API runs on :3005 and the client already
   defaults to 3005. Create frontend/.env.local only if ports changed.
   Then `bun run db:migrate` and `bun run seed` (creates roles + admin / admin123).
4. Verify: `bun run typecheck` and `bun run lint`; start `bun run dev`; check `GET /api/health` returns 200 and that
   POST /api/auth/login works with the seeded admin (read the login schema in shared/src/schemas/auth.schema.ts);
   then stop the servers. Fix setup problems only. Do not fix the known template defects below.
5. Known template defects (already tracked as T-002 and T-003 in TASKS.md; mention only if they block you):
   no frontend src/__tests__/setup.ts and no backend .env.test (tests cannot run); Playwright config and e2e specs are CRM leftovers
   on the wrong ports; warehouse types/constants and unused deps remain; branding says Symatis.
6. Update the Run/DB/port lines in CLAUDE.md if they changed. Write docs/.app-setup-done (date + what was installed/configured).
   Mark T-001 done in TASKS.md.
7. Reply in max 10 lines: what is running (URLs), login admin/admin123 (change it), anything I must do by hand.
