# www.martinsladek.com

Personal static website (English + Czech). HTML, CSS, and a little JS. No build step.

Live host today: Apache on a friend’s SSH/SFTP server. Source of truth for publish is **GitHub `main`**, not a dirty local working tree.

## Layout

| Path | Role |
|------|------|
| `index.html` | English homepage (also root) |
| `en/`, `cz/` | Language pages |
| `css/`, `js/` | Styles and scripts |
| `images/` | Page graphics |
| `files/` | Downloads (CV) |
| `flags/` | Language flags |
| `.htaccess` | Apache redirects (production today) |
| `_redirects` | Same redirects for Cloudflare Pages / Netlify (unused until you switch host) |

## Local preview

From the repo root (any static server), for example:

```powershell
npx --yes http-server -p 8765 -c-1
```

Open `http://127.0.0.1:8765/`.

## Publish (current)

1. Land changes on GitHub `main` (in Cursor: `/deliver`).
2. Upload that `main` to the web host (in Cursor: `/deploy`).

`/deploy` clones/fetches GitHub `main`, stages files (keeps root `.htaccess`, drops other top-level dot dirs), and uploads with **pscp** (overwrite only; never deletes extra files already on the server).

Local secrets stay in gitignored `.cursor/deploy-config.ps1` (copy from `.cursor/deploy-config.ps1.example`). Never commit PPK paths or host credentials.

Agent conventions for `/deploy` and `/deliver` are in [AGENTS.md](AGENTS.md). The deploy skill lives under `.cursor/skills/deploy/`.

## Optional later: GitHub Actions + rsync

Not active. Template only:

- [`.github/workflows/deploy.yml.template`](.github/workflows/deploy.yml.template)

To enable: rename to `deploy.yml`, add repository secrets (`SSH_HOST`, `SSH_USER`, `SSH_KEY`, `REMOTE_PATH`), and prefer a **deploy-only** SSH key (see AGENTS.md). Do not put a real private key in the repo.

## Optional later: Cloudflare Pages

Point Pages at this GitHub repo, publish directory = repo root. Use `_redirects` instead of `.htaccess`. Turn off SPA “fallback to index.html” so missing URLs stay 404.
