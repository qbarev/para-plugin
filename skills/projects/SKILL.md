---
name: projects
description: Work with Projects in the Obsidian PARA vault and their Todoist pairs — list the active projects, create a project (folder plus Todoist project), summarize where a project stands, or add a task to a project in Todoist. Use when the user says "list projects", "show projects", "what am I working on", "create a project", "new project", "project overview", "project status", "add a task", "какие проекты", "список проектов", "покажи проекты", "что у меня в работе", "заведи проект", "новый проект", "саммари по проекту", "обзор проекта", "что по проекту", "статус проекта", "где я по проекту", "добавь задачу", "заведи задачу".
argument-hint: list | create <description> | overview <project> | task <project> <task>
---

# Projects

Projects are efforts with a **defined goal and an end state** — unlike Areas, which are
ongoing. A project is a **folder** in the vault paired with a **project in the task backend**:
the folder holds what the project means, the backend holds its tasks (`tasks.md`).
Every task call is an operation from `tasks.md`, run per the adapter for `TASKS`.

## Base layer

Read before acting, each as `../../para/<file>.md` relative to this skill's base directory — these hold the shared rules, do not restate them from memory:

- `../../para/paths.md` — always, including «Language»: the strings below come from `lang/<LANG>.md`
- `../../para/tasks.md` — always: the operations, pairing, what a task is
- `../../para/find-target.md` — for `overview` and `task`
- `../../para/note-format.md` — for `create`; for every subcommand, «Legacy fields»
- `../../para/project-id.md` — for `create`
- `../../para/dod.md` — for `create` (writing the `project.dod` section) and `overview`
- `../../para/thresholds.md` — for `list` and `overview`: project order, staleness,
  horizons, task counts, output size
- `../../para/confirm.md` — `create` and `task` write (Tier 1); `list` and `overview`
  write nothing
- `../../para/move.md` — for `create`, before writing a folder that may collide

## Subcommands

The first word of `$ARGUMENTS` picks the subcommand: `list`, `create`, `overview`,
`task`. If it is none of those, work out which is meant from the phrasing and say which
you picked. Empty `$ARGUMENTS` → run `list`, then ask what to do.

Every subcommand meets projects that predate the task backend: `status`, `Tasks/` (`note-format.md` says when that is legacy), no `tasks_ref` field. Read them as `note-format.md` «Legacy fields» says — report, never
rewrite.

---

### `create <description>` — start a project

Input: what the project is, its goal, deadline, first steps. Empty → ask what the
project is and its goal.

1. **Read `Templates/Project.md`** from disk, verbatim.

2. **Derive a title** per `note-format.md`. It is used three ways: as `title` and the H1
   **without** the id prefix, and — **with** the prefix — as the folder name and the
   overview filename. **Propose `short`** per `note-format.md`.

3. **Issue the id** per `project-id.md`.

4. **Create the folder structure** under `Projects/`:

   ```
   PROJ-xxxx <title>/
   ├── PROJ-xxxx <title>.md      ← overview, from Templates/Project.md
   ├── Notes/
   ├── Resources/
   └── Results/
   ```

   All three subfolders, even empty. No `Tasks/` (under `TASKS = files` the adapter
   creates it with the first task).

5. **Fill the frontmatter** per the Project row in `note-format.md`. `created` is today.
   `deadline` only if the description gives one. `tasks_ref` stays blank until step 7
   (under `pairing: none` the field is left out).

6. **Fill the body:**
   - the `project.goal` section — the goal / desired end state. **Required.**
   - the `project.value` section — what the user gains, measurable or unambiguous
     (`note-format.md`, "Three sections about the outcome"). **Required.** If either
     this or `project.goal` is not clear from the input, ask for both in one question
     (`confirm.md`, Tier 1.5) before writing.
   - the `project.problem` section — what prompted the project.
   - the `project.expected_result` section — the concrete artifacts and where they live.
   - the `project.scope` section — only the items the user named. Usually empty: the
     research task fills it (`tasks.md` «The research task»).
   - the `project.dod` section — checkboxes per `dod.md`. If the description does not let
     you derive real checks, ask — as for a missing `project.goal`.
   - the `common.links` section — wikilinks to clearly related notes, otherwise the
     template's `-`.

