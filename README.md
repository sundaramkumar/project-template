# Project Kick-start Kit

**Start here: BOOTSTRAP.md.** It has the exact prompts to run everything from inside Claude Code
(install, GitHub login, team access, new project). The terminal steps below are the manual alternative.

One command sets up a new project with:
1. a multi-agent AI dev team (tech-lead, developer, tester; the main Claude session is the Engineering Manager)
2. the application template (Bun + Hono + Drizzle + PostgreSQL + React 19 + Tailwind), cloned from GitHub;
   `/kickoff` then installs the software it needs and sets up the database
3. a knowledge wiki, maintained by Claude, which renders to HTML at `wiki/index.html`
plus a requirements intake: drop requirement documents in, Claude turns them into a tracked list and a task plan.

    You (boss) -> main Claude session (Engineering Manager, defined in CLAUDE.md)
                    -> tech-lead (plans + reviews) -> developer (builds) -> tester (tests)

## Contents
    BOOTSTRAP.md          prompts to do everything from Claude Code (start here)
    install.sh            installs /new-project and /team-access for the current user
    user-commands/        user-level slash commands: /new-project /team-access /update-kit
    new-project.sh        the kick-start script (called by /new-project)
    app-template.conf     the template repos + branches to clone, and the wiki profile
    template/             copied into every project
      CLAUDE.md  TASKS.md  dot-gitignore
      docs/BRIEF.md             short project description
      docs/REQUIREMENTS.md      requirement register (REQ-001...), filled by /requirements
      docs/requirements/        INBOX: drop requirement documents here
      dot-claude/               becomes .claude/
        agents/   tech-lead, developer, tester
        skills/   add-feature, backend-hono, db-drizzle, frontend-react, testing, code-review
        commands/ /kickoff  /requirements  /app-setup  /add-task  /task
        settings.json
      CLAUDE.wiki.md            wiki section appended to the project's CLAUDE.md

The wiki itself is not kept in this kit: it is cloned per project from the wiki template
named in app-template.conf, so wiki improvements reach new projects without touching the kit.

## Project layout
Every project gets the same shape, so a team member knows where things are without asking:

    <project>/
      frontend/            React SPA        (application template)
      backend/             Hono API         (application template)
      shared/              API contract     (application template)
      wiki/                knowledge wiki - open wiki/index.html
      docs/requirements/   INBOX: drop requirement documents here
      docs/BRIEF.md        short project description
      .claude/             agents, commands, skills
      CLAUDE.md  TASKS.md

## One-time setup
1. Clone the kit somewhere permanent:   git clone https://github.com/sundaramkumar/project-template.git ~/project-template
   (kit owner moving an existing folder: mv <folder> ~/project-template)
2. chmod +x ~/project-template/new-project.sh
   echo "alias newproj='~/project-template/new-project.sh'" >> ~/.zshrc && source ~/.zshrc
3. The template repos may be private. Check your machine can clone the ones in app-template.conf:
       git ls-remote https://github.com/sundaramkumar/application-template.git
       git ls-remote https://github.com/sundaramkumar/llm-wiki-template.git
   If either asks for a password or fails, run `gh auth login` (or add an SSH key with access).
   Every team member needs read access to both repos and a working git login on their own machine.
4. Have Claude Code and git. Bun and PostgreSQL are checked and installed by /kickoff, with your OK.

## For every new project
1. newproj ~/projects/my_app
   Options: --no-wiki  --no-app-template.  Safe on existing folders: nothing is overwritten.
2. Give Claude the requirements (any of these):
   a. Drop files into  my_app/docs/requirements/  (PDF, Word, Excel, HTML, Markdown, text, screenshots)
   b. At any time:   /requirements ~/Downloads/client-spec.pdf     (one file or a whole folder)
   c. A web link:    /requirements https://example.com/spec
   d. Paste text:    /requirements <paste emails, meeting notes, chat messages>
   e. Only a rough idea: a few bullets in docs/BRIEF.md
3. cd ~/projects/my_app && claude        then /agents (expect tech-lead, developer, tester).
4. /kickoff
   - /app-setup: checks Bun, PostgreSQL, ports; shows ONE table; installs after your yes; creates a project-named database,
     .env (random JWT secret), migrates and seeds, starts the app and checks /api/health and login
   - reads the requirements (docs/requirements/ + docs/REQUIREMENTS.md; unclear items become Open items, never guesses)
   - updates TASKS.md: T-001..T-003 (template setup, test setup, cleanup) + 8-15 feature tasks citing REQ ids
5. Open http://localhost:5175, log in as admin / admin123 (change it). Then /task T-002, /task T-003 ...
   and after each task: /clear. /add-task <text> adds a task.
6. New client documents later: /requirements <file>, then /add-task for the new work.
   After a few tasks: /wiki-sync, then /wiki-build to refresh wiki/index.html.
   Blocked tasks need your decision: write it in Notes, set status todo.

## Known defects in the application template (found when building this kit)
They are tracked as T-002 and T-003 in every new project. Better: fix them once in the template repo, then delete the tasks.
- Backend and frontend READMEs describe a CRM project (wrong ports, modules that do not exist). Root README, ARCHITECTURE.md and OVERVIEW.md are correct.
- frontend/.env.example says VITE_API_URL=http://localhost:3000, but the API runs on 3005 (the client already defaults to 3005). Do not copy it.
- Tests cannot run: no frontend src/__tests__/setup.ts (Vitest config requires it), no backend .env.test, no tests at all.
- Playwright config (ports 3000/5173) and all e2e specs are CRM leftovers.
- Leftovers: warehouse types/constants in @shared, unused deps (@hello-pangea/dnd, xlsx, redux-thunk), "Symatis CRM API" docs title, Symatis branding.
- Every new project would use database `application` and ports 3005/5175. /app-setup picks a project-named database and checks ports.

## Tips
- One task = one /task run = then /clear. Biggest token saver.
- "skip review" in a task's Notes skips the tech-lead review for trivial changes.
- Git hooks from the template: commit runs lint, push runs typecheck. Agents must fix failures, never use --no-verify.
- /usage shows consumption. Weak tests? change `model: haiku` to `sonnet` in .claude/agents/tester.md.
- Subagents cannot call subagents, which is why the main session is the manager.

## Customising
- Another stack: change the Stack lines in CLAUDE.md and the skills; point app-template.conf at another repo.
- New skill: copy a skill folder, rewrite it, add its name to `skills:` in .claude/agents/developer.md.
- Edit anything under template/ to change future projects (existing projects keep their copy).
- Change the wiki itself in the wiki template repo; new projects pick it up on their next clone.

## Troubleshooting
- "COULD NOT CLONE": your git login cannot read the repo. Fix the login or ask for access, then re-run newproj on the same folder.
- Agents/commands not listed: exit and restart `claude`.
- Developer ignores conventions: add "First read .claude/skills/<name>/SKILL.md" to that agent's prompt
  (preloading skills through the `skills:` line has had open bugs in Claude Code).
- newproj: command not found: open a new terminal tab or run `source ~/.zshrc`.
