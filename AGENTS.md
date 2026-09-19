# Agent notes — www.martinsladek.com

Static personal site. Prefer small, reversible edits. Do not invent a second deploy path unless asked.

## Slash commands (this project)

| Command | Meaning |
|---------|---------|
| `/deliver` | Feature branch → PR into `main` → merge the PR (rebase). Personal Cursor skill; not part of this repo. |
| `/deploy` | Publish **GitHub `main`** to the live Apache host via the project skill `.cursor/skills/deploy/`. Not `/deliver`. |

`/deploy` is a **skill** (scripts + `SKILL.md`), not something to re-implement ad hoc. Follow that skill: use gitignored `.cursor/deploy-config.ps1`, **pscp** only, overwrite only, never delete remote extras, never echo the PPK path, never upload from a dirty workspace.

## Content conventions

- Hide unused nav/tiles with **HTML comments**; do not delete pages or PDFs “to clean up”.
- `files/` = downloads (CV). `images/` = page graphics. `flags/` = nav flags. Do not use `pics/` in the repo.
- After CSS changes, bump `?v=…` on stylesheet links only when you want cache-bust; the file stays `css/style.css`.
- Prefer local assets under `/images/` over hotlinking CDNs.

## Docs vs production host

- Production redirects today: **`.htaccess`** (Apache).
- `_redirects` mirrors those rules for Cloudflare/Netlify later. Do not remove `.htaccess` “because `_redirects` exists”.
- GitHub Actions deploy is **`.github/workflows/deploy.yml.template` only** — inactive until renamed. Do not enable CI deploy unless the user asks.

## Secrets

Never commit: `.cursor/deploy-config.ps1`, private keys (`.ppk`, OpenSSH private keys), passwords, or real `SSH_KEY` values. Examples and placeholders only.

## If enabling CI deploy later (security sketch)

GitHub Actions needs an SSH private key in **encrypted Actions secrets** (not in git). Prefer a **dedicated deploy identity**, not the owner’s interactive account:

1. Separate Linux user (e.g. `deploy-www`) whose home/web tree is only the site directory.
2. Or same user + **forced command** / `authorized_keys` options so that key can only run `rrsync` / rsync into one path.
3. Key used only for deploy; revoke by deleting that one public key.

Password login for that key should stay off. Current `/deploy` + PuTTY PPK remains the live path until CI is explicitly enabled.
