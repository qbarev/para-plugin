# Adapter: files

How each operation in `tasks.md` is carried out with plain files in the vault. Used when
`TASKS = files`. No app and no connector are involved, so «Backend missing» cannot
happen here. Read `paths.md` first; every path below is under `PARA_ROOT`, and every
shell path is quoted and built from the expanded `PARA_ROOT`.

pairing: none

The folder is the list. A project's task list is its own folder; there is no second
project to pair with. Consequences, stated once in `tasks.md` «Pairing»: `tasks_ref` is
absent, `ref` is the project folder (a path under `PARA_ROOT`, such as
`Projects/PROJ-xxxx <title>`, derived and never stored), and nothing is ever «unpaired».

## Where things live

| What | Where |
|---|---|
| A capture | `Inbox/<title>.md` |
| A project task | `Projects/PROJ-xxxx <title>/Tasks/<title>.md` |
| A task outside any project | `Areas/<group>/Tasks/<title>.md`; `Areas/Tasks/<title>.md` when `GROUPING = none` |

`Tasks/` is created by the first task written into it. A task is one note, built from
the vault's `Templates/Task.md` (read it from disk, verbatim; `note-format.md` says how
templates are applied). The plugin's `templates/<LANG>/Task.md` is only the seed
`init` copies there.

Specifics that hold for every operation:

- **Task fields map.** `text` = `title` (frontmatter) and the filename; `description` =
  the note body below the H1; `due` = `due`; `created` = `created`; `labels` = `tags`
  without `task`; open/completed = `status: open` / `status: done`. `duration` =
  `duration` (`30m`, `2h`; blank when not given).
- **`id`** = the filename without `.md`. Basenames are unique across `REPO_ROOT`
  (`note-format.md` «Name collisions»), so the `id` finds the file with
  `find "$REPO_ROOT" -name "<id>.md" -not -path "*/.*"` and **survives a move**. A name
  that is already taken is not resolved by the adapter (no silent suffix): it reports the
  collision and the skill resolves it per `note-format.md` «Name collisions» (add to the
  existing note, another title, or a qualifier), in `task.add` and in `task.move` with
  a `title` alike.
- **Writing a task.** Template verbatim; `title` and the H1 = `text`; `created` = today;
  `status: open`; `due` and `duration` blank unless given; `tags` is a block list, `task` first, then
  `labels`. The date rule is `tasks.md` «Fields»: `due` is written only when the caller
  passes it, as `YYYY-MM-DD`. A recurring date is not supported: say so and write the
  task undated.
- **`area`** is a group name from `GROUPS` in `areas.md`. No match is reported, never
  guessed. With `GROUPING = none` there are no groups: `area` (whatever name the skill
  passes) selects the single folder `Areas/Tasks/`.
- **`project_ref`** is a folder under `Projects/` (or `Archive/`). A `ref` that does not
  resolve to a folder is reported.
- Exactly one of `project_ref` or `area` is given; neither or both is an error, never
  a guess.

## Operations

### `inbox.add`

Write the task note to `Inbox/` as above: `text` = `title`; `description` goes under the
H1 when given. Nothing else is set. Returns the `id`.

### `inbox.list`

Every `*.md` directly in `Inbox/` (`paths.md`: all are captures) whose `status` is not `done`. A note without
frontmatter (created by hand in Obsidian, `paths.md`) is an open capture: its `text` is
the filename, its `created` the file's birth date (`stat -f %SB -t %Y-%m-%d`). Oldest
first by `created`, ties by filename.

### `inbox.close`

Set `status: done` in the capture; the file stays where it is. Reversible, as
`tasks.md` requires. On a note without frontmatter, add a minimal frontmatter with
`status: done` and leave the body alone. Never delete the file.

### `project.create`

No-op. The skill has made the folder; `Tasks/` appears with the first task. Returns
`ref` = `Projects/PROJ-xxxx <title>`.

### `project.archive`, `project.restore`

No-op. The skill moves the folder and the tasks go with it.

### `project.delete`

No-op. The skill removes the folder (`/remove`, Tier 2) and the tasks go with it.

### `project.list`

Not supported. The folders under `Projects/` are the projects, so there is no
«backend project without an overview» to find.

### `task.add`

Write the task note into `Tasks/` of the project folder (`project_ref`) or of the area
(`area`), as above. `labels` are written as tags, so `task.label` is rarely needed.
Returns the `id`.

### `task.list`

`state: open` — the `*.md` in the `Tasks/` folder with `status: open`; the folder is
the project's (`project_ref`) or the area's (`area`). A note without `status` counts as
open. Each result carries its `due`. «Overdue» is decided by the caller
(`thresholds.md`).

`state: completed` — the same with `status: done`, filtered by file modification date
(`stat -f %Sm -t %Y-%m-%d`) between `since` and `until`. The completion date is not
stored; the modification date is its proxy.

### `task.move`

Move the file to the `Tasks/` folder of the destination (`project_ref` or `area`),
creating it if needed, per `move.md`. When `title` is given, rename the file to it and set
`title` and the H1 to it (the `id` is then the new name). `created`, the body and every
other field are kept. The task stays open; a capture moved out of `Inbox/` becomes a
task of its destination. A basename already taken is a collision (see «Where things
live»).

### `project.activity`

`state`, always: `active` when the `ref` folder exists, `missing` when it does not.
There is no second side that could be `archived`.

`last_event`: the newest modification time of any file under the folder, dotfiles
(`.gitkeep`, `.DS_Store`) left out:

```bash
find "$PARA_ROOT/<ref>" -type f -not -name '.*' -exec stat -f %m {} + | sort -n | tail -1
```

An empty result leaves `last_event` absent.

### `task.label`

Add the label to `tags` in the note, keeping every tag already there. Rarely needed:
`task.add` takes `labels`. It rewrites the file, so it bumps the modification date that
`task.list` with `state: completed` filters on.
