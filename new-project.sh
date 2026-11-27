#!/usr/bin/env bash
# Kick-start a project: AI dev team + application template + knowledge wiki + requirements intake.
# Usage: new-project.sh <project-folder> [--no-wiki] [--no-app-template] [--profile <name>]
#   <project-folder>     new or existing folder (created if missing). Existing files are NEVER overwritten.
#   --no-wiki            skip the wiki (it is added by default)
#   --no-app-template    skip cloning the application template (repo set in app-template.conf)
#   --profile <name>     wiki profile: web-app (default), monolith, mobile-app, data-pipeline, infrastructure, library
#
# Layout produced:
#   <project>/frontend  <project>/backend  <project>/shared   (application template)
#   <project>/wiki                                            (wiki, opens at wiki/index.html)
#   <project>/docs/requirements                                (put requirement documents here)
#   <project>/.claude                                          (agents, commands, skills)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T="$HERE/template"

usage() { sed -n '2,7p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit "${1:-1}"; }

WIKI=1; APPTPL=1; DEST=""; PROFILE_OVERRIDE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --no-wiki) WIKI=0; shift ;;
    --wiki) WIKI=1; shift ;;
    --no-app-template) APPTPL=0; shift ;;
    --profile) PROFILE_OVERRIDE="${2:?--profile needs a name}"; shift 2 ;;
    -h|--help) usage 0 ;;
    -*) echo "Unknown option: $1" >&2; usage 1 ;;
    *) DEST="$1"; shift ;;
  esac
done
[ -n "$DEST" ] || usage 1

# config (repos, branches, wiki profile)
: "${APP_TEMPLATE_REPO:=}"; : "${APP_TEMPLATE_BRANCH:=}"
: "${WIKI_TEMPLATE_REPO:=}"; : "${WIKI_TEMPLATE_BRANCH:=}"; : "${WIKI_PROFILE:=}"
[ -f "$HERE/app-template.conf" ] && . "$HERE/app-template.conf"
# An unset branch is left unset on purpose: clone_repo then takes the repo's own
# default branch, instead of this script guessing between master and main.
[ -n "$WIKI_PROFILE" ]         || WIKI_PROFILE=web-app
[ -n "$PROFILE_OVERRIDE" ]     && WIKI_PROFILE="$PROFILE_OVERRIDE"

mkdir -p "$DEST"
DEST="$(cd "$DEST" && pwd)"
NAME="$(basename "$DEST")"
echo "Kick-starting project in: $DEST"

TD="$(mktemp -d)"
trap 'rm -rf "$TD"' EXIT INT TERM

copy() {  # copy <src> <dest>; never overwrite
  mkdir -p "$(dirname "$2")"
  if [ -e "$2" ]; then echo "  skip (exists): ${2#"$DEST"/}"; else cp "$1" "$2"; echo "  added:         ${2#"$DEST"/}"; fi
}
copy_tree() {  # copy_tree <src-dir> <dest-dir>
  [ -d "$1" ] || return 0
  ( cd "$1" && find . -type f ! -name .DS_Store | sort ) | while IFS= read -r f; do
    copy "$1/${f#./}" "$2/${f#./}"
  done
}
# clone_repo <repo> <branch> <outdir>
# Tries HTTPS then SSH for the same path, and for each one the named branch then the repo's
# default branch - so a repo on master still clones when the config says main. 0 on success.
clone_repo() {
  local repo="$1" branch="$2" out="$3" url ssh=""
  [ -n "$repo" ] || return 1
  export GIT_TERMINAL_PROMPT=0
  case "$repo" in https://github.com/*) ssh="git@github.com:${repo#https://github.com/}" ;; esac
  for url in "$repo" "$ssh"; do
    [ -n "$url" ] || continue
    if [ -n "$branch" ]; then
      rm -rf "$out"
      if git clone -q --depth 1 --branch "$branch" "$url" "$out" 2>/dev/null; then return 0; fi
    fi
    rm -rf "$out"
    if git clone -q --depth 1 "$url" "$out" 2>/dev/null; then
      [ -n "$branch" ] && echo "  note: branch '$branch' not found, used the default branch ($(git -C "$out" rev-parse --abbrev-ref HEAD))"
      return 0
    fi
  done
  rm -rf "$out"
  return 1
}
source_note() { echo "$1@$(git -C "$2" rev-parse --short HEAD) ($3) cloned $(date +%F)"; }

