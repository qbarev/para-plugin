# Paths

Every path in every PARA skill comes from this file. A skill must never spell out a
vault path of its own, and must never use a relative path — the working directory is
not guaranteed to be either root.

## Two roots — do not confuse them

There are two nested directories and both have been called "the vault root" in the
past. That ambiguity has already created stray note folders directly in `REPO_ROOT`
once. Always say which one you mean.

**The values come from the vault config `.claude/para/vault.md`, and from nowhere
else.** That file belongs to the vault, not to the plugin: the plugin ships only
`config.example/`, which is what lets the plugin be updated without ever colliding
with how a particular vault is set up.

```
REPO_ROOT = <REPO_ROOT in .claude/para/vault.md>
PARA_DIR  = <PARA_DIR in .claude/para/vault.md>
PARA_ROOT = $REPO_ROOT/$PARA_DIR     (PARA_DIR = "." means PARA_ROOT is REPO_ROOT itself)
```

If `.claude/para/vault.md` does not exist, **stop and say so** — "run `/para:init`
from the vault root" (every skill but `/para:init`, which is what creates it). Never
guess a root from the working directory, never fall back
to a default, and never write config or notes anywhere else: a wrong root writes notes
into the wrong vault.

**Schema version.** Right after reading `vault.md`, compare its `SCHEMA` with
«Current schema» in `migrations.md`. Every skill except `/para:init` does this before
anything else and stops on a mismatch, writing nothing — a skill running against a
schema it was not written for half-works, which is worse than stopping:

- `SCHEMA` lower than the plugin's, or missing → say the `common.schema_behind` string
  (`{vault}` = the vault's value, `0` when missing; `{plugin}` = the plugin's) and stop.
- `SCHEMA` higher than the plugin's → say the `common.schema_ahead` string and stop.

## Language

`LANG` in `vault.md` is the language of the vault: a code with a file `lang/<LANG>.md`
and seed templates `templates/<LANG>/` in the plugin (`ru` and `en` ship; a new language
is those files and needs no skill edits). Everything a skill writes into a note is in
that language, and so is what it prints to chat. Every *fixed* string — section
headings, frontmatter vocabulary values, the research-task name, report headings, route
names, lint finding names — comes from the plugin's `lang/<LANG>.md`, found as
`../../lang/<LANG>.md` relative to a skill's base directory, the way `../../para/` is.

- A skill names a fixed string by its **key**: «the `project.dod` section», «the
  `task.unpaired` string». It reads the file once per run and takes the string from
  there; it never translates a fixed string from memory and never keeps a second copy.
  Placeholders in braces (`{n}`) are filled by the skill.
- The examples in the plugin's own text are written in English whatever `LANG` is; the
  output follows `LANG`, not the language of the examples.
- **Switching language.** Notes and stored values are always in `LANG`. Chat output is in
  `LANG` unless the user explicitly asks for another language for that reply, which is
  honoured for that reply only. The language the user happened to type in is never such a
  request.
- **Plural placeholders.** `{n|a|b|c}` stands for `n` followed by a noun form. With three
  forms (Russian): `a` when `n` mod 10 = 1 and `n` mod 100 ≠ 11; `b` when `n` mod 10 is
  2–4 and `n` mod 100 is not 12–14; `c` otherwise. With two forms (English): `a` when
  `n` = 1, `b` otherwise. With three forms, 1, 21 and 101 take `a`; 2, 3 and 4 take `b`; 5–20, 11–14 and 25 take
  `c`. Other placeholders (`{k}`,
  `{title}`) are substituted as they are.
- `vault.md` missing means `LANG` is unknown: the stop message above is said in English.
  A `LANG` whose `lang/<LANG>.md` or `templates/<LANG>/` is missing: stop and say so.
- Frontmatter keys stay Latin and identical in every language. Machine values (such as
  a task's `status: open | done`) are not localised; vocabulary values (such as a
  resource's `type`) are keys in `lang/<LANG>.md`.

### How `vault.md` is found

Reading `REPO_ROOT` from a file requires knowing where that file is — the one piece of
bootstrapping in the whole base layer. It rests on the session's working directory
being the vault root, so the config is reachable as `.claude/para/vault.md`. That is the
**only** place a relative path is permitted. Everything after it uses the `REPO_ROOT`
just read, because a later tool call may start somewhere else entirely. If the session
was started in a subfolder, the file is not there: that is the "missing" case above, not
a reason to search upwards.

- **`REPO_ROOT`** holds the tooling: `CLAUDE.md`, `.claude/`, `.obsidian/`. **No note
  ever goes here** (with `PARA_DIR = .` the rule reads: no note outside the PARA folders).
  If a note or a project folder appears directly in `REPO_ROOT` outside them, that is a bug.
- **`PARA_ROOT`** holds the vault proper: the four PARA folders, `Inbox/` and `Templates/`.
  **Every path below is relative to `PARA_ROOT`.**

`.obsidian/` sits in `REPO_ROOT`, so Obsidian's own vault root is `REPO_ROOT` and the
PARA folder is just a folder inside it. Two consequences: basenames must be unique
across `REPO_ROOT`, not merely `PARA_ROOT`; and `.obsidian/app.json` sets
`newFileFolderPath` to `<PARA_DIR>/Inbox` — the path there is relative to
`REPO_ROOT` and does not follow this file's convention.

## The task backend and its adapter

Tasks live in the backend `TASKS` names in `vault.md` (`tasks.md` owns what that means).
Skills run operations **per the adapter for `TASKS`**:

- `TASKS` = `todoist` or `files` → the adapter is `adapters/<TASKS>.md` in the base layer;
- `TASKS` = `mcp` → the adapter is `<REPO_ROOT>/.claude/para/adapter.md`, in the vault.

## The inbox is the backend's inbox, not a folder

The capture buffer is the task backend's inbox (shown to the user as the `inbox.name`
string): `inbox.add`, `inbox.list`,
`inbox.close` in `tasks.md`. A capture is a task: the thought as its text, anything
longer in its description. It becomes a note only when `/inbox process` routes it into a
PARA folder, and the capture is closed then. No skill ever writes a capture to disk
(the `files` backend is the one exception, and its adapter says so).

