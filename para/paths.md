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
from the vault root". Never guess a root from the working directory, never fall back
to a default, and never write config or notes anywhere else: a wrong root writes notes
into the wrong vault.

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

## Inbox is Todoist, not a folder

The capture buffer is the **«Входящие» project in Todoist** (`projectId: "inbox"` in the
Todoist tools). A capture is a Todoist task: the thought in `content`, anything longer
in `description`. It becomes a note only when `/inbox process` routes it into a PARA
folder, and the task is completed then. No skill ever writes a capture to disk.

`Inbox/` under `PARA_ROOT` exists for one reason: Obsidian needs a folder to put a file
created by hand (`newFileFolderPath`), and the vault is not meant to be edited from
Obsidian. It is a fallback, never a destination — no skill writes into it, no template
belongs to it, and anything found there is a stray that `/vault-lint` reports and
`/inbox process` offers to route like any other capture.

## Map

| What | Path under `PARA_ROOT` |
|---|---|
| Obsidian's fallback for new files | `Inbox/` |
| Projects | `Projects/` |
| Areas | `Areas/` |
| Resources | `Resources/` |
| Archive | `Archive/` |
| Templates | `Templates/` |

Project folder: `Projects/PROJ-xxxx <Название>/`, containing the overview note
`PROJ-xxxx <Название>.md` plus `Notes/`, `Resources/`, `Results/`. Tasks are not in the
vault — they are in the paired Todoist project (`todoist.md`). A `Tasks/` folder in an
older project is legacy (`note-format.md`).

Templates by destination — see `note-format.md` for how to apply them:

| Destination | Template |
|---|---|
| `Projects/` | `Templates/Project.md` |
| `Areas/` | `Templates/Area.md` |
| `Resources/` | `Templates/Resource.md` |
| `<Проект>/Notes/`, `<Проект>/Results/` | `Templates/Note.md` |

Service files (dotfiles — Obsidian ignores them, they are not notes):

| What | Path |
|---|---|
| Journal of ids freed by deletion | `Archive/.removed-ids` |

## Rules

- Quote every path. `REPO_ROOT` and most note titles contain spaces; an unquoted path
  silently splits into two arguments.
- Build paths by expanding `PARA_ROOT` in full. Never `cd` into the vault and use a
  relative path: another tool call may start elsewhere.
- Before writing a new file, confirm the resolved absolute path starts with
  `$PARA_ROOT/`. A path that lands in `REPO_ROOT` means a prefix was dropped.