echo "[1/3] AI dev team"
NAME_ESC="$(printf '%s' "$NAME" | sed 's/[&/\]/\\&/g')"
TMP="$(mktemp)"; sed "s/{{PROJECT_NAME}}/$NAME_ESC/g" "$T/CLAUDE.md" > "$TMP"
copy "$TMP" "$DEST/CLAUDE.md"; rm -f "$TMP"
copy "$T/TASKS.md"                       "$DEST/TASKS.md"
copy "$T/docs/BRIEF.md"                  "$DEST/docs/BRIEF.md"
copy "$T/docs/REQUIREMENTS.md"           "$DEST/docs/REQUIREMENTS.md"
copy "$T/docs/requirements/.gitkeep"     "$DEST/docs/requirements/.gitkeep"
copy "$T/dot-gitignore"                  "$DEST/.gitignore"
copy_tree "$T/dot-claude"                "$DEST/.claude"

echo "[2/3] Knowledge wiki"
WIKI_NOTE=""
if [ "$WIKI" = 1 ]; then
  if [ -z "$WIKI_TEMPLATE_REPO" ]; then
    echo "  skipped (no WIKI_TEMPLATE_REPO set in app-template.conf)"
  elif clone_repo "$WIKI_TEMPLATE_REPO" "$WIKI_TEMPLATE_BRANCH" "$TD/wiki"; then
    NOTE="$(source_note "$WIKI_TEMPLATE_REPO" "$TD/wiki" "$WIKI_TEMPLATE_BRANCH")"
    rm -rf "$TD/wiki/.git"
    # the template's own usage guide is not this project's wiki home page
    [ -f "$TD/wiki/index.html" ] && mv "$TD/wiki/index.html" "$TD/wiki/template-guide.html"
    # its Claude commands belong to the project, not inside wiki/
    if [ -d "$TD/wiki/.claude" ]; then
      copy_tree "$TD/wiki/.claude" "$DEST/.claude"
      rm -rf "$TD/wiki/.claude"
    fi
    copy_tree "$TD/wiki" "$DEST/wiki"
    mkdir -p "$DEST/docs"; echo "$NOTE" > "$DEST/docs/.wiki-template-source"

    # tell the agents the wiki exists and how to use it
    if [ -f "$T/CLAUDE.wiki.md" ] && ! grep -q '^# Knowledge wiki' "$DEST/CLAUDE.md"; then
      cat "$T/CLAUDE.wiki.md" >> "$DEST/CLAUDE.md"; echo "  updated:       CLAUDE.md (wiki section)"
    fi

    # fill the config placeholders (only while they are still placeholders)
    CFG="$DEST/wiki/wiki.config.json"
    if [ -f "$CFG" ] && grep -q '{{' "$CFG"; then
      PROFILE_ESC="$(printf '%s' "$WIKI_PROFILE" | sed 's/[&/\]/\\&/g')"
      sed -e "s/{{PROJECT_NAME}}/$NAME_ESC/g" -e "s/{{PROFILE}}/$PROFILE_ESC/g" "$CFG" > "$CFG.tmp" \
        && mv "$CFG.tmp" "$CFG"
      echo "  configured:    wiki/wiki.config.json (name=$NAME, profile=$WIKI_PROFILE)"
    fi

    # build the HTML views, then make sure wiki/index.html opens the wiki
    BUILT=0
    if command -v node >/dev/null 2>&1 && [ -f "$DEST/wiki/scripts/build-site.mjs" ]; then
      if ( cd "$DEST/wiki" && node scripts/build-site.mjs >/dev/null 2>&1 ); then BUILT=1; fi
    fi
    write_index() {  # only our own generated file is ever replaced
      if [ -f "$DEST/wiki/index.html" ] && ! grep -q 'generated by new-project.sh' "$DEST/wiki/index.html" 2>/dev/null; then
        echo "  skip (exists): wiki/index.html"; return 0
      fi
      cat > "$DEST/wiki/index.html"; echo "  added:         wiki/index.html"
    }
    if [ "$BUILT" = 1 ] && [ -f "$DEST/wiki/site/index.html" ]; then
      write_index <<HTML
<!doctype html>
<!-- generated by new-project.sh; rebuilt by /wiki-build -->
<meta charset="utf-8">
<title>$NAME wiki</title>
<meta http-equiv="refresh" content="0; url=./site/index.html">
<p>Opening the <a href="./site/index.html">$NAME wiki</a>&hellip;</p>
HTML
      WIKI_NOTE="built"
    else
      write_index <<HTML
