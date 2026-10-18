# Adapter: Todoist

How each operation in `tasks.md` is carried out with the Todoist MCP tools (the
`mcp__claude_ai_Todoist__*` tools). Used when `TASKS = todoist`. This is the only base-layer file
that names Todoist's tools.

pairing: separate

If the Todoist tools are not available in the session, `tasks.md` «Backend missing»
applies.

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
  user sees the `inbox.name` string). Tools address it as `projectId: "inbox"`.
- Task fields map: `text` = `content`, `due` = the task's due date, `created` = `addedAt`.
- `area` names are resolved to a project id with `find-projects` and `searchText`; no
  match, or more than one, is reported, never guessed.
- Lists are paged: follow `cursor` until it is exhausted.

## Operations

### `inbox.add`

`add-tasks` with `projectId: "inbox"`, `content` = `title`, `description` when given.
Nothing else is set. Returns the new task's id.

### `inbox.list`

`find-tasks` with `projectId: "inbox"`, paged. Sort by `addedAt`, oldest first.

### `inbox.close`

`complete-tasks` with the id. Never `delete-object` on a capture (`tasks.md`, `inbox.close`).

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

### `project.list`

`find-projects` with `archivedStatus: "all"`, paged. `ref` = `id`, `name` = `name`,
`is_inbox` = `inboxProject`, `is_archived` = `isArchived`.

### `task.add`

`add-tasks` with `projectId` (the `project_ref`, or the id resolved from `area`),
`content` = `text`, and `description`, `duration`, `labels` when given. `dueString` only
when `due` was given — the user's own words for the day, passed through. Supported
`labels` mean `task.label` is not needed. Returns the new task's id.

### `task.list`

`state: open` — `find-tasks` with `projectId`, paged; `due` is the task's due date.
`state: completed` — `find-completed-tasks` with `projectId`, `since` and `until`.

### `task.move`

`update-tasks` with the task `id` and the destination `projectId`, plus `content` = `title` when a new title is given — and nothing else.
Todoist keeps the date and recurrence on a project move. Never send the task's current
`projectId`.

### `task.complete`

`complete-tasks` with the task `id`. Confirm by re-reading: `find-tasks` with the task's
`projectId` (paged) must no longer return the id; the tool's echo is not evidence.
Never `delete-object`.

### `project.activity`

`state`, always: `find-projects` with `archivedStatus: "all"` and look for the id —
absent is `missing`, `isArchived` is `archived`, else `active`. (Reuse a `project.list`
result already in hand.)

`last_event`, when it can be found: `find-activity` with `objectType: "task"`,
`projectId: ref`, `limit: 1`; events come newest first and `eventDate` is the result.
Todoist may return empty pages with a `cursor` while it scans: follow the cursor, at
most 3 more pages. Never filter by `objectId` — it was observed to return events of
unrelated objects. Nothing found → `last_event` is absent; `state` is still returned.

### `task.label`

`update-tasks` with the task `id` and `labels` — which **replaces** all labels, so first
read the task's current labels and send them plus the new one. Rarely needed:
`add-tasks` takes `labels`.
