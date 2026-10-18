# Vault config

**Vault-specific.** The vault keeps its copy at `<REPO_ROOT>/.claude/para/vault.md`;
this is the template it is filled in from. The plugin never overwrites the vault's copy,
so a plugin update cannot conflict with how this vault is set up.

Read the values. Never guess them, and never fall back to a default — if the vault's
file is missing, stop and say "run `/para:init` from the vault root" (`paths.md` owns
that rule).

## Keys

| Key | Value |
|---|---|
| `REPO_ROOT` | *absolute path to the vault root (the directory holding `.obsidian/` and `.claude/`) — no `~`, no relative path* |
| `PARA_DIR` | *name of the subfolder holding the PARA folders, or `.` when they sit directly in `REPO_ROOT`* |
| `LANG` | *a language code that has `lang/<LANG>.md` in the plugin (`ru`, `en`) — the language of notes and of what is printed to chat* |
| `TASKS` | *`todoist`, `files` or `mcp` — where tasks live* |
| `SCHEMA` | *integer, starts at `1` — the vault schema version; a plugin with a higher one asks for a migration* |
| `IGNORE` | *paths relative to `REPO_ROOT` that PARA never touches (`paths.md` «IGNORE»), each in backticks, separated by commas; may be empty* |

`PARA_ROOT` is not a key: it is `$REPO_ROOT/$PARA_DIR`, with `.` meaning `REPO_ROOT`
itself. Deriving it keeps `.obsidian/app.json` (`newFileFolderPath`) and
`.obsidian/templates.json` (`folder`) from disagreeing with it.
