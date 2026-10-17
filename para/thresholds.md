# Thresholds

Every number the skills compute with. A threshold written in a
skill is a bug — the skill reads it from here, so that two places reporting on the same
thing cannot quietly disagree. Read `paths.md` first.

All of these are judgement calls, not measurements. Change one here and every reader
changes with it.

## Staleness

| What | Untouched for | Used by |
|---|---|---|
| A project has gone quiet | **14 days** | `/projects overview`, `/projects list` |
| An area has gone quiet | **60 days** | `/areas review` |

A **paired** project is measured from `project.activity` (`tasks.md`) — the latest event
in its backend project. When the adapter marks `project.activity` «not supported», or
the project is unpaired, it is measured like an area: from the mtime of the newest file in the folder or of
the note (`stat -f '%m %N'`).

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
| A deadline worth naming | **14 days** | `/projects list`, `/projects overview` |

## Project order

Wherever several projects are listed: nearest `deadline` first, blank last; then
`title`, alphabetically. There is no priority (`note-format.md`).

## Output size

| What | Limit | Used by |
|---|---|---|
| Open tasks listed in an overview | the dated ones from today on, plus the **5** oldest undated | `/projects overview` |
| `Notes/` files read in full | all, unless **more than ~10** — then the most recently modified | `/projects overview` |

The reading caps exist because bodies run long, not because reading is expensive. When
a folder is small, read all of it.

## Task counts

Computed one way wherever they appear, from the paired backend project (`task.list`):

- **запланировано** — open tasks dated today or later;
- **просрочено** — open tasks dated before today;
- **в бэклоге** — open tasks with no date;
- **закрыто** — completed tasks, over the period the caller names.

No pair → no counts: say «нет пары в менеджере задач», never `0`.

## Acceptance

`# Критерий готовности` holds **2–5** checkboxes (`dod.md` owns why). Acceptance is
ticked over total, `☑`/`☐`. Section missing or still a placeholder → drop the line.
