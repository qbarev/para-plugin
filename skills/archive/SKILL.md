---
name: archive
description: Work with Archive in the Obsidian PARA vault — put a finished or abandoned project (folder and its Todoist project) or a note into the archive, list what is already there, or restore something back into an active folder. Use when the user says "заархивируй", "перенеси в архив", "закрой проект", "что в архиве", "покажи архив", "верни из архива", "восстанови проект".
argument-hint: <что> | list | restore <что>
---

# Archive

The `Archive/` area of the vault: everything finished or shelved goes here, and
archiving is always a move — never a deletion. Permanent deletion is `/remove`. A
project's backend pair is archived and restored together with its folder.

## Base layer

Read before acting, each as `../../para/<file>.md` relative to this skill's base directory — these hold the shared rules, do not restate them from memory:

- `../../para/paths.md` — always
- `../../para/find-target.md` — for the subcommands that take a target
- `../../para/move.md` — always
- `../../para/confirm.md` — always
- `../../para/dod.md` — when the target is a project
- `../../para/tasks.md` — when the target is a project: the operations, pairing, area projects
- `../../para/note-format.md` — when editing frontmatter; «Legacy fields»

## Subcommands

The first word of `$ARGUMENTS` picks the subcommand. `list` and `restore` are the only
keywords — anything else is the target of an archive, so `/archive проект в` archives
that project. Empty `$ARGUMENTS` → show the three subcommands and ask.

---

### `<что>` — put into the archive

1. **Find the target** per `find-target.md`, operation "Archive".

2. **If the target is a project:**
   - **Open tasks first.** Read the paired project's tasks (`task.list`, open,
     with `project_ref`). If tasks are open, list them and ask once (Tier 1.5)
     what happens to them: complete them, move them to an area project (`task.move` with `area`)
     or leave them inside the archived project. Carry the
     answer out before going on. An unpaired project with a legacy `Tasks/` folder has
     no backend side; `dod.md` says how its tasks are checked.
   - Apply `dod.md` and name every condition that does not hold. That file decides
     whether the outcome is completed or abandoned; do not reproduce its reasoning
     here, and do not soften it.
   - Move the **whole folder**, internal structure untouched, from
     `Projects/PROJ-xxxx <title>/` to `Archive/PROJ-xxxx <title>/`. The name stays
     exactly as it is: the id stays with the project for life, and id issuance scans
     `Archive/` to keep it reserved (`project-id.md`).
   - `project.archive` when paired (always, under `pairing: none`; a no-op there). Keep
     `tasks_ref:` in the overview — restore needs it.
   - Legacy fields (`status` and the rest) are left exactly as they are
     (`note-format.md`): an archived project keeps its history.

3. **If the target is a standalone note** (Area, Resource, or a stray from `Inbox/`):
   move the single `.md` into `Archive/`.
   - Areas are ongoing by definition and normally are not archived. Ask what was meant
     (Tier 1.5) — it usually means the note is stale, not that the responsibility ended.
   - A legacy task note inside a project that is *not* being archived: moving it breaks
     nothing useful and is probably not what was meant — ask (Tier 1.5). Tasks are
     closed in the backend now.

4. **Check the basename for collisions** before moving (`move.md`, `note-format.md`).
   A duplicate makes every link to that name ambiguous — Tier 1.5, ask rather than move.

5. **Close the loop — projects only.** Before reporting, ask one question and wait for
   the answer: **что этот проект изменил?** Not what got produced — condition 2 of
   `dod.md` already covers the artifact — but what is different now that it is over,
   and whether it was worth what it cost.

   Before asking, **read `# Ценность` aloud** — the benefit the user wrote down when
   the project began (`note-format.md`, "Three sections about the outcome") — and ask
   whether it came true: «Ожидалось: −5 часов ревью в неделю. Сбылось?». If the
   section is empty or absent, ask the question as it stands, without inventing an
   expectation.

   Write **`# Что изменилось`** at the end of the overview body. Its **first line** is
   the outcome per `dod.md` — `Завершён.` or `Брошен: <причина>.` — then the user's
   answer in their own words; do not summarise it into your own. If the answer names
   something that outlives the project, that is condition 4 of `dod.md` speaking; route
   it to `Areas/` or `Resources/` rather than leaving it in the archive.

   If the user does not want to answer, write only the outcome line and say the loop
   was skipped. Never invent the rest.

6. **Report**: what moved, its new path, the outcome line, what happened to open tasks,
   whether the backend project was archived, any warning.

---

### `list` — show what is in the archive

Read only. Never open the notes beyond what is named below.

1. List `Archive/` — both project folders and loose `.md` files.
2. For each project folder, read the overview frontmatter (`id`, `deadline`) and the
   first line of `# Что изменилось`, if the section exists.
3. Print two Russian sections, each alphabetical, with a count in the header:

```
**Проекты в архиве (N)**
1. PROJ-0005 Проект Д — Завершён, дедлайн 2026-09-30
2. PROJ-0007 Проект Ж — Брошен
3. PROJ-0003 Проект В — без отметки
4. Старый проект — без метаданных

**Заметки в архиве (N)**
1. Какая-то заметка
```

The outcome is read only when the first non-blank line of `# Что изменилось` is
exactly `Завершён.` or starts with `Брошен`. Otherwise — the section is missing, or it
opens with the user's own words, as in projects archived before this rule — print
`без отметки`; never infer an outcome from free text or from a legacy `status`. `без метаданных`
— no frontmatter at all. An empty archive is a valid answer: say it plainly.

---

### `restore <что>` — bring something back

1. **Find the target** per `find-target.md`, operation "Restore from archive".
2. **Work out where it goes back to.** A project returns to `Projects/`. A note
   returns to the PARA folder its frontmatter implies — `area/<slug>` → `Areas/`,
   `resource/<slug>` → `Resources/`. If the tags do not say, or the note predates the
   convention, ask where it belongs. Nothing is restored into `Inbox/` — it is not a
   destination (`paths.md`).
3. **Check the basename for collisions** as above, then move.
4. **The task side — projects only.** `project.restore` with the `ref`. Under
   `pairing: separate` with no `tasks_ref:`, offer to create the pair (`tasks.md`
   «Pairing»); on yes, `project.create`, add a `tasks_ref:` key and fill it. Under
   `pairing: none` there is no pair to offer. Leave ticked checkboxes in `# Критерий готовности` and
   the `# Что изменилось` section as they are — editing them is Tier 2 and rarely
   wanted.
5. **Report**: what came back, to where, and the state of its backend pair.

## Notes

- Never delete anything here. Archiving is always a move into `Archive/`; if the user
  wants something gone, that is `/remove`.
- All user-facing text and every frontmatter value in Russian.
