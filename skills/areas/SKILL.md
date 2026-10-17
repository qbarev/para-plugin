---
name: areas
description: Work with Areas in the Obsidian PARA vault — create an area of ongoing responsibility, or review which areas have gone quiet and what has drifted in them. Use when the user says "заведи область", "новая сфера", "добавь область", "обзор областей", "что по областям", "какие сферы провисают", "ревью сфер".
argument-hint: create <название> | review
---

# Areas

Areas are ongoing responsibilities with **no end date** — health, finances, the career.
They are not projects and never get "finished". An area that has gone quiet is the thing
this skill exists to surface: unlike a project, nothing about an area announces that it
has been neglected.

**How Areas are organised is not decided here.** `areas.md` owns the model: whether
there is a grouping layer at all, what the groups are called, which frontmatter field
records the group, and where a new note goes. This skill holds the algorithm and reads
the model — it never hardcodes a group name or assumes how many there are.

## Base layer

Read before acting, each as `../../para/<file>.md` relative to this skill's base directory — these hold the shared rules, do not restate them from memory:

- `../../para/paths.md` — always
- `.claude/para/areas.md` (vault config, under `REPO_ROOT`) — always; this skill is meaningless without the model
- `../../para/note-format.md` — for `create`
- `../../para/find-target.md` — when `review` needs to resolve a named area
- `../../para/confirm.md` — `create` writes; `review` writes nothing
- `../../para/thresholds.md` — for `review`

## Subcommands

The first word of `$ARGUMENTS` picks the subcommand: `create` or `review`. Empty → show
both and ask.

---

### `create <название>` — start an area

1. **Read `Templates/Area.md`** from disk, verbatim.
2. **Decide the group.** One of the values `GROUPS` lists in `areas.md`, from the
   description. If it is genuinely unclear, ask — the grouping field is the one that
   determines where the file goes, so it cannot be left blank.
   With `GROUPING = none` this step does not apply.
3. **Fill the frontmatter** per the Area row of the schema in `note-format.md`: `title`,
   `tags: [area/<slug>]` with the slug filled in per `note-format.md`, and the grouping
   field if the model has one.
4. **Fill the body:**
   - `# Ссылки` — wikilinks to related notes, otherwise the template's empty `-`.
   - `# Текущее состояние` — where this responsibility stands right now, in the user's
     own words from the description. Blank if they did not say.
   - `# Заметки` — leave empty; it fills up over time.
5. **Write** to the path `PLACEMENT` gives in `areas.md`, going deeper if the
   description implies a subfolder. Check the basename for a vault-wide collision first.
6. **Report** the path and the group.

If the description has an end state and a goal, it is a project, not an area — say so
and offer `/projects create`.

---

### `review` — what has gone quiet

Read-only. Answers "which of my responsibilities am I not looking at". With an argument,
review only that area; with none, every group `GROUPS` lists — however many that is.

1. **Walk `Areas/`** recursively. For every note: path, the grouping field, and mtime
   (`stat -f '%m %N'`).

2. **Read the frontmatter** of each, and `# Текущее состояние` where present. Do not
   read the full bodies — this is a sweep, not a summary of each note.

3. **Compute per group**: how many notes, when the group was last touched, and which
   individual notes have gone past the area staleness threshold in `thresholds.md`,
   which is deliberately far looser than a project's.

4. **Flag only what actually fires:**
   - a group with no notes at all;
   - a note past that threshold — say how long, not that it is bad;
   - a note that violates `PLACEMENT_CHECK` — its grouping field disagreeing with the
     folder it sits in. Skip when the model sets `PLACEMENT_CHECK = none`;
   - an area note with an unfilled `area/` tag slug;
   - a note with no frontmatter at all (predates the convention — state it, do not
     migrate it);
   - dangling wikilinks in `# Ссылки`;
   - an area holding what reads like project work — a goal with an end state. Name it
     and offer to split it out.

5. **Render in Russian** per `REVIEW_GROUPING`, dropping any group that has nothing to
   report. The exact shape of the output lives in `areas.md` — it depends on the
   model, so it is written where the model is.

6. **Write nothing.** If the review surfaces something worth doing, say it and let the
   user decide.

## Notes

- Silence in an area is information, not a verdict. Report it factually — "не менялась
  74 дня", never "ты забросил".
- An area is rarely archived; ongoing responsibilities do not end. If asked to archive
  one, that usually means the note is stale, not the responsibility — see `/archive`.
- Everything in Russian.
