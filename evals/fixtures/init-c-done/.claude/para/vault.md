# Vault config

Read the values. Never guess them, and never fall back to a default — if the vault's
file is missing, stop and say "run `/para:init` from the vault root" (`paths.md` owns
that rule).

## Keys

| Key | Value |
|---|---|
| `REPO_ROOT` | `__REPO_ROOT__` |
| `PARA_DIR` | `Second-brain` |
| `LANG` | `ru` |
| `TASKS` | `todoist` |
| `SCHEMA` | `1` |
| `IGNORE` | |

`PARA_ROOT` is not a key: it is `$REPO_ROOT/$PARA_DIR`, with `.` meaning `REPO_ROOT`
itself. Deriving it keeps `.obsidian/app.json` (`newFileFolderPath`) and
`.obsidian/templates.json` (`folder`) from disagreeing with it.
