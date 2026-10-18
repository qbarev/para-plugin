# Finding a target

How to turn a user's loose description ("project c", "PROJ-0003", "note a")
into exactly one file or folder. Read `paths.md` first — every path here is relative
to `PARA_ROOT`.

## Search scope

Which folders to search depends on what the caller is doing, not on which skill is
running. Pick the row, search every folder in it.

| Caller's operation | Search in |
|---|---|
| Archive something | `Projects/`, `Areas/`, `Resources/`, and `Inbox/` for a stray (`paths.md`) |
| Remove something | the same, **plus** `Notes/` `Resources/` `Results/` inside every project, **plus `Archive/`** |
| Report on / open something | the same as Remove — but when the description resolves to a project folder (by id, `short` or title), take the folder and do not also offer notes inside it; fall back to notes only when no project matched |
| Add a task to a project (`task`) | `Projects/` **project folders only** — match on id, `short` or title of the folder; never on notes inside a project, never `Archive/` |
| Restore from archive | `Archive/` only |
| Create something | nothing — you are checking for a **collision**, not a target; see `note-format.md` |

Deleting an archived project is the ordinary case, not the exotic one, which is why
`Archive/` is in the Remove row: an id is retired only by deletion, and by then the
project has usually been archived already.

Search recursively: Areas and Resources are nested (`Areas/<Group 1>/<Topic>/…`, the
depth depending on the model in `areas.md`).

## Matching a project

A project folder is named `PROJ-xxxx <title>`, so its name never equals the title.

- If the description contains `PROJ-` followed by digits, match on the id — that is
  exact, take it.
- Otherwise match the overview's `short` field (read from the frontmatter of each
  folder in scope) — exact, case-insensitive. A `short` match wins over any substring
  match.
- Otherwise match against the **title part only**, after the `PROJ-xxxx ` prefix.
- Match on substring, case-insensitively. "project c" must find `PROJ-0003 Project C`.
- The `id` field inside the overview note's frontmatter is the source of truth, not the
  folder name. If they disagree, say so instead of picking one.
- Archived projects predating the convention have no prefix and no frontmatter
  (`Old project`). Match those on the folder name as-is.

## Matching a note

Match on filename without `.md`, substring, case-insensitively. A note's `title`
frontmatter matches its filename for every type except a project overview, so the
filename is enough.

## Resolving the result

Count the candidates, then:

- **0 candidates** — say nothing matched, and show what you searched. Never guess at
  the closest thing, never create a placeholder, never fall back to creating something
  new unless the caller's operation is itself a create.
- **1 candidate** — proceed with it, naming it in full so the user can catch a wrong match.
- **N candidates** — list them with their locations and ask which one. Never pick
  silently, not even when one looks obviously better.

A project folder and a note inside it can both match the same words. When the matches
span both kinds, treat them as separate candidates and let the user choose — "delete
project c" may mean the project folder or one note inside it. The "Report on" row is the
exception: there a matched project folder wins, as the table says.
