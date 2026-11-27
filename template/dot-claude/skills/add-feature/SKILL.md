---
name: add-feature
description: End-to-end checklist for adding a feature (module) across shared contract, DB, backend, frontend and RBAC in this Bun monorepo. Use for every new feature or screen.
---
# Add a feature, in this order
Use a singular name (`vendor`) for files and a plural module key (`vendors`) for RBAC/routes. Copy the users/roles feature.
1. Shared (shared/src): types/<name>.types.ts and schemas/<name>.schema.ts (Zod 4: create + update); export both from index.ts.
2. RBAC: add the module to ModuleKey + MODULES in shared/src/config/modules.ts (`ownable: true` only if the table has owner_id).
3. DB: backend/src/db/schema/<name>.ts, export it in schema/index.ts, then `bun run db:generate`, READ the SQL, `bun run db:migrate`.
4. Backend: features/<name>/<name>.{routes,controller,service}.ts; mount in src/routes.ts.
5. Frontend: features/<name>/api/<name>.api.ts + screens/*; nav item in shared/config/nav.config.ts (module key, implemented: true);
   routes in App.tsx wrapped in guard('<module>', ...).
6. `bun run seed` gives Admin full access to new modules; other roles get access in the Roles screen.
7. Tests (testing skill), then `bun run typecheck && bun run lint`.
Never skip a step. Never change the DB by hand.
