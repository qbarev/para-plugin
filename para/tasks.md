# Tasks

Tasks live in the vault's task backend, and only there. The vault keeps what a project
*means* — goal, criteria, notes, results; the backend keeps what is to be *done* —
tasks, their durations and dates. No skill keeps a list of tasks in a note: two copies
of one task are what this arrangement exists to avoid. (With `TASKS = files` the tasks
are notes of their own, owned by that adapter — a task there is one note, never a list
inside another.) Read `paths.md` first.

## Backend and adapter

`TASKS` in `vault.md` names the backend: `todoist`, `files` or `mcp`. Skills never call
a task app's tools themselves. They name an **operation** from the table below and run
it **per the adapter for `TASKS`** (`paths.md` says where the adapter file is).

- The adapter is the only place that knows how an operation is carried out, and the
  only place that names the app.
- **Backend missing.** If the adapter's tools are not available in this session, say so
  in one line and stop. Never fall back to another backend, and never write a task to
  disk to make up for it (the `files` adapter is the one backend that is disk, and has
  nothing to be missing). A skill that only reads tasks and can finish without them
  (a project overview, a lint check) skips that part, says so, and goes on; it never
  reports a project as broken because the backend is unreachable.
- **Unsupported.** An operation an adapter marks «not supported» is skipped at that
  point; the skill says so and carries on with the rest.
- A failed call is reported as it is. The vault side is never rolled back to match.

## Operations

Inputs and results are the contract; the adapter decides how they are met. A *task* in a
result carries: `id`, `text`, `description` (may be empty), `duration` (may be empty),
`due` (a date, may be empty), `labels`, `created`. Whether a task is *overdue* is
decided in one place, `thresholds.md` «Task counts».

Two ways to name where a task lives, **exactly one given, never guessed**:
`project_ref` — the project's `ref` (under `pairing: separate` its `tasks_ref`, see
«Pairing»); `area` — a name from `AREA_TASK_PROJECTS` in `areas.md` (an adapter that
keeps area tasks in folders reads it as a group name from `GROUPS`, and says so).

