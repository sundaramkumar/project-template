Kick off this new project. $ARGUMENTS
Write no application code beyond what the application template's own setup requires.
1. App template: if docs/.app-setup-done does not exist, follow .claude/commands/app-setup.md.
2. Requirements: if docs/requirements/ has files not yet listed in docs/REQUIREMENTS.md, follow .claude/commands/requirements.md.
   If there are no requirement files and docs/BRIEF.md is empty, ask me (max 5 short questions): must-have features,
   users/roles, integrations, hosting, deadline. Wait for answers.
3. Plan: update TASKS.md. Keep T-001..T-003 as they are (template setup, test setup, cleanup/rebrand). Then add 8-15 small
   feature tasks from T-004 on, in build order (each under half a day, independently testable, following the add-feature
   checklist). Columns: ID | Task | Status | Notes. Notes = one-line acceptance criteria + the REQ ids covered (e.g. "REQ-004, REQ-005").
   Anything needing a client decision -> `blocked` with the question. Every Must requirement must be covered by at least one task.
4. If wiki/ exists, run /wiki-sync, then /wiki-build so the wiki and wiki/index.html match.
5. Reply with the task list (ID + title only), open questions, and anything I must do by hand. Max 20 lines.
