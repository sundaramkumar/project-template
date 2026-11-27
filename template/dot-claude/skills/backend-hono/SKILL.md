---
name: backend-hono
description: Conventions for the Bun + Hono API in backend (layering, routes, validation, errors, responses, auth, audit). Use when creating or changing backend code.
---
# Backend (backend/src)
- Per feature, features/<name>/: routes (URL + validation, no logic) -> controller (thin: read params/body, call ONE service fn,
  reply via lib/response) -> service (all Drizzle queries + business rules; throws AppError).
- Routes: copy role.routes.ts: describeRoute({summary, tags}) + requirePermission('<module>', 'read|create|update|delete')
  + zValidator('json', <shared schema>, zHook). Schemas come from '@shared'. Specific paths before '/:id'.
- Responses: ok / created / paginated / noContent (lib/response) -> { success, data, meta? }.
- Errors: throw badRequest / notFound('Thing') / conflict / uniqueConflict / forbidden (lib/errors). Never return raw errors.
  Catch duplicate keys with isUniqueViolation (lib/db-errors).
- Ids/actor: paramId(c, 'Thing'), queryId, actorIdOf(c) (lib/ids). Never trust ids from the body for ownership.
- Lists: parseListQuery(c, { sortable, defaultSort }) with a column whitelist; buildMeta(total, page, limit); filters via lib/filter.
- Ownable modules: apply scopeCondition (lib/scope.ts) to list and get queries.
- Writes with more than one statement: withTransaction(tx => ...) and recordAudit(tx, { recordType, recordId, action, actorId, before, after }).
- Config only through config/env.ts (Zod). New variable -> also add it to .env.example.
- Auth is a JWT httpOnly cookie (app_token) or X-API-Key; permissions are resolved server-side per request. Public routes only in PUBLIC_PATHS (app.ts): avoid adding.
- Strict TypeScript, no `any`.
