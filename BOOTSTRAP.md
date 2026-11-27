# Everything from the Claude Code prompt

Start Claude Code in your `~/projects` folder (desktop app: New session -> choose `~/projects`).
Lines that start with `!` run directly in the prompt (needed only for GitHub login). Everything else is a normal message or slash command.

## A. One-time install (each person, once)
Paste this message:

    Install my AI dev team kit. The kit folder is at <KIT LOCATION>. Move it to ~/project-template if it is not there already,
    then run `bash ~/project-template/install.sh` and show me the output. If gh (GitHub CLI) or Homebrew is missing, tell me.

Teammates paste this instead - this one repo is the whole kit:

    Clone https://github.com/sundaramkumar/project-template.git into ~/project-template, then run
    `bash ~/project-template/install.sh` and show me the output. If gh or Homebrew is missing, tell me.

Then restart Claude Code so `/new-project`, `/team-access` and `/update-kit` appear. Later, `/update-kit` pulls the latest kit.

## A2. Publish the kit (kit owner, when it changes)
The kit lives at github.com/sundaramkumar/project-template, so publishing a change is an ordinary push. Needs
section B (GitHub login) first. Paste:

    Show me `git -C ~/project-template status --short` and `git -C ~/project-template diff --stat`, wait for my OK,
    then commit and push.

If my local kit folder still points somewhere else, repoint it first:
`git -C ~/project-template remote set-url origin https://github.com/sundaramkumar/project-template.git`.

Teammates then run `/update-kit` to pull it.

Whoever can read the kit repo can read the agents, skills and scripts. The application template and the wiki template
are separate repos with their own access; if either is private, run /team-access to add teammates to it.

## B. GitHub login (each person, once)
    ! gh auth login
Choose GitHub.com -> HTTPS -> yes to "authenticate Git" -> login with the browser. If `gh` is missing: ask Claude "install gh with Homebrew".
If a template repo sits behind an organisation with SAML SSO, also authorise your login for that organisation
(GitHub -> Settings -> Configure SSO).

## C. Give the team access (repo owner, once per person)
    ! gh auth refresh -h github.com -s repo
    /team-access alice bob carol
Every repo is a personal repo under `sundaramkumar`, so people are added as read-only collaborators; there is no
organisation or team. Claude shows the plan (repos, users, permission) and waits for your yes. Public repos need
nothing and are skipped. New people get an invite email to accept. Only the repo owner can run this.

## D. Start a project (every time)
    /new-project my_app
Claude then, in this one session:
1. checks GitHub access to the template repos and tells you exactly what to fix if it fails
2. creates ~/projects/my_app with the AI team, the wiki, the requirements folders and the application template:

       my_app/frontend  my_app/backend  my_app/shared  my_app/wiki  my_app/docs/requirements

3. asks where your requirements are: a file/folder path, a link, pasted text, or only a rough idea
4. shows ONE table of software to install (Bun, PostgreSQL...), installs after your yes, creates the database, migrates, seeds, starts the app
5. reads the requirements and writes TASKS.md
Options: `/new-project my_app --no-wiki`, `--no-app-template`, `--profile <name>` (wiki profile, default web-app).
Requirements can be given up front: `/new-project my_app requirements: ~/Downloads/spec.pdf`.
When it finishes, the wiki is at `~/projects/my_app/wiki/index.html`.

## E. Build (every task)
Open `~/projects/my_app` as the working folder in a NEW Claude Code session (desktop app: New session -> choose the folder).
This loads the three agents from `.claude/agents/`. Then:

    /task T-002              (plan -> build -> test -> review; 5-line report)

To confirm the agents are there, run `ls .claude/agents` (expect tech-lead.md, developer.md, tester.md).
The `/agents` command no longer lists them: Claude Code removed that wizard. Nothing is wrong if it is missing -
the agents are files, picked up when the session starts in the project folder, and /task delegates to them by name.
    /clear
    /add-task <what you want>      /requirements <new file or link or pasted text>      /wiki-sync      /wiki-build

Open http://localhost:5175 and log in as admin / admin123 (change it).

## F. Read the wiki
Open the file directly - nothing has to be running:

    open ~/projects/my_app/wiki/index.html

The pages are markdown in `wiki/wiki/`; the HTML under `wiki/site/` is generated from them, and the home page links
the other views: the system map, the risk register and the page graph. After `/wiki-sync`, or any edit to the pages,
run `/wiki-build` and reload.

Claude writes the pages, you read them. Never edit anything in `wiki/site/` by hand.

## Why E needs a new session
Claude Code loads a project's agents, skills and CLAUDE.md when a session starts in that folder. `/new-project` runs from `~/projects`,
so it can create and set up the project, but the team only loads when you open the project itself.
