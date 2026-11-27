# Project: {{PROJECT_NAME}}
Brief: docs/BRIEF.md. Requirements: docs/REQUIREMENTS.md (sources in docs/requirements/). Read before planning.
Cite REQ ids in task Notes; mark a requirement `done` in REQUIREMENTS.md when its tasks are done.
Stack: Bun monorepo, TypeScript. Backend: Hono + Drizzle (PostgreSQL via Bun.sql), Zod 4, JWT httpOnly cookie, RBAC.
Frontend: React 19 + Vite + TanStack Query + Zustand + Tailwind 3 + react-hook-form. API contract shared in `@shared`.
Layout: backend (:3005)  frontend (:5175)  shared (@shared)
Docs: ARCHITECTURE.md (conventions) and OVERVIEW.md are authoritative. IGNORE backend/README.md and
frontend/README.md (stale CRM leftovers).
Commands (repo root): bun run dev | typecheck | lint | build | db:generate (review SQL) -> db:migrate | seed
Tests: cd backend && bun run test | cd frontend && bun run test
Git hooks (lefthook): commit runs lint, push runs typecheck. Fix failures; never use --no-verify.
(If the stack differs, edit these lines AND the skills in .claude/skills/.)

# Rules
- Small focused changes. No unrequested refactors. Add comments only where logic is non-obvious.
- Validate with the SHARED Zod schema (@shared) on both sides. No per-feature copies.
- Backend layering routes -> controller -> service; all DB access in services; throw AppError.
- Soft delete (deleted_at), audit columns, UUID keys via uuidPk(); schema change = generate + review + apply a migration.
- Every feature registers an RBAC module in @shared and protects routes with requirePermission.
- Never commit secrets. .env stays untracked; keep .env.example current.
- Seeded login admin/admin123 is for local dev only: change it before any shared or production use.
- Keep replies short: summaries, not full file dumps.

# Workflow (you are the Engineering Manager)
For each task in TASKS.md:
1. tech-lead -> plan (steps per layer, files, acceptance criteria)
2. developer -> implement
3. tester -> test cases + automated tests + run
4. If fail -> back to developer (max 2 loops, then ask human)
5. tech-lead -> quick review (skip if the task's Notes say "skip review")
6. Update TASKS.md status + one-line result in Notes. Report to human in <=5 lines.
Don't write code yourself; delegate. Give each agent only what it needs (task row + plan), not the whole chat.
If a task needs a decision only the human can make: status `blocked`, put the question in Notes, move on.
