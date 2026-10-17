# Writing a note

Everything shared between the skills that create notes. Read `paths.md` first.

## Start from the template on disk

Every new note starts from the template matching its destination folder — see the table
in `paths.md`. **Always read it from disk; never work from a copy pasted into a skill.**
Copy the contents verbatim as the starting point.

- Replace `{{title}}` everywhere: in `title:` and in the `# {{title}}` heading.
- Keep every section heading the template has, even when the body stays empty.
- Do not add a heading the template lacks, and do not drop one. The templates already
  carry `# Ссылки` where it belongs.

## Frontmatter schema

All types carry `title`, matching the H1. For every type except Project, the filename
matches it too.

**Note** is the working note inside a project — `<Проект>/Notes/` and `<Проект>/Results/`.
It carries no `status`, `due` or `estimate` in its frontmatter: it is thinking, not
work to be tracked — the work is in Todoist (`todoist.md`). Notes written before this type existed have only `title` and
`created`; leave them alone, as with any pre-convention note.

| Type | Fields |
|---|---|
| Project | `title`, `short`, `id`, `tags: [project/<slug>]`, `area`, `deadline`, `todoist`, `created` |
| Area | `title`, `tags: [area/<slug>]`, plus the grouping field `GROUPING` names in `areas.md` |
| Resource | `title`, `tags: [resource/<slug>, topic/<slug>]`, `source`, `type` |
| Note | `title`, `tags: [note]`, `project`, `created` |

Allowed values:

- `area` on a Project and the Area grouping field — both take their values from
  `GROUPS` in `areas.md`. One vocabulary, two fields: a project belongs to the
  same responsibility an area tracks. With `GROUPING = none` the Area field is absent
  entirely and `area` on a Project is dropped with it.
- `type` — `статья` / `книга` / `видео` / `своя мысль`, Resource only.
- `todoist` — the Todoist project id, quoted, Project only (`todoist.md`, «Pairing»).
  Blank until the pair exists.

## Filling fields

- **Fill the tag slug.** `project/<slug>`, `area/<slug>`, `resource/<slug>`,
  `topic/<slug>` — a bare trailing slash left in a real note is a bug. `topic/` belongs
  to Resource only.
- **Tags are a block list.** The `tags: [a, b]` notation in the schema table above is
  shorthand; a note carries the template's form, one `  - item` per line — never a
  flow list.
- **Dates** (`deadline`, `created`) are `YYYY-MM-DD` so Obsidian reads them as
  Date properties. Convert relative dates ("через месяц") to absolute ones.
- **`short`** is the project's name as it is said in conversation — one or two Russian
  words: «Отпуск», «Ремонт». Project only. It is a label, never a filename or a
  link target. Unlike the other fields, `/projects create` **proposes** it from the
  title — a label is not a fact that could be invented — and shows it so the user can
  change it.

An empty field is honest information: it says the thing has not been decided
yet. **Leave a field blank rather than inventing a value**, and never infer
one from tone or from a neighbouring field. If it matters, ask.

## Three sections about the outcome

A project's overview carries three neighbouring sections that are easy to write as one.
They answer different questions, and the archive adds a fourth that answers back:

| Section | Question |
|---|---|
| `# Цель` | what the world looks like when the project is done |
| `# Ценность` | **what the user gains from that** — measurable where possible (hours, money, a date, a count), and unambiguous where not: «−5 часов ревью в неделю», «гарантия действует 2 года» |
| `# Ожидаемый результат` | which artifacts appear and where they live (`dod.md`) |
| `# Скоуп работ` | which work items lead there — written by the research task (`todoist.md`), each item becoming Todoist tasks; empty until then |
| `# Что изменилось` | written at archiving: what was actually gained — the answer to `# Ценность` |

`# Ценность` sits between `# Проблема` and `# Ожидаемый результат` in
`Templates/Project.md`. It is required like `# Цель`: if the description does not say
what the user gets, ask (`confirm.md`, Tier 1.5) — in the same question as the goal,
never a second one. Never write the artifact here, and never write the benefit under
`# Ожидаемый результат`.

## Legacy fields

Projects created before tasks moved to Todoist carry fields and a folder the schema no
longer has: `status`, `priority`, `value`, `estimate` in the overview, and a `Tasks/`
folder of task notes (`tags: [task]`, some also `research`). They are **legacy**: read
them when reporting, never write or update them, never create them. `/vault-lint`
lists them as the migration agenda; they are removed only when the project is migrated
with the user. Archived projects keep theirs for good.

## Title and filename

- Short — 6 words or fewer — in **Russian**, naming the thing rather than describing it.
- The title comes from what the user said — for a capture routed by `/inbox process`,
  from the capture itself.
- Strip characters illegal in filenames: `/ \ : * ? " < > |`.
- The filename is the title plus `.md`. The exception is a project: the folder and the
  overview file carry the `PROJ-xxxx ` prefix, while `title` and the H1 stay clean.

## Name collisions

Basenames must stay unique across **`REPO_ROOT`**, not merely `PARA_ROOT` — Obsidian's
own vault root is `REPO_ROOT` (see `paths.md`), and links resolve by filename, so a
duplicate makes every link to that name ambiguous (see `move.md`). Search the wider
root, or `/vault-lint` will keep reporting collisions this check was unable to prevent:

```bash
find "$REPO_ROOT" -name "<filename>.md" -not -path "*/.*"
```

If something already exists, **say so and ask** whether to add to the existing note,
pick another title, or write alongside it with a qualifier. Do not silently append a
date or a number — a second note the user cannot tell apart from the first is worse
than a question.

## Notes predating the convention

Older notes have no frontmatter at all. Read them as-is, leave them as they are, and do
not migrate one as a side effect of another task. When a skill reports on such a note,
say the metadata is absent rather than filling it in from inference.

## Language

Russian throughout — the note body, the frontmatter values, and everything you print to
chat. Property keys stay Latin. Switch only if the user explicitly asks for another
language; the language they happened to type in is not such a request.
