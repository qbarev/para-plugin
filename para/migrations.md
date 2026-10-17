# Migrations

The vault schema version and what moving a vault to each version changes. `SCHEMA` in
`vault.md` is the version a vault is at; the version below is the one this plugin
expects. `paths.md` compares the two on every run; `/para:init` is the only skill that
migrates.

## Current schema

SCHEMA: 1

## How a migration runs

`/para:init` on a vault whose `SCHEMA` is lower than the current one. It runs every
version section below from the vault's `SCHEMA` + 1 up to the current one, in order, as
**one plan** (`init`'s plan → one «yes» → apply, the same order as a first run):

- A step that changes a file the vault owns lists that file and the change as its own
  plan line. Nothing is written before the «yes».
- **A step that changes a template** compares the plugin's new seed
  (`templates/<LANG>/`) with the vault's `Templates/` file — which is the source of
  truth and may carry the user's edits — and shows the diff in the plan. The vault's
  file is replaced only on a «yes» to that line; a «no» keeps it, and the report says
  so. A template is never replaced silently, and never because a «yes» was given in
  advance.
- `SCHEMA` in `vault.md` is raised to the new version **last**, after every other step
  has been applied, so an interrupted migration runs again from the start.
- A vault whose `SCHEMA` is **higher** than the current one is not migrated: `init`
  stops as `paths.md` «Schema version» says.

## Versions

A section per version: `### <n>` and the list of what migrating to it changes. A
version with nothing to change still gets its section, saying so.

### 1

The first schema. A vault reaches it only through `/para:init` creating or adopting it;
there is nothing to migrate.
