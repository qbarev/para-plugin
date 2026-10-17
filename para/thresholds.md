# Thresholds

Every number the skills and the planning rhythms compute with. A threshold written in a
skill is a bug — the skill reads it from here, so that two places reporting on the same
thing cannot quietly disagree. Read `paths.md` first.

All of these are judgement calls, not measurements. Change one here and every reader
changes with it.

## Sprint

| What | Value | Used by |
|---|---|---|
| Anchor — first day of sprint 1 | **2026-10-12** (a Monday) | `todoist.md` «Sprint», «Rhythms» |
| Sprint length | **14 days** — week 1 and week 2 | same |
| Planned share of capacity | **80 %** — the rest is buffer | `todoist.md` «Capacity» |

The buffer exists because the first slip otherwise breaks the whole plan.

## Capacity

The hours themselves are **not here.** They are the user's schedule and live in the
note `Рабочий график` under `Areas/`, section `## Ёмкость`: a table with columns
`День | Время | Часы | Тема`, one row per block, `Тема` either `тактика` or
`стратегия`. The user edits it in Obsidian; read it at run time, every time.

If the note or the section is missing, say so and stop — never fall back to a guessed
schedule.

## Staleness

| What | Untouched for | Used by |
|---|---|---|
| A project has gone quiet | **14 days** | `/projects overview`, `/projects list` |
| An area has gone quiet | **60 days** | `/areas review` |

A **paired** project is measured from the latest event in its Todoist project
(`find-activity` — a task added, completed, rescheduled or edited). An **unpaired**
project, and an area, are measured from the mtime of the newest file in the folder or
of the note (`stat -f '%m %N'`).

The two numbers differ by design: areas move slowly by nature, and an area silent for a
fortnight is normal where a project silent for a fortnight is a signal.

**Report the span, do not characterise it.** "не менялся 23 дня" is a fact; "заброшен"
is a verdict, and belongs to the user.

### The limit of mtime

mtime records that a *file* changed, not that *work* happened. Never state staleness as
though it measured effort — and if every project's newest file falls inside the same
hour, the spread is degenerate (a bulk edit or a sync touched everything) and the
signal is worthless for that run; say so instead of reporting it.

## Horizons

| What | Window | Used by |
|---|---|---|
| A deadline worth naming | **14 days** | `/projects list`, `/projects overview`, `todoist.md` «Sprint» and «Week» |

## Project order

Wherever several projects are listed: nearest `deadline` first, blank last; then
`title`, alphabetically. There is no priority (`note-format.md`): what matters this
sprint is decided at planning, not stored.

## Output size

| What | Limit | Used by |
|---|---|---|
| Open tasks listed in an overview | the dated ones in the sprint, plus the **5** oldest undated | `/projects overview` |
| `Notes/` files read in full | all, unless **more than ~10** — then the most recently modified | `/projects overview` |

The reading caps exist because bodies run long, not because reading is expensive. When
a folder is small, read all of it.

## Task counts

Computed one way wherever they appear, from the paired Todoist project:

- **в спринте** — open tasks dated inside the current sprint (`todoist.md` «Sprint»);
- **просрочено** — open tasks dated before today;
- **в бэклоге** — open tasks with no date;
- **закрыто** — completed tasks, over the period the caller names.

No pair → no counts: say «нет пары в Todoist», never `0`.

## Acceptance

`# Критерий готовности` holds **2–5** checkboxes (`dod.md` owns why). Acceptance is
ticked over total, `☑`/`☐`. Section missing or still a placeholder → drop the line.
