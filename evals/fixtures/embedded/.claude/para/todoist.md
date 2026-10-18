# Todoist

Tasks live in Todoist, and only there. Read `paths.md` first.

The user-facing description of this system is the note `Распорядок` (under `Areas/`).
It owns the schedule — section `## Ёмкость`. This file owns how Claude applies it.

## Pairing

Every project in `Projects/` has exactly one Todoist project. Vault side — the
overview's frontmatter field `todoist`, holding the Todoist project id.

A project in `Projects/` without `todoist` is **unpaired**. Report it as «нет пары в
Todoist».

A project **waiting on someone else** stays in the sprint by a short check task on the
day it makes sense: «Проверить, ответил ли мастер», 5 min.

## Area projects

Tasks that belong to no project go to one Todoist project per area group
(`TODOIST_AREA_PROJECTS`), and their tasks spend the same sprint hours as any other.

## What a task is

A task is a **concrete physical action**: verb and object, the first ten minutes are
obvious, one sitting.

| Field | Meaning | Set when |
|---|---|---|
| duration | the estimate | at planning, at the latest when the task gets a date |
| date | the day it is planned for; dated = in the sprint | at sprint or week planning, never on creation |
| time | when in the day | in the morning of that day |

**Type.** A task is *tactical* (заполнить, отправить, позвонить) or *strategic*
(решить, сформулировать, выбрать). The type is judged from the wording when choosing a
day and is not stored.

## Sprint

The sprint is two weeks. Its anchor and length are in `thresholds.md`; the current
sprint is the one whose span contains today. A task is in the sprint when its date
falls inside the sprint's span.

## Plan vs fact

| What | Where it comes from |
|---|---|
| Completed | `find-completed-tasks` for the period: count, and sum of durations |
| Postponed | `find-activity` on each task: how many times its date changed |
| Time | ask the user once which tasks took noticeably more or less than estimated |

## Writing to Todoist

- Giving a date to an undated task → `update-tasks`.
- Moving a task that already has a date → `reschedule-tasks`, always.
- Moving a task to another project → `update-tasks` with `projectId`; never send back a
  task's existing `projectId`.
- New tasks → `add-tasks`, Tier 1 (`confirm.md`). Everything in Russian.

## Rhythms

There is no planning skill. Each rhythm **proposes, waits for «да», then writes** — the
planning exception in `confirm.md`.

### Capacity

Take the blocks of the target week from `Распорядок` → `## Ёмкость`. Multiply by the
planned share in `thresholds.md`:

```
Ёмкость недели: 5 ч × 80 % = 4 ч
```

### Sprint — «спланируй спринт»

1. Results of the sprint that ends — per «Plan vs fact».
2. Capacity of week 1.
3. On «да», write the dates.

### Day — «распланируй день»

Today's tasks with overdue ones. On «да», write the times.
