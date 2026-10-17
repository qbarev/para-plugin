# Todoist

Tasks live in Todoist, and only there. The vault keeps what a project *means* — goal,
criteria, notes, results; Todoist keeps what is to be *done* — tasks, their durations
and dates. A task is never written to disk, and no skill keeps a list of tasks in a
note: two copies of one task are what this arrangement exists to avoid. Read
`paths.md` first.

All calls go through the Todoist MCP tools.

## Pairing

Every project in `Projects/` has exactly one Todoist project, and the reverse.

- **Todoist name** — the project's `title`, without the `PROJ-xxxx` prefix.
- **Todoist description** — the project's `PROJ-xxxx`.
- **Vault side** — the overview's frontmatter field `todoist`, holding the Todoist
  project id as a quoted string: `todoist: "6Xexample0000000"`.
- **The key is the id, never the name.** A project renamed on either side stays
  paired. Two overviews carrying the same id is a lint finding.

A project in `Projects/` without `todoist` is **unpaired** — every project created
before this file existed, until it is migrated. Report it as «нет пары в Todoist» and
carry on; never create the pair as a side effect of reading.

A Todoist project with no overview pointing at it is **unpaired on the Todoist side**,
unless it is the inbox («Входящие», `inboxProject: true` — its API name is `Inbox`) or
an area project. Report it; never create a folder for it
unasked.

A project **waiting on someone else** (a consultant, a reply) carries a
short check task, dated for the day it makes sense: «Проверить, ответил ли консультант», 5 min.

Lifecycle, both sides together: a project exists while the user means to finish it;
finished or abandoned, the folder goes to `Archive/` and the Todoist project is
archived (`/archive`). Whether a project is *being worked on* is not stored anywhere —
it is visible as recent activity and dated tasks in its Todoist project.

## Area projects

Tasks that belong to no project — chores, one-off errands, anything an area produces —
go to one Todoist project per area group. Their names are the `AREA_TASK_PROJECTS`
key in `areas.md`. They have no folder in `Projects/`, are never reported as
unpaired.

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

Fields:

| Field | Meaning | Set when |
|---|---|---|
| duration | the estimate | when given, at the latest when the task gets a date |
| date | the day it is planned for | only when the user gives one, never on creation |
| time | when in the day | only when the user gives one |

### The research task

A project whose work is not yet clear — every new project, and any project where
the user cannot name the next steps — gets **one** task first, and no others:

- name: `Ресерч «<short>»: определить скоуп работ`;
- label `research` — the only label in use; it makes every open research a filter away
  (`@research`);
- description: what has to be found out, taken from the project's goal and problem,
  and the done condition — «в заметке проекта заполнен „Скоуп работ“, по его пунктам
  заведены задачи в Todoist»;
- no duration, like any task at creation.

Its result lives in the vault: the overview's `# Скоуп работ` section lists the work
items in plain words. Each item then becomes one or more Todoist tasks, worded as
below. Never invent the scope for the user to skip this step — a list Claude made up
is exactly the unclear task this rule exists to prevent. When the scope changes later,
update the section and the tasks together.

No date means **backlog**: the task waits in its project. Priorities and sections are
not used; the one label is `research` (above).

## Writing to Todoist

- Giving a date to an undated task → `update-tasks`.
- Moving a task that already has a date → `reschedule-tasks`, always: `update-tasks`
  replaces the whole due and destroys recurrence.
- Setting or changing the **time of day** on a dated task → `reschedule-tasks` too —
  it is a change of due, and the same recurrence rule applies.
- Removing a date → `update-tasks` clearing the due. Never on a recurring task: name it
  and leave it.
- Moving a task to another project → `update-tasks` with `projectId`, only when the
  move is intended; never send back a task's existing `projectId`.
- New tasks → `add-tasks`, Tier 1 (`confirm.md`). Everything in Russian.
