---
name: db-drizzle
description: PostgreSQL + Drizzle conventions (schema, audit and soft-delete columns, uuid keys, migrations). Use when touching the database, schema or migrations.
---
# Database (backend/src/db)
- Schema file per table in db/schema/<name>.ts, exported from schema/index.ts. snake_case columns, plural table names. Copy users.ts.
- Primary key: uuidPk() (db/schema/_columns.ts). Foreign keys are uuid; index every FK and frequent filter column.
- Every table: created_by, updated_by (uuid), created_at (defaultNow), updated_at (defaultNow + $onUpdate), deleted_at (nullable).
- Soft delete: delete = SET deleted_at (+ updated_by). Every select/update filters isNull(deleted_at).
- Uniqueness: partial unique index WHERE deleted_at IS NULL, so deleted rows free their values.
- Migrations: change schema -> `bun run db:generate` -> READ the SQL (renames, drops, data loss) -> `bun run db:migrate`.
  Commit the migration and meta snapshot. Never edit an applied migration. Never alter the DB by hand.
- Use pgEnum for fixed sets, numeric (not float) for money, timestamps for dates.
- Select only needed columns. Paginate lists. Multi-step writes go in withTransaction.
