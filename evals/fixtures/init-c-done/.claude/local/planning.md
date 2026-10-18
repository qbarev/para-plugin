# Planning

This file belongs to the vault, not to the `para` plugin: no skill reads it, and the
local part of `CLAUDE.md` points at it. It holds how Claude plans this vault's tasks —
the schedule, the numbers, the sprint and the rhythms. It builds on the plugin's
`para/tasks.md` (the operations, what a task is, the fields and the date rule, the
research task) and `para/adapters/todoist.md`, and restates neither.

## Schedule

The user-facing description of this system is the note `Распорядок` (under `Areas/`).
It owns the schedule — section `## Ёмкость`. This file owns how Claude applies it.

The hours are in the note `Распорядок` under `Areas/`, section `## Ёмкость`. If the
note or the section is missing, say so and stop.

## Numbers

| What | Value | Used by |
|---|---|---|
| Anchor — first day of sprint 1 | **2026-09-07** (a Monday) | «Sprint» |
| Sprint length | **14 days** | same |
| Planned share of capacity | **80 %** | «Capacity» |

## Sprint

The sprint is two weeks. Its anchor and length are in «Numbers»; the current
sprint is the one whose span contains today. A task is in the sprint when its date
falls inside the sprint's span.

A project **waiting on someone else** stays in the sprint by a short check task on the
day it makes sense: «Проверить, ответил ли мастер», 5 min.

Tasks that belong to no project go to one Todoist project per area group
(`AREA_TASK_PROJECTS`, `.claude/para/areas.md`), and their tasks spend the same sprint
hours as any other.

| Field | Meaning | Set when |
|---|---|---|
| duration | the estimate | at planning, at the latest when the task gets a date |
| date | the day it is planned for; dated = in the sprint | at sprint or week planning, never on creation |

**Type.** A task is *tactical* (заполнить, отправить, позвонить) or *strategic*
(решить, сформулировать, выбрать). The type is judged from the wording when choosing a
day and is not stored.

## Counts

- **в спринте** — open tasks dated inside the current sprint.

The plugin reports the scheduled count instead; planning computes this one itself.

## Plan vs fact

| What | Where it comes from |
|---|---|
| Completed | `find-completed-tasks` for the period: count, and sum of durations |
| Postponed | `find-activity` on each task: how many times its date changed |
| Time | ask the user once which tasks took noticeably more or less than estimated |

## Writing dates

- Giving a date to an undated task → `update-tasks`.
- Moving a task that already has a date → `reschedule-tasks`, always.
- Moving a task to another project → per the adapter's `task.move`.
- New tasks → `task.add`, `tasks.md`.

## The planning exception

**One named exception — planning.** The rhythms in this file («Rhythms») set and
move dates and durations in Todoist. Show the whole proposal, wait for «да», then
write. A correction («СБ не надо, перенеси на ВТ») is a new proposal, not a yes.

## Rhythms

There is no planning skill. Each rhythm **proposes, waits for «да», then writes** — the
planning exception in this file.

### Capacity

Take the blocks of the target week from `Распорядок` → `## Ёмкость`. Multiply by the
planned share in «Numbers»:

```
Ёмкость недели: 5 ч × 80 % = 4 ч
```

### Sprint — «спланируй спринт»

1. Results of the sprint that ends — per «Plan vs fact».
2. Capacity of week 1.
3. On «да», write the dates.

### Day — «распланируй день»

Today's tasks with overdue ones. On «да», write the times.
