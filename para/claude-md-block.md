# The CLAUDE.md block

What `/para:init` writes into the vault's `CLAUDE.md`: the lines from
`<!-- para:begin -->` to `<!-- para:end -->` below, both markers included, copied
verbatim. It is in English whatever `LANG` is, like the rest of the plugin's own text.

The block carries no values: they live in `vault.md`, so changing the config never makes
the block stale. Everything outside the markers belongs to the vault and is never
touched. `init` owns how the block is inserted and compared.

<!-- para:begin -->
## PARA vault

This folder is an Obsidian vault organised by the PARA method and run by the `para`
Claude Code plugin: `/para:inbox`, `/para:projects`, `/para:areas`, `/para:resources`,
`/para:archive`, `/para:remove`, `/para:vault-lint`; `/para:init` sets the vault up and
migrates it.

- **Two roots.** `REPO_ROOT` is this folder. It holds the tooling (`CLAUDE.md`,
  `.claude/`, `.obsidian/`) and no notes. `PARA_ROOT` is `REPO_ROOT/<PARA_DIR>`, or
  `REPO_ROOT` itself when `PARA_DIR` is `.`; it holds `Projects/`, `Areas/`,
  `Resources/`, `Archive/`, `Inbox/` and `Templates/`. Every note goes under `PARA_ROOT`.
- **Config** lives in `.claude/para/`: `vault.md` (the roots, `LANG`, `TASKS`, `SCHEMA`,
  `IGNORE`), `areas.md` (how Areas are grouped) and, when `TASKS` is `mcp`, `adapter.md`.
  The plugin never overwrites it.
- **Tasks** live in the task backend `TASKS` names, never in a list inside a note.
  With `TASKS` = `files` each task is a note of its own, managed by the plugin.
- **Templates** for new notes are `PARA_ROOT/Templates/`; edit them there.
- Start PARA sessions in this folder: the skills find their config at
  `.claude/para/vault.md` relative to the working directory.
<!-- para:end -->