**When `TASKS = files`, `Inbox/` is the inbox, and every file in it is a capture** —
including one made by hand in Obsidian. `inbox.add` writes there, one task note each,
and `inbox.list` reads it (`adapters/files.md`). Skills point here for this rule. The
paragraph that follows describes every other backend.

Under every backend but `files`, `Inbox/` under `PARA_ROOT` exists for one reason: Obsidian needs a folder to put a file
created by hand (`newFileFolderPath`), and the vault is not meant to be edited from
Obsidian. It is a fallback, never a destination — no skill writes into it, no template
belongs to it, and anything found there is a stray that `/vault-lint` reports and
`/inbox process` offers to route like any other capture.

## Map

| What | Path under `PARA_ROOT` |
|---|---|
| Obsidian's fallback for new files; the inbox itself when `TASKS = files` | `Inbox/` |
| Projects | `Projects/` |
| Areas | `Areas/` |
| Resources | `Resources/` |
| Archive | `Archive/` |
| Templates | `Templates/` |

Project folder: `Projects/PROJ-xxxx <title>/`, containing the overview note
`PROJ-xxxx <title>.md` plus `Notes/`, `Resources/`, `Results/`. Tasks are not in the
overview — they are in the backend project (`tasks.md`); when `TASKS = files` they are
the notes in the project's own `Tasks/` folder (`adapters/files.md`), created with the
first task. Whether a `Tasks/` folder is legacy depends on `TASKS`
(`note-format.md` «Legacy fields»).

Templates by destination — see `note-format.md` for how to apply them:

| Destination | Template |
|---|---|
| `Projects/` | `Templates/Project.md` |
| `Areas/` | `Templates/Area.md` |
| `Resources/` | `Templates/Resource.md` |
| `<project>/Notes/`, `<project>/Results/` | `Templates/Note.md` |
| a task (only when `TASKS = files`) | `Templates/Task.md` |

Service files (dotfiles — Obsidian ignores them, they are not notes):

| What | Path |
|---|---|
| Journal of ids freed by deletion | `Archive/.removed-ids` |

## IGNORE — what PARA leaves alone

`IGNORE` in `vault.md` lists paths, relative to `REPO_ROOT`, that PARA never touches:
daily notes, attachments, the user's own Obsidian templates, and whatever the user
told `/para:init` to leave as it is. `/para:init` fills it when it adopts an existing
vault; the user may edit it. A path is ignored when it **is** an entry or lies
**under** one (`Daily` covers `Daily/2026-09-01.md`). No skill moves, edits, archives or
deletes an ignored path, and no skill writes into one.

The value is the backticked items of the `IGNORE` row, separated by commas. To filter a
list of absolute paths (one per line) down to those outside `IGNORE`:

```bash
ignore_list=$(sed -n 's/^| `IGNORE` |\(.*\)|[[:space:]]*$/\1/p' "$REPO_ROOT/.claude/para/vault.md" \
  | grep -oE '`[^`]+`' | tr -d '`')
not_ignored() { while IFS= read -r p; do r=${p#"$REPO_ROOT"/}; r=${r#./}; skip=
  while IFS= read -r i; do [ -n "$i" ] && case "$r" in "$i"|"$i"/*) skip=1 ;; esac
  done <<<"$ignore_list"; [ -z "$skip" ] && printf '%s\n' "$p"; done; }
```

`IGNORE` hides nothing from the duplicate-name check: Obsidian resolves links across the
whole of `REPO_ROOT`, ignored or not (`note-format.md` «Name collisions»).

## Rules

- Quote every path. `REPO_ROOT` and most note titles contain spaces; an unquoted path
  silently splits into two arguments.
- Build paths by expanding `PARA_ROOT` in full. Never `cd` into the vault and use a
  relative path: another tool call may start elsewhere.
- Before writing a new file, confirm the resolved absolute path starts with
  `$PARA_ROOT/`. A path that lands in `REPO_ROOT` means a prefix was dropped.
