# Tasks

Tasks live in the vault's task backend, and only there. The vault keeps what a project
*means* — goal, criteria, notes, results; the backend keeps what is to be *done* —
tasks, their durations and dates. A task is never written into a note, and no skill
keeps a list of tasks in a note: two copies of one task are what this arrangement
exists to avoid. Read `paths.md` first.

## Backend and adapter

`TASKS` in `vault.md` names the backend: `todoist`, `files` or `mcp`. Skills never call
a task app's tools themselves. They name an **operation** from the table below and run
it **per the adapter for `TASKS`** (`paths.md` says where the adapter file is).

- The adapter is the only place that knows how an operation is carried out, and the
  only place that names the app.
- **Backend missing.** If the adapter's tools are not available in this session, say so
  in one line and stop. Never fall back to another backend, and never write a task to
  disk to make up for it. A skill that only reads tasks and can finish without them
  (a project overview, a lint check) skips that part, says so, and goes on; it never
  reports a project as broken because the backend is unreachable.
- **Unsupported.** An operation an adapter marks «not supported» is skipped at that
  point; the skill says so and carries on with the rest.
- A failed call is reported as it is. The vault side is never rolled back to match.

## Operations

Inputs and results are the contract; the adapter decides how they are met. `ref` is the
project's `tasks_ref` (below). A *task* in a result carries: `id`, `text`, `description`
(may be empty), `duration` (may be empty), `due` (date, may be empty), `labels`,
`created`.

| Operation | Input | Result |
|---|---|---|
| `inbox.add` | `text`; `description` (optional, for a long capture) | the new capture's `id` |
| `inbox.list` | — | every open capture as a task, oldest first |
| `inbox.close` | capture `id` | nothing; the capture is closed, reversibly, never destroyed |
| `project.create` | `title` (without the `PROJ-xxxx` prefix); `description` (the `PROJ-xxxx` id) | the new project's `ref` |
| `project.archive` | `ref` | nothing |
| `project.restore` | `ref` | nothing |
| `project.delete` | `ref` | nothing; Tier 2, the skill has asked (`confirm.md`) |
| `task.add` | `ref` or an area project's name; `text`; `description`, `duration`, `due`, `labels` (all optional) | the new task's `id` |
| `task.list` | `ref` or an area project's name; `state`: `open` (default) or `completed` with a period | tasks of that project; for `open`, each with `due` and an overdue flag |
| `task.move` | task `id`; destination `ref` or area project's name | nothing; the task keeps its date, recurrence and `id` |
| `project.activity` | `ref` | the time of the latest event (a task added, completed, changed), plus the project's `state`: `active`, `archived` or `missing`; or «not supported» (also when no event can be found) |
| `task.label` | task `id`; `label` | nothing; **optional** — «not supported» is a normal answer |

Notes on the table:

- **`inbox.*`** work on the backend's inbox, whatever the backend calls it. In the
  `files` backend that is a folder (`paths.md`).
- **Pairing operations** (`project.*`) have no meaning where the backend has no
  separate project; such an adapter says what it does instead.
- **`project.activity` `state`** is what lets `/vault-lint` tell «pair lost» (`missing`)
  from «closed on one side only» (`archived`) without a call of its own.
- **Dates** are never inferred. See «Fields».

## Pairing

Every project in `Projects/` has exactly one project in the backend, and the reverse.

- **Name** — the project's `title`, without the `PROJ-xxxx` prefix.
- **Description** — the project's `PROJ-xxxx`.
- **Vault side** — the overview's frontmatter field `tasks_ref`, holding the backend's
  project id as a quoted string: `tasks_ref: "6Xexample0000000"`.
- **The key is the id, never the name.** A project renamed on either side stays
  paired. Two overviews carrying the same id is a lint finding.

A project in `Projects/` without `tasks_ref` is **unpaired** — every project created
before this file existed, until it is migrated. Report it as «нет пары в менеджере
задач» and carry on; never create the pair as a side effect of reading.

Lifecycle, both sides together: a project exists while the user means to finish it;
finished or abandoned, the folder goes to `Archive/` and the backend project is
archived (`/archive`). Whether a project is *being worked on* is not stored anywhere —
it is visible as recent activity (`project.activity`) and dated tasks in it.

A project **waiting on someone else** (a consultant, a reply) carries a
short check task, dated for the day it makes sense: «Проверить, ответил ли консультант», 5 min.

## Area projects

Tasks that belong to no project — chores, one-off errands, anything an area produces —
go to one backend project per area group. Their names are the `AREA_TASK_PROJECTS`
key in `areas.md`. They have no folder in `Projects/`, are never reported as unpaired,
and operations accept them by name where the table says «area project's name».

## What a task is

A task is a **concrete physical action**, readable without context:

- **verb and object** — «Написать поставщику письмо с вопросом о сроках поставки», not
  «Ресерч „Права“»;
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

New tasks are Tier 1 (`confirm.md`). Everything in Russian.

### The research task

A project whose work is not yet clear — every new project, and any project where
the user cannot name the next steps — gets **one** task first, and no others:

- name: `Ресерч «<short>»: определить скоуп работ`;
- label `research` (via `task.label` if `task.add` was not given `labels`) — the only
  label in use; it makes every open research a filter away. Where labels are not
  supported the name alone marks it;
- description: what has to be found out, taken from the project's goal and problem,
  and the done condition — «в заметке проекта заполнен „Скоуп работ“, по его пунктам
  заведены задачи»;
- no duration, like any task at creation.

Its result lives in the vault: the overview's `# Скоуп работ` section lists the work
items in plain words. Each item then becomes one or more tasks, worded as above. Never
invent the scope for the user to skip this step — a list Claude made up is exactly the
unclear task this rule exists to prevent. When the scope changes later, update the
section and the tasks together.

No date means **backlog**: the task waits in its project. Priorities and sections are
not used; the one label is `research`.
