---
name: deploy
description: >-
  Upload GitHub main of this website repo to the live web host with pscp
  (overwrite only, never delete remote extras). Use only when the user types
  /deploy or deploy as an explicit publish command in this project.
disable-model-invocation: true
---

# Deploy

Project-scoped (`.cursor/skills/deploy`). Publish **GitHub `main`** to the live web host. Not `/deliver`. Not the open workspace.

## Config (gitignored)

`.cursor/deploy-config.ps1` holds `$RepoUrl`, `$RemoteSpec`, `$WorkRoot`, `$DeployPpk`. Never commit it. Never echo `$DeployPpk`.

Public repo has only `.cursor/deploy-config.ps1.example` (placeholders).

## First run (no config)

1. `powershell -NoProfile -File .cursor/skills/deploy/scripts/list-putty-sessions.ps1` (JSON: name, user, host, hasPpk — no key path).
2. Ask the user to pick a PuTTY session (`AskQuestion`). Include a Manual option.
3. Chosen session: `fill-deploy-config.ps1 -SessionName "<name>"`. Show the printed `RemoteSpec` and ask to confirm or edit `/home/...` if needed. Do not print the PPK path.
4. Manual: copy the example to `deploy-config.ps1` and ask for user, host, remote directory, and PPK path. Do not invent a Google Drive path.
5. Then run `deploy-www.ps1`.

`.ppk` is PuTTY, not OpenSSH. OpenSSH keys live in `~/.ssh/id_ed25519`. PuTTY stores the `.ppk` path on the session (`PublicKeyFile`). `~/.ssh/*.ppk` is only a fallback in the example, not a standard.

No Cursor dialog API for this form. Use `AskQuestion`.

## Later runs

```
powershell -NoProfile -ExecutionPolicy Bypass -File .cursor/skills/deploy/scripts/deploy-www.ps1
```

Network without asking. **pscp** only. Staging drops every `.*` except `.htaccess`.

## Never

- Hardcode host, user, or PPK path into git-tracked files.
- Upload from the workspace.
- Delete files on the server.
- Rewrite the scripts on each `/deploy` unless the user asked to change deploy behavior.

## Done

Overwrote files on the web host. No key path. No command recap.