<!doctype html>
<!-- generated by new-project.sh; rebuilt by /wiki-build -->
<meta charset="utf-8">
<title>$NAME wiki — not built yet</title>
<style>body{font:15px/1.6 system-ui,sans-serif;max-width:40rem;margin:4rem auto;padding:0 1rem}
code{background:#f1efe9;border-radius:4px;padding:.1rem .35rem}</style>
<h1>$NAME wiki</h1>
<p>The wiki pages are in <code>wiki/wiki/</code>. The HTML views have not been built yet.</p>
<p>In Claude Code, from the project folder, run <code>/wiki-build</code>
   (or <code>cd wiki &amp;&amp; node scripts/build-site.mjs</code>).
   This page is then replaced by the wiki home page.</p>
HTML
      WIKI_NOTE="not built"
      command -v node >/dev/null 2>&1 || echo "  note: node is not installed, so the wiki was not built"
    fi
  else
    echo "  COULD NOT CLONE $WIKI_TEMPLATE_REPO. Check access (gh auth login, or an SSH key), then re-run (existing files are skipped):"
    echo "     $HERE/new-project.sh \"$DEST\""
    WIKI_NOTE="failed"
  fi
else echo "  skipped (--no-wiki)"; fi

echo "[3/3] Application template"
APP_NOTE=""
if [ "$APPTPL" = 1 ]; then
  if [ -z "$APP_TEMPLATE_REPO" ]; then
    echo "  skipped (no repo set in app-template.conf)"
  elif clone_repo "$APP_TEMPLATE_REPO" "$APP_TEMPLATE_BRANCH" "$TD/src"; then
    NOTE="$(source_note "$APP_TEMPLATE_REPO" "$TD/src" "$APP_TEMPLATE_BRANCH")"
    rm -rf "$TD/src/.git"
    # the template's own CLAUDE.md must not replace ours: keep it for /app-setup to read
    if [ -f "$TD/src/CLAUDE.md" ]; then
      mkdir -p "$DEST/docs"; copy "$TD/src/CLAUDE.md" "$DEST/docs/APP-TEMPLATE-CLAUDE.md"; rm "$TD/src/CLAUDE.md"
    fi
    # merge .gitignore lines instead of skipping them
    if [ -f "$TD/src/.gitignore" ]; then
      grep -vxFf "$DEST/.gitignore" "$TD/src/.gitignore" >> "$DEST/.gitignore" || true
      rm "$TD/src/.gitignore"; echo "  merged:        .gitignore"
    fi
    copy_tree "$TD/src" "$DEST"
    mkdir -p "$DEST/docs"; echo "$NOTE" > "$DEST/docs/.app-template-source"
    APP_NOTE="installed"
  else
    echo "  COULD NOT CLONE $APP_TEMPLATE_REPO. Check you have access (gh auth login, or an SSH key with access to the org), then re-run (existing files are skipped):"
    echo "     $HERE/new-project.sh \"$DEST\""
    APP_NOTE="failed"
  fi
else echo "  skipped (--no-app-template)"; fi

[ -d "$DEST/.git" ] || { git init -q "$DEST" && echo "git init done"; }

# A project with no commits cannot be diffed, reverted or branched, and every file
# shows as untracked - which reads as "the wiki is missing" when it is merely uncommitted.
if ! git -C "$DEST" rev-parse HEAD >/dev/null 2>&1; then
  if git -C "$DEST" add -A 2>/dev/null \
     && git -C "$DEST" commit -q -m "Scaffold $NAME

Created by new-project.sh. Templates recorded in docs/.app-template-source
and docs/.wiki-template-source." 2>/dev/null; then
    echo "git: baseline commit created ($(git -C "$DEST" rev-parse --short HEAD))"
  else
    echo "git: no baseline commit - set user.name and user.email, then: git add -A && git commit"
  fi
fi

cat <<MSG

Done. Next:
  1. Put the requirements in $DEST/docs/requirements/ (any format) and/or fill docs/BRIEF.md
  2. cd "$DEST" && claude
  3. Run /kickoff
     (/kickoff installs the app template's software, reads the requirements, and builds TASKS.md)
     The agents load from .claude/agents/ when the session starts. To list them: ls .claude/agents

  Wiki: $DEST/wiki/index.html
MSG
[ "$APP_NOTE" = failed ]  && echo "  NOTE: application template was NOT cloned - see message above."
[ "$WIKI_NOTE" = failed ] && echo "  NOTE: wiki template was NOT cloned - see message above."
[ "$WIKI_NOTE" = "not built" ] && echo "  NOTE: wiki HTML not built yet - run /wiki-build in the project."
exit 0
