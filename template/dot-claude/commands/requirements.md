Ingest requirements. Input: $ARGUMENTS
(a file path, a folder, a URL, pasted text, or empty = everything new in docs/requirements/)

1. Collect sources into docs/requirements/ (the inbox):
   - empty: every file there not yet listed under "Sources" in docs/REQUIREMENTS.md.
   - path outside the inbox: copy it in (never modify the original).
   - URL: fetch it, save as docs/requirements/YYYY-MM-DD_<slug>.md.
   - pasted text: save as docs/requirements/YYYY-MM-DD_pasted.md.
2. Read each source fully. PDFs: use Read. docx/xlsx/html: convert to text first (pandoc, or python3 with
   python-docx/openpyxl); if a converter is missing, tell me what you need to install and wait.
3. If wiki/ exists: add or update a source page for each source following the rules in wiki/CLAUDE.md (source page,
   affected pages, index, log), then run /wiki-build.
4. Update docs/REQUIREMENTS.md:
   - add the source under Sources;
   - add each requirement as one row: next free REQ-nnn, one testable sentence, module, priority (Must/Should/Could), status `new`, source file;
   - changed requirement: edit its row and note the change in Status; never renumber or delete;
   - anything ambiguous, missing or contradictory goes to Open items. Do NOT guess.
5. Reply in max 10 lines: sources read, requirement counts (new/changed), the top 5 open questions.
