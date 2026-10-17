# Writing a note

Everything shared between the skills that create notes. Read `paths.md` first.

## Start from the template on disk

Every new note starts from the template matching its destination folder — see the table
in `paths.md`. **Always read it from disk; never work from a copy pasted into a skill.**
Copy the contents verbatim as the starting point.

- Replace `{{title}}` everywhere: in `title:` and in the `# {{title}}` heading.
- Keep every section heading the template has, even when the body stays empty.
- Do not add a heading the template lacks, and do not drop one. The templates already
  carry the `common.links` section where it belongs.
- The headings a template carries are the `lang/<LANG>.md` strings for the section keys
  (`project.goal`, `common.links`, …; `paths.md` «Language»). Whenever this base layer or
  a skill names a section by its key, it means the heading of that text in the vault's
  language, and the vault's own `Templates/` decides how it is spelled on disk.

## Frontmatter schema

All types carry `title`, matching the H1. For every type except Project, the filename
matches it too.

**Note** is the working note inside a project — `<project>/Notes/` and `<project>/Results/`.
It carries no `status`, `due` or `estimate` in its frontmatter: it is thinking, not
work to be tracked — the work is in the task backend (`tasks.md`). Notes written
before this type existed have only `title` and `created`; leave them alone, as with any pre-convention note.

| Type | Fields |
|---|---|
| Project | `title`, `short`, `id`, `tags: [project/<slug>]`, `area`, `deadline`, `tasks_ref` (only under `pairing: separate`), `created` |
| Area | `title`, `tags: [area/<slug>]`, plus the grouping field `GROUPING` names in `areas.md` |
| Resource | `title`, `tags: [resource/<slug>, topic/<slug>]`, `source`, `type` |
| Note | `title`, `tags: [note]`, `project`, `created` |
| Task (only when `TASKS = files`) | `title`, `tags: [task]`, `status: open \| done`, `due`, `duration`, `created` |

Allowed values:

- `area` on a Project and the Area grouping field — both take their values from
  `GROUPS` in `areas.md`. One vocabulary, two fields: a project belongs to the
  same responsibility an area tracks. With `GROUPING = none` the Area field is absent
  entirely and `area` on a Project is dropped with it.
- `type` — one of the `resource.type.*` strings (`article`, `book`, `video`,
  `own_thought`), Resource only. The value is vocabulary, so it is written in the vault's
  language, as `lang/<LANG>.md` spells it. The key `type` itself stays Latin.
- `tasks_ref` — the backend project id, quoted, Project only (`tasks.md`, «Pairing»).
  Blank until the pair exists; absent when `TASKS = files`. Notes written before this
  field was renamed carry `todoist` with the same meaning: read it as `tasks_ref`, and
  `/vault-lint` reports it.

## Filling fields

- **Fill the tag slug.** `project/<slug>`, `area/<slug>`, `resource/<slug>`,
  `topic/<slug>` — a bare trailing slash left in a real note is a bug. `topic/` belongs
  to Resource only.
- **Tags are a block list.** The `tags: [a, b]` notation in the schema table above is
  shorthand; a note carries the template's form, one `  - item` per line — never a
  flow list.
- **Dates** (`deadline`, `created`) are `YYYY-MM-DD` so Obsidian reads them as
  Date properties. Convert relative dates ("in a month") to absolute ones.
- **`short`** is the project's name as it is said in conversation — one or two words in
  `LANG`: «Vacation», «Renovation». Project only. It is a label, never a filename or a
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
| the `project.goal` section | what the world looks like when the project is done |
| the `project.value` section | **what the user gains from that** — measurable where possible (hours, money, a date, a count), and unambiguous where not: «−5 hours of review a week», «the warranty lasts 2 years» |
| the `project.expected_result` section | which artifacts appear and where they live (`dod.md`) |
| the `project.scope` section | which work items lead there — written by the research task (`tasks.md`), each item becoming tasks; empty until then |
| the `project.what_changed` section | written at archiving: what was actually gained — the answer to the `project.value` section |

The `project.value` section sits between `project.problem` and `project.expected_result`
in `Templates/Project.md`. It is required like `project.goal`: if the description does not say
what the user gets, ask (`confirm.md`, Tier 1.5) — in the same question as the goal,
never a second one. Never write the artifact here, and never write the benefit under
the `project.expected_result` section.

## Legacy fields

Projects created before tasks moved to a task app carry fields and a folder the schema no
longer has: `status`, `priority`, `value`, `estimate` in the overview, and a `Tasks/`
folder of task notes (`tags: [task]`, some also `research`). They are **legacy**: read
them when reporting, never write or update them, never create them. `/vault-lint`
lists them as the migration agenda; they are removed only when the project is migrated
with the user. Archived projects keep theirs for good.

**`Tasks/` is legacy unless `TASKS = files`.** Under `files` it is the backend's own
folder (`adapters/files.md`): never legacy, never reported. This is the one statement
of it; skills and base files point here.

## Title and filename

- Short — 6 words or fewer — in `LANG`, naming the thing rather than describing it.
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

Write in `LANG` (`paths.md` «Language») — the note body, the frontmatter values that are
vocabulary, and everything you print to chat. Every fixed string — section headings, the
`resource.type.*` values, the research-task name, report headings — is the one in
`lang/<LANG>.md`; the content (titles, the user's words, a summary) is written fresh in
`LANG`, whatever language the source or the prompt is in. Property keys stay Latin and
are identical in every language. Switch language only if the user explicitly asks the
vault to change `LANG`; the language they happened to type in is not such a request.
