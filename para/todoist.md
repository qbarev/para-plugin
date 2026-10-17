# Todoist

Tasks live in Todoist, and only there. The vault keeps what a project *means* — goal,
criteria, notes, results; Todoist keeps what is to be *done* — tasks, their durations
and dates. A task is never written to disk, and no skill keeps a list of tasks in a
note: two copies of one task are what this arrangement exists to avoid. Read
`paths.md` first.

The user-facing description of this system is the note `Как я работаю` (under
`Areas/`). It owns the schedule — block times and hours, section `## Ёмкость`. This
file owns how Claude applies it. Neither restates the other.

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

A project **waiting on someone else** (a consultant, a reply) stays in the sprint by a
short check task on the day it makes sense: «Проверить, ответил ли консультант», 5 min.

Lifecycle, both sides together: a project exists while the user means to finish it;
finished or abandoned, the folder goes to `Archive/` and the Todoist project is
archived (`/archive`). Whether a project is *being worked on* is not stored anywhere —
it is visible as dated tasks in the current sprint.

## Area projects

Tasks that belong to no project — chores, one-off errands, anything an area produces —
go to one Todoist project per area group. Their names are the `AREA_TASK_PROJECTS`
key in `areas.md`. They have no folder in `Projects/`, are never reported as
unpaired, and their tasks spend the same sprint hours as any other.

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
| duration | the estimate | at planning, at the latest when the task gets a date |
| date | the day it is planned for; dated = in the sprint | at sprint or week planning, never on creation |
| time | when in the day | in the morning of that day |

### The research task

A project whose work is not yet clear — every new project, and any project where
the user cannot name the next steps — gets **one** task first, and no others:

- name: `Ресерч «<short>»: определить скоуп работ`;
- label `research` — the only label in use; it makes every open research a filter away
  (`@research`);
- description: what has to be found out, taken from the project's goal and problem,
  and the done condition — «в заметке проекта заполнен „Скоуп работ“, по его пунктам
  заведены задачи в Todoist»;
- no duration until planning, like any task.

Its result lives in the vault: the overview's `# Скоуп работ` section lists the work
items in plain words. Each item then becomes one or more Todoist tasks, worded as
below. Never invent the scope for the user to skip this step — a list Claude made up
is exactly the unclear task this rule exists to prevent. When the scope changes later,
update the section and the tasks together.

No date means **backlog**: the task waits in its project. Priorities and sections are
not used; the one label is `research` (above).

**Type.** A task is *tactical* (a step known in advance, doable tired: заполнить,
отправить, записаться, позвонить) or *strategic* (thinking and writing, needs a fresh
head: решить, сформулировать, спроектировать, выбрать). The type is judged from the
wording when choosing a day and is not stored.

## Sprint

The sprint is two weeks, Monday to Sunday twice. Its anchor and length are in
`thresholds.md`; the current sprint is the one whose span contains today, counted from
the anchor in whole sprint lengths. Week 1 and week 2 are its halves.

A task is in the sprint when its date falls inside the sprint's span. There is no
label, board, section or note for a sprint, and no written sprint goals — the dated
tasks are the goals.

## Plan vs fact

Todoist knows the plan (duration, date) and what was completed; it does not know the
time actually spent. So:

| What | Where it comes from |
|---|---|
| Completed | `find-completed-tasks` / `find-activity` for the period: count, and sum of durations |
| Postponed | `find-activity` on each task: how many times its date changed; a task moved twice or more is named |
| Time | nothing automatic — ask the user once which tasks took noticeably more or less than estimated |

Never ask the user to log time per task, and never treat a missing duration as zero.

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

## Rhythms

There is no planning skill. When the user asks for one of these in conversation, follow
it. Each one **proposes, waits for «да», then writes** — the planning exception in
`confirm.md` — and reports what changed. None writes to the vault. Today and the time
come from the system; the timezone from `user-info`.

### Capacity

Used by Sprint and Week. Take the blocks of the target week from `Как я работаю` →
`## Ёмкость`. Subtract the overlap of each block with events in the user's primary
Google calendar (`list_events`). Multiply by the planned share in `thresholds.md`. Show
the arithmetic in one line:

```
Ёмкость недели: 7,5 ч − 1,0 ч (встреча ЧТ) = 6,5 ч × 80 % = 5,2 ч
```

**From the second sprint on**, the cap is the smaller of that number and what was
actually closed in the previous sprint, per week: the sum of durations of tasks
completed in it, corrected by the misses the user names at the results step. Show both
numbers and which one was taken.

Dated tasks of the week already count against it, whatever day they are on. A dated
task without a duration is listed as «без оценки» and asked about; it is never counted
as zero.

### Sprint — «спланируй спринт»

Also when «спланируй неделю» is asked on a Sunday whose next day starts a sprint.

1. **Results of the sprint that ends**: completed (count, hours), postponed twice or
   more, still open and overdue — per «Plan vs fact».
2. **One question**: «какие задачи заметно разошлись с оценкой?» — the answer is
   context for the next step, not a record.
3. **Capacity** of week 1.
4. **Backlog**: for each project with undated tasks, list them; the user picks.
5. **Propose days**: tactical tasks to the tactical blocks, strategic to the strategic,
   until capacity is reached; ask for a duration where one is missing.
6. **Show the proposal** as a table — `День | Задача | Проект | Оценка` — with the total
   against capacity.
7. **On «да»**, write the dates (and durations given in step 5).

### Week — «спланируй неделю»

The same steps for the week that just ended and the one ahead. The week ahead is the
next Monday–Sunday when asked on Saturday or Sunday, otherwise the current week's
remaining days. Asked on the Sunday before a sprint starts — that is Sprint.

### Day — «распланируй день», «что сегодня»

Today's tasks with overdue ones. Propose start times inside today's block, one after
another by duration, starting no earlier than now. A task without a duration is asked
about first — never given a zero-length or guessed slot. On a day without a block, or once
today's block is over, list the tasks, say so, and propose times only if asked — late
in the day, offer Evening instead. On «да», write the times.

### Evening — «закрой день», «итоги дня»

Today's and overdue tasks not completed. For each, propose the next block day in the
sprint with capacity left (block hours minus durations already dated that day), or
removing the date when the sprint has no room. A recurring task is not moved — its
next occurrence comes by itself; name it and move on. A task without a duration is
asked about before it is placed. On «да», write.
