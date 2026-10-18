# Changelog

What changed, newest first. Before `0.1.0` this tooling was a vault template whose skills
lived inside the vault (`.claude/skills/`, `.claude/para/`); from `0.1.0` it is the
Claude Code plugin `para`. Each entry says what a vault has to do about it.

## 0.1.0 — the tooling becomes a plugin

The skills and the base layer leave the vault and become the plugin `para`
(`/para:inbox`, `/para:projects`, `/para:areas`, `/para:resources`, `/para:archive`,
`/para:remove`, `/para:vault-lint`, and the new `/para:init`).

- **Config** moves from `.claude/para/local/` to `.claude/para/`: `vault.md` (`REPO_ROOT`,
  `PARA_DIR`, `LANG`, `TASKS`, `SCHEMA`, `IGNORE`), `areas.md`, and `adapter.md` when
  `TASKS` is `mcp`. `PARA_DIR` is configurable (`.` puts the PARA folders in
  `REPO_ROOT`). `TODOIST_AREA_PROJECTS` is renamed `AREA_TASK_PROJECTS`.
- **`/para:init`** sets a vault up and keeps it current: an empty folder (A), an existing
  Obsidian vault sorted into PARA by moves only (B), or a vault that still carries the old
  embedded tooling (C). One plan, one «yes»; a re-run fills in what is missing; `SCHEMA`
  drives migrations.
- **Task backends.** Tasks go through a backend-neutral contract (`para/tasks.md`) and an
  adapter: `todoist`, `files` (tasks as notes in the vault) or any other MCP app
  (`mcp`, an adapter generated per vault). The overview field `todoist` is renamed
  `tasks_ref`; the old key is still read and `/para:vault-lint` reports it.
- **Languages.** Skills and the base layer are English; every string that reaches a note
  or the chat comes from `lang/<LANG>.md` (`ru`, `en`). Seed templates per language in
  `templates/<LANG>/`; the vault's own `Templates/` stays the source of truth.
- **Planning leaves the plugin**: the sprint, capacity, the rhythms and the planning
  exception to the confirmation tiers. A vault that used them keeps them in a file of
  its own (`.claude/local/planning.md`; scenario C writes it). The «in the sprint» count
  becomes «scheduled»: open tasks dated today or later.
- `/para:vault-lint` names each finding (the `lint.*` strings) and leaves `IGNORE`'d paths
  out of every check except duplicate names.
- **A vault on the old template:** enable the plugin at project level and run
  `/para:init` from the vault root (scenario C). It moves the config, renames the
  overview key, writes the planning file, and moves the old skills, base layer,
  `local.example/`, `CLAUDE.md` and the template's README and CHANGELOG to the Trash.

## Template — tasks move to Todoist

Tasks leave the vault. Todoist holds every task, its duration and its date; the vault
keeps what a project means.

- New `todoist.md`: pairing a project folder with a Todoist project (`todoist:` holds the
  id), area projects for tasks outside any project, what a task is, the two-week sprint,
  plan vs fact, and the planning rhythms followed on request.
- Removed from projects: `status`, `priority`, `value`, `estimate`, the `Tasks/` folder,
  the readiness gate. Existing projects keep these as **legacy** until migrated by hand;
  `/vault-lint` lists them.
- `/review` is removed. `/projects create` creates the Todoist project with one research
  task, whose result is the overview's scope section; `/projects task` writes to Todoist.
- `/archive` archives and restores the Todoist pair.
- `/vault-lint` adds the pairing checks, the legacy-format list and sync-conflict copies.
- `local/areas.md` gains `TODOIST_AREA_PROJECTS`.

## Template — folders lose their numbers

- `0. Inbox/` … `4. Archive/` become `Projects/`, `Areas/`, `Resources/`, `Archive/`.
- The inbox moves to the Todoist inbox. `Inbox/` stays only as Obsidian's folder for
  files made by hand; `/vault-lint` reports anything in it.
- The Inbox note type and its template are gone.

## Template — readiness gate and computed priority

- A project status `Idea`, a Definition of Ready, a research task per project, a value
  section and a `value` field; `priority` computed from `value` and `estimate`. (All of
  this was removed again when tasks moved to Todoist.)

## Template v1

First release: nine skills, an eight-file base layer, six note templates, an empty PARA
structure, and `.claude/para/local/` for the vault-specific config.