7. **Create the pair** per `tasks.md` «Pairing»: `project.create` with the title and
   the id. Under `pairing: separate`, write the returned `ref` into `tasks_ref:`; if the call fails, say so: the folder stays, unpaired, and
   `/projects task` will offer to pair it later. Under `pairing: none` there is no pair
   and no `tasks_ref`: skip the write.

8. **First tasks** in the new project, **without dates**:
   - the research task per `tasks.md` «The research task», **always**, unless the
     user already named the full scope — then write it into the `project.scope` section instead;
   - steps the user named explicitly, added with `task.add` and worded per «What a task is». A step that cannot
     be worded as an action is a question for the research, not a task.

   Never invent steps the user did not name.

9. **Report** the folder path, id, title, `short` (offering to change it), deadline,
   goal, the value line, the backend project name, and the tasks created.

If the input describes an ongoing responsibility with no end, this is not a project —
say so and offer `/areas create` instead. If it is an idea the user has not decided to
take on, say that it is not a project yet (`tasks.md` «Pairing») and offer to leave
it in the inbox (`inbox.name`).

---

### `task <project> <task>` — add a task

1. **Find the project** per `find-target.md`, operation «Add a task to a project».
   The target may also be an area project from `AREA_TASK_PROJECTS` in
   `areas.md` — match it by name.
2. **Resolve where it goes**: an area project → `area`; otherwise the overview's
   `tasks_ref` → `project_ref` (under `pairing: none` the project folder is the `ref`
   and this step is just the project).
   - `pairing: separate` and no `tasks_ref` on the overview → say the `task.unpaired` string and offer to create it
     (step 7 of `create`). On yes, create the pair, then continue. Never write the task
     into the vault instead.
3. **Word the task** per `tasks.md` «What a task is». If the user's wording already
   fits, keep it; otherwise propose the reworded version in the announcement. If it
   cannot be an action, ask for the next step (Tier 1.5).
4. **`task.add`** with `project_ref` or `area` (under `TASKS = files` a taken basename is
   a collision: `note-format.md` «Name collisions», ask, no silent suffix): the text, a description for anything longer,
   `duration` only if given. The date rule is `tasks.md` «Fields».
5. **Report** the task and the project.

---

### `overview <project>` — where the project stands

**Read-only.** Writes nothing — not to the vault, not to the backend. If the summary
surfaces something worth fixing, say so and let the user decide.

1. **Find the project** per `find-target.md`, operation "Report on". With no argument,
   list the projects and ask.

2. **Read the overview note**: frontmatter and the sections `project.goal`,
   `project.value`, `project.expected_result`, `project.dod`, `common.links`. A blank field is
   reported as blank, never filled in from inference.

3. **Read the tasks** (`task.list`, open): their dates and durations. Compute the counts
   per `thresholds.md` «Task counts». Under `pairing: separate`, no pair → skip, and
   say the `task.unpaired` string.

4. **Read `Notes/`** (and `Results/`, if it has anything) in full, up to the cap in
   `thresholds.md` — this is where decisions and risks actually live.

5. **Legacy.** If the overview carries `status` / `priority` / `value` / `estimate`, or
   the folder has a legacy `Tasks/` (`note-format.md`), add one line, the `overview.legacy` string with `{fields}` such as
   `status, Tasks/ (3 files)` (the folder count is the `overview.legacy_tasks`
   string), naming only what is present. Do not read task notes for
   progress; the migration decides what survives.

6. **Signals** — report only those that fire:
   - the project's `deadline` past, or inside the horizon in `thresholds.md`;
   - overdue tasks — say by how many days;
   - nothing scheduled while the deadline is inside the horizon;
   - dated tasks without a duration;
   - quiet longer than the project threshold in `thresholds.md`, measured as it says
     (`project.activity` when paired, mtime otherwise, per `thresholds.md`);
   - dangling wikilinks in the `common.links` section;
   - every acceptance criterion ticked while the project is still in `Projects/` —
     finished and not closed.

