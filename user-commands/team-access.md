---
description: (repo owner) Give teammates read access to the kit and the template repos
argument-hint: <github-username> [<github-username> ...]
---
Grant GitHub access: $ARGUMENTS

Every repo involved is a personal repo owned by `sundaramkumar`, so access is granted by adding each person as a
collaborator with `pull` (read-only) permission. No organisation and no team is involved.

The repos:
  - the kit: `sundaramkumar/project-template` — what teammates clone to install
  - the two templates named in {{KIT}}/app-template.conf: `APP_TEMPLATE_REPO` and `WIKI_TEMPLATE_REPO`

Read app-template.conf for the exact names rather than assuming them. A public repo needs nothing, so check each
one first and skip the public ones.

This changes who can read my repos. Do steps 1-2, then show me the exact plan (repos, users, permission) and wait
for my yes before step 3.

1. `gh auth status` must show a login with the `repo` scope. If it is missing, tell me to type
   `! gh auth refresh -h github.com -s repo`. If gh is missing: offer `brew install gh`.
2. For each repo: `gh api repos/sundaramkumar/<repo> --jq '{admin: .permissions.admin, private: .private}'`.
   - If `admin` is not true, stop: only the owner can add collaborators.
   - If `private` is false, note it as "public, nothing to do" and leave it out of the plan.
3. After my yes, for each PRIVATE repo and each user:
   `gh api -X PUT repos/sundaramkumar/<repo>/collaborators/<user> -f permission=pull`
   A user who is not already a collaborator gets an invitation by email.
4. Verify each repo: `gh api repos/sundaramkumar/<repo>/collaborators --jq '.[].login'`.
5. Reply in max 8 lines: which repos changed, which were already public, who is pending an invite, and what each
   member must do next — accept the invite email, then `! gh auth login`.
