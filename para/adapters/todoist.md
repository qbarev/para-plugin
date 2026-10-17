# Adapter: Todoist

How each operation in `tasks.md` is carried out with the Todoist MCP tools (the
`mcp__claude_ai_Todoist__*` tools). Used when `TASKS = todoist`. This is the only base-layer file
that names Todoist's tools.

If the Todoist tools are not available in the session, `tasks.md` «Backend missing»
applies: say so and stop.

Todoist specifics that hold for every operation:

- A project's `ref` is its Todoist project id, a string.
- `add-projects` and `update-projects` require a `color`; send `charcoal` (the default),
  never choose one.
- Never send a task's existing `projectId`, `sectionId` or `parentId` back to
  `update-tasks`: those fields are treated as a move. Send only what changes.
- `project-management` echoes the project with its old `isArchived`; confirm a change by
  reading `find-projects` with `archivedStatus: "all"`.
- Todoist apps show durations under 24 hours only; the adapter sends `duration` as given
  (`30m`, `2h`).
- The inbox is the project with `inboxProject: true` (its API name is `Inbox`; the
  user sees «Входящие»). Tools address it as `projectId: "inbox"`.
- Task fields map: `text` = `content`, `due` = the task's due date, `created` = `addedAt`.
- Lists are paged: follow `cursor` until it is exhausted.

## Operations

### `inbox.add`

`add-tasks` with `projectId: "inbox"`. A short text goes into `content` as given. A long
one gets a short `content` derived from it (6 words or fewer) and the full text verbatim
in `description`. Nothing else is set. Returns the new task's id.

### `inbox.list`

`find-tasks` with `projectId: "inbox"`, paged. Sort by `addedAt`, oldest first.

### `inbox.close`

`complete-tasks` with the id. Completing is reversible; never `delete-object` on a
capture.

### `project.create`

`add-projects` with `name` = the title, `description` = the `PROJ-xxxx` id, `color:
"charcoal"`, flat (no `parentId`), personal (no `workspace`). Returns the new project's
id as `ref`.

### `project.archive`

`project-management` with `action: "archive"`, `projectId: ref`.

### `project.restore`

`project-management` with `action: "unarchive"`, `projectId: ref`.

### `project.delete`

`delete-object` with `type: "project"`, `id: ref`. Works on active and archived
personal projects. The skill has already obtained the Tier 2 yes.

### `task.add`

`add-tasks` with `projectId` (the `ref`, or the area project's id found by name with
`find-projects` and `searchText`), `content` = `text`, and `description`, `duration`,
`labels` when given. `dueString` only when `due` was given — it is the user's own words
for the day, passed through. Returns the new task's id.

### `task.list`

`state: open` — `find-tasks` with `projectId`, paged; a task is overdue when its due
date is before today. `state: completed` — `find-completed-tasks` with `projectId` and
`since`/`until` for the period.

### `task.move`

`update-tasks` with the task `id` and the destination `projectId` — and nothing else.
Todoist keeps the date and recurrence on a project move. Never send the task's current
`projectId`.

### Changing a task's date (not an operation, but the rule behind a dated task)

No skill in the plugin changes a task's date. Should one need to: a date given to an
undated task is `update-tasks` with `dueString`; moving an existing date, or setting a
time of day on a dated task, is `reschedule-tasks`, always — `update-tasks` replaces the
whole due and destroys recurrence. Removing a date is `update-tasks` with `dueString:
"remove"`, never on a recurring task: name it and leave it.

### `project.activity`

Time: `find-activity` with `objectType: "task"`, `projectId: ref`, `limit: 1`; events come
newest first and `eventDate` is the result. Todoist may return empty pages with a
`cursor` while it scans: follow the cursor, at most 3 more pages. Never filter by
`objectId` — it was observed to return events of unrelated objects. No event found →
report «not supported» for the time, so the caller falls back to mtime (`thresholds.md`).
State: `find-projects` with `archivedStatus: "all"` and look for the id —
absent is `missing`, `isArchived` is `archived`, else `active`. (If the project is
archived or missing, say so rather than reporting a time.)

### `task.label`

`update-tasks` with the task `id` and `labels` — which **replaces** all labels, so first
read the task's current labels and send them plus the new one. Supported.