7. **Render to chat, in `LANG`.** The labels are `lang/<LANG>.md` strings, named in the
   template below by key in braces; shown here with the English strings:

   ```
   ## PROJ-0001 · Project A

   **{overview.area}** Area A · **{overview.deadline}** 2026-10-31 — 14 days
   **{overview.tasks}** {count.scheduled} 3 · {count.overdue} 1 · {count.backlog} 6
   **{overview.acceptance}** ☑☐☐ 1/3

   ### {overview.essence}
   <The goal, 1–2 sentences.>
   <The expected result — one line.>
   <The value — one line.>

   ### {overview.scheduled}
   - **Write the supplier an email** — Tue 10-21, 30 min
   - **Fill in the form** — overdue by 2 days, 1 h

   ### {overview.backlog}
   - Book an appointment
   - …and 3 more

   ### {overview.digest}
   - <A key decision or conclusion from Notes/ — in your own words.>

   ### {overview.signals}
   - Deadline in 14 days, nothing scheduled
   ```

   The braces are keys, not literal text: print the string each key stands for.
   Dates are the `common.date` format (`2026-10-31`; `10-31` in the short form
   `common.date_short`, used with a weekday from `common.weekdays` on a task line); the
   days to the deadline are `common.days`; unit abbreviations are `common.unit.*`; an
   overdue task carries the `task.overdue_by` string; the backlog tail is the
   `overview.backlog_more` string (`{n}` = tasks not shown). The
   `overview.backlog` section shows the oldest undated tasks up to the cap in
   `thresholds.md`. Drop any section or field that would be empty. An empty `Results/`
   is a normal state.

---

### `list` — the projects

**Read-only.** One line per project — the index, not a summary: never opens `Notes/`.

1. **Enumerate** the folders directly under `Projects/`. Archived projects are not
   listed — that is `/archive list`.

2. **Read the overview frontmatter**: `id`, `title`, `area`, `deadline`, and under `pairing: separate` `tasks_ref`.
   A folder with no frontmatter is pre-convention — print it by folder name with
   the `common.no_metadata` string.

3. **Read the tasks** of each project that has a `ref` (`task.list` with `project_ref`, open), counted per `thresholds.md` «Task counts».

4. **Order** per `thresholds.md` «Project order».

5. **Render, in `LANG`**, with the `list.*`, `count.*` and `task.unpaired` strings
   (header `list.header`, deadline `list.until` with the date in `common.date_short` and,
   inside the horizon of `thresholds.md`, ` (14 d)` after it: the days to go and
   `common.unit.day`); shown here with the English strings:

   ```
   **Projects (4)**
   1. PROJ-0008 Project A — Area A · until 10-31 (14 d) · scheduled 2 · backlog 3
   2. PROJ-0020 Project B — until 10-31 (14 d) · scheduled 0 · backlog 3
   3. PROJ-0009 Project C — Area B · until 02-28 · no pair in the task manager · old format
   4. PROJ-0027 Project D — backlog empty
   No pair in the vault: «Project E»
   ```

   - A past deadline: the `list.deadline_passed` string.
   - The `list.legacy` string when legacy fields are present, or a legacy `Tasks/` is.
   - A project whose backlog is empty: the `list.backlog_empty` string.
   - The last line (`list.orphans`) names backend projects that no overview points at (`project.list` once,
     matched by `ref`; not the inbox, not `AREA_TASK_PROJECTS`). Drop it when empty or
     when the adapter does not support `project.list`.
   - Drop any blank field rather than printing a placeholder. An empty `Projects/` is a
     valid answer: say it plainly.

## Archived and pre-convention projects

Projects in `Archive/` may predate the conventions: no frontmatter, no `PROJ-xxxx`
prefix, no subfolders. Read the `project.goal` section from the note, skip the tasks
section and `overview.acceptance`, and state plainly that it is archived and in the old format.

## Notes

- Compute, don't estimate: day counts, task counts and overdue spans come from the backend,
  the files and today's system date. If something cannot be computed because a field
  is blank, say it is blank rather than guessing.
- A summary reports on state; it does not judge the user. "overdue by 5 days", not
  "you abandoned the project".
- Everything in `LANG`, tasks included.