| Operation | Input | Result |
|---|---|---|
| `inbox.add` | `title`; `description` (optional) | the new capture's `id` |
| `inbox.list` | — | every open capture as a task, oldest first |
| `inbox.close` | capture `id` | nothing. Closing is reversible and never destroys the capture — the one statement of that; callers point here |
| `project.create` | `title` (without the `PROJ-xxxx` prefix); `description` (the `PROJ-xxxx` id) | the new project's `ref` |
| `project.archive` | `ref` | nothing |
| `project.restore` | `ref` | nothing |
| `project.delete` | `ref` | nothing; Tier 2, the skill has asked (`confirm.md`) |
| `project.list` | — | the backend's projects as (`ref`, `name`, `is_inbox`, `is_archived`); **optional** — a ledgered addition to the original twelve operations; «not supported» is a normal answer |
| `task.add` | `project_ref` or `area`; `text`; `description`, `duration`, `due`, `labels` (all optional) | the new task's `id` |
| `task.list` | `project_ref` or `area`; `state`: `open` (default) or `completed`; for `completed`, `since` and `until` as `YYYY-MM-DD` | the tasks, each with its `due` date |
| `task.move` | task `id`; destination `project_ref` or `area`; `title` (optional — the task's new text, a rename on move) | nothing; the task keeps its date, recurrence and `id`, and stays open |
| `task.complete` | task `id` | nothing; the task is completed, never deleted. **Optional** — a ledgered addition like `project.list`; «not supported» is a normal answer |
| `project.activity` | `ref` | `state`: `active`, `archived` or `missing` — **always returned**; `last_event`: the time of the latest event (a task added, completed, changed) — **may be absent** («no events found», or not supported) |
| `task.label` | task `id`; `label` | nothing; **optional**. Used only when the adapter marks `labels` on `task.add` unsupported; otherwise pass `labels` to `task.add` |

Notes on the table:

- **`inbox.*`** work on the backend's inbox, whatever the backend calls it. In the
  `files` backend that is a folder (`paths.md`).
- **`inbox.add`**: the skill owns how a long capture becomes a short `title` plus the
  full text as `description`; the adapter passes both through.
- **`project.activity`**: `state` is what lets `/vault-lint` tell «pair lost»
  (`missing`) from «closed on one side only» (`archived`). A pair check depends on
  `state` only and is never skipped because `last_event` is absent. Staleness
  (`thresholds.md`) falls back to mtime only when `last_event` is absent.
- **`project.list`** is one call: a reader that needs «backend projects no overview
  points at» calls it once and matches by `ref`. The inbox (`is_inbox`) and the
  `AREA_TASK_PROJECTS` projects are not findings.
- **Dates** are never inferred. See «Fields».

## Pairing

Each adapter declares `pairing:` once, at its top.

- **`pairing: separate`** (a backend with projects of its own): every project in `Projects/` has exactly
  one project in the backend, and the reverse.
  - **Name** — the project's `title`, without the `PROJ-xxxx` prefix.
  - **Description** — the project's `PROJ-xxxx`.
  - **Vault side** — the overview's frontmatter field `tasks_ref`, holding the backend's
    project id as a quoted string: `tasks_ref: "6Xexample0000000"`. This is `ref`.
  - **The key is the id, never the name.** A project renamed on either side stays
    paired. Two overviews carrying the same id is a lint finding.
  - A project in `Projects/` without `tasks_ref` is **unpaired** — every project created
    before this file existed, until it is migrated. Report it with the `task.unpaired` string and carry on; never create the pair as a side effect of reading. Steps that
    resolve `tasks_ref` or offer a pair apply only under this value.
- **`pairing: none`** (the `files` backend): the project is its own task list. `tasks_ref` is absent
  and not required; `ref` is the project folder itself, derived from its path and never
  stored. «Unpaired» does not exist: no `task.unpaired`, no offer to create a pair.
  `project.create`, `project.archive`, `project.restore` and `project.delete` are no-ops
  (the folder moves are the skills' own). `project.activity` returns `state: active`
  while the folder exists and `missing` when it does not; `last_event` is the adapter's.

Lifecycle, both sides together: a project exists while the user means to finish it;
finished or abandoned, the folder goes to `Archive/` and the backend project is
archived (`/archive`). Whether a project is *being worked on* is not stored anywhere —
it is visible as recent activity (`project.activity`) and dated tasks in it.

A project **waiting on someone else** (a consultant, a reply) carries a
short check task, dated for the day it makes sense, named per the `task.waiting.name`
string (`{who}` = who is awaited, e.g. the consultant), 5 min.

## Area projects

Tasks that belong to no project — chores, one-off errands, anything an area produces —
go to one backend project per area group. Their names are the `AREA_TASK_PROJECTS`
key in `areas.md`. They have no folder in `Projects/`, are never reported as unpaired,
and operations take them as `area`.

## What a task is

A task is a **concrete physical action**, readable without context:

- **verb and object** — «Write the supplier an email asking about delivery times», not
  «Research "Rights"»;
- **the first ten minutes are obvious** — if they are not, it is a question, not a
  task: ask for the next step instead of writing it;
- **one sitting** — larger work is split before it gets a date.

When wording a task for the user (`/projects create`, `/projects task`,
`/inbox process`), propose this form and show it; if the user's words cannot become an
action, say so and ask for the next step rather than writing a vague task.

### Fields

| Field | Meaning | Set when |
|---|---|---|
| duration | the estimate | when given, at the latest when the task gets a date |
| date | the day it is planned for | only when the user names a day — never chosen by a skill, never inferred, so a new task is undated |
| time | when in the day | only when the user gives one |

This is the only statement of the date rule. A skill that adds a task passes `due` only
when the user supplied it.

New tasks are Tier 1 (`confirm.md`). Everything in `LANG` (`paths.md` «Language»).

### The research task

A project whose work is not yet clear — every new project, and any project where
the user cannot name the next steps — gets **one** task first, and no others:

- name: the `task.research.name` string, with the project's `short` for `{short}`;
- label `research` (passed as `labels` to `task.add`) — the only
  label in use; it makes every open research a filter away. Where `task.add` cannot take labels, `task.label`; where
  that is unsupported too, the name alone marks it;
- description: what has to be found out, taken from the project's goal and problem,
  and the done condition — the `task.research.done` string, with the `project.scope`
  heading for `{scope}`;
- no duration, like any task at creation.

Its result lives in the vault: the overview's `project.scope` section lists the work
items in plain words. Each item then becomes one or more tasks, worded as above. Never
invent the scope for the user to skip this step — a list Claude made up is exactly the
unclear task this rule exists to prevent. When the scope changes later, update the
section and the tasks together.

No date means **backlog**: the task waits in its project. Priorities and sections are
not used; the one label is `research`.
