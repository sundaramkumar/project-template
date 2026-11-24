
# Knowledge wiki
Project knowledge lives in `wiki/wiki/` as markdown, and renders to HTML at `wiki/index.html`.
Read `wiki/wiki/index.md` and the relevant module page before planning a task.
The rules the wiki follows are in `wiki/CLAUDE.md`; page shapes are in `wiki/page-templates/`.

After a task is marked done, run `/wiki-sync`, then `/wiki-build` to refresh the HTML.

Commands: `/wiki-init`, `/wiki-sync`, `/wiki-build`, `/wiki-ask`, `/wiki-lint`.
Never edit anything in `wiki/site/` by hand - it is generated.
