---
name: projects
description: Work with Projects in the Obsidian PARA vault and their Todoist pairs — list the active projects, create a project (folder plus Todoist project), summarize where a project stands, or add a task to a project in Todoist. Use when the user says "какие проекты", "список проектов", "покажи проекты", "что у меня в работе", "заведи проект", "новый проект", "саммари по проекту", "обзор проекта", "что по проекту", "статус проекта", "где я по проекту", "добавь задачу", "заведи задачу".
argument-hint: list | create <описание> | overview <проект> | task <проект> <задача>
---

# Projects

Projects are efforts with a **defined goal and an end state** — unlike Areas, which are
ongoing. A project is a **folder** in the vault paired with a **project in the task backend**:
the folder holds what the project means, the backend holds its tasks (`tasks.md`).
Every task call is an operation from `tasks.md`, run per the adapter for `TASKS`.

## Base layer

Read before acting, each as `../../para/<file>.md` relative to this skill's base directory — these hold the shared rules, do not restate them from memory:

- `../../para/paths.md` — always
- `../../para/tasks.md` — always: the operations, pairing, what a task is
- `../../para/find-target.md` — for `overview` and `task`
- `../../para/note-format.md` — for `create`; for every subcommand, «Legacy fields»
- `../../para/project-id.md` — for `create`
- `../../para/dod.md` — for `create` (writing `# Критерий готовности`) and `overview`
- `../../para/thresholds.md` — for `list` and `overview`: project order, staleness,
  horizons, task counts, output size
- `../../para/confirm.md` — `create` and `task` write (Tier 1); `list` and `overview`
  write nothing
- `../../para/move.md` — for `create`, before writing a folder that may collide

## Subcommands

The first word of `$ARGUMENTS` picks the subcommand: `list`, `create`, `overview`,
`task`. If it is none of those, work out which is meant from the phrasing and say which
you picked. Empty `$ARGUMENTS` → run `list`, then ask what to do.

Every subcommand meets projects that predate the task backend: `status`, `Tasks/`, no
`tasks_ref` field. Read them as `note-format.md` «Legacy fields» says — report, never
rewrite.

---

### `create <описание>` — start a project

Input: what the project is, its goal, deadline, first steps. Empty → ask what the
project is and its goal.

1. **Read `Templates/Project.md`** from disk, verbatim.

2. **Derive a title** per `note-format.md`. It is used three ways: as `title` and the H1
   **without** the id prefix, and — **with** the prefix — as the folder name and the
   overview filename. **Propose `short`** per `note-format.md`.

3. **Issue the id** per `project-id.md`.

4. **Create the folder structure** under `Projects/`:

   ```
   PROJ-xxxx <title>/
   ├── PROJ-xxxx <title>.md      ← overview, from Templates/Project.md
   ├── Notes/
   ├── Resources/
   └── Results/
   ```

   All three subfolders, even empty. No `Tasks/`.

5. **Fill the frontmatter** per the Project row in `note-format.md`. `created` is today.
   `deadline` only if the description gives one. `tasks_ref` stays blank until step 7.

6. **Fill the body:**
   - `# Цель` — the goal / desired end state. **Required.**
   - `# Ценность` — what the user gains, measurable or unambiguous
     (`note-format.md`, "Three sections about the outcome"). **Required.** If either
     this or `# Цель` is not clear from the input, ask for both in one question
     (`confirm.md`, Tier 1.5) before writing.
   - `# Проблема` — what prompted the project.
   - `# Ожидаемый результат` — the concrete artifacts and where they live.
   - `# Скоуп работ` — only the items the user named. Usually empty: the research
     task fills it (`tasks.md` «The research task»).
   - `# Критерий готовности` — checkboxes per `dod.md`. If the description does not let
     you derive real checks, ask — as for a missing `# Цель`.
   - `# Ссылки` — wikilinks to clearly related notes, otherwise the template's `-`.

7. **Create the pair** per `tasks.md` «Pairing»: `project.create` with the title and
   the id. Write the returned `ref` into `tasks_ref:`. If the call fails, say so: the folder stays, unpaired, and
   `/projects task` will offer to pair it later.

8. **First tasks** in the new project, **without dates**:
   - the research task per `tasks.md` «The research task», **always**, unless the
     user already named the full scope — then write it into `# Скоуп работ` instead;
   - steps the user named explicitly, added with `task.add` and worded per «What a task is». A step that cannot
     be worded as an action is a question for the research, not a task.

   Never invent steps the user did not name.

9. **Report** the folder path, id, title, `short` (offering to change it), deadline,
   goal, the value line, the backend project name, and the tasks created.

If the input describes an ongoing responsibility with no end, this is not a project —
say so and offer `/areas create` instead. If it is an idea the user has not decided to
take on, say that it is not a project yet (`tasks.md` «Pairing») and offer to leave
it in «Входящие».

---

### `task <проект> <задача>` — add a task

1. **Find the project** per `find-target.md`, operation «Add a task to a project».
   The target may also be an area project from `AREA_TASK_PROJECTS` in
   `areas.md` — match it by name.
2. **Resolve the project**: the overview's `tasks_ref`, or the area project.
   - No `tasks_ref` on the overview → say «нет пары в менеджере задач» and offer to create it
     (step 7 of `create`). On yes, create the pair, then continue. Never write the task
     into the vault instead.
3. **Word the task** per `tasks.md` «What a task is». If the user's wording already
   fits, keep it; otherwise propose the reworded version in the announcement. If it
   cannot be an action, ask for the next step (Tier 1.5).
4. **`task.add`** into that project: the text, a description for anything longer,
   `duration` only if given. The date rule is `tasks.md` «Fields».
5. **Report** the task and the project.

---

### `overview <проект>` — where the project stands

**Read-only.** Writes nothing — not to the vault, not to the backend. If the summary
surfaces something worth fixing, say so and let the user decide.

1. **Find the project** per `find-target.md`, operation "Report on". With no argument,
   list the projects and ask.

2. **Read the overview note**: frontmatter and the sections `# Цель`, `# Ценность`,
   `# Ожидаемый результат`, `# Критерий готовности`, `# Ссылки`. A blank field is
   reported as blank, never filled in from inference.

3. **Read the tasks** (`task.list`, open): their dates and durations. Compute the counts
   per `thresholds.md` «Task counts». No pair → skip, and say «нет пары в менеджере
   задач».

4. **Read `Notes/`** (and `Results/`, if it has anything) in full, up to the cap in
   `thresholds.md` — this is where decisions and risks actually live.

5. **Legacy.** If the overview carries `status` / `priority` / `value` / `estimate`, or
   the folder has `Tasks/`, add one line: `Старый формат: status, Tasks/ (N файлов) —
   перенести при груминге`, naming only what is present. Do not read task notes for
   progress; the migration decides what survives.

6. **Signals** — report only those that fire:
   - the project's `deadline` past, or inside the horizon in `thresholds.md`;
   - overdue tasks — say by how many days;
   - nothing scheduled while the deadline is inside the horizon;
   - dated tasks without a duration;
   - quiet longer than the project threshold in `thresholds.md`, measured as it says
     (`project.activity` when paired, mtime otherwise, per `thresholds.md`);
   - dangling wikilinks in `# Ссылки`;
   - every acceptance criterion ticked while the project is still in `Projects/` —
     finished and not closed.

7. **Render to chat, in Russian**:

   ```
   ## PROJ-0001 · Проект А

   **Область** Область А · **Дедлайн** 31.10.2026 — 14 дней
   **Задачи** запланировано 3 · просрочено 1 · в бэклоге 6
   **Приёмка** ☑☐☐ 1/3

   ### Суть
   <Цель, 1–2 предложения.>
   <Ожидаемый результат — одной строкой.>
   <Ценность — одной строкой.>

   ### Запланировано
   - **Написать поставщику письмо** — ВТ 21.10, 30 мин
   - **Заполнить анкету** — просрочена на 2 дня, 1 ч

   ### Бэклог
   - Записаться на приём
   - …и ещё 3

   ### Выжимка
   - <Ключевое решение или вывод из Notes/ — своими словами.>

   ### Сигналы
   - Дедлайн через 14 дней, ничего не запланировано
   ```

   «Бэклог» shows the oldest undated tasks up to the cap in `thresholds.md`. Drop any
   section or field that would be empty. An empty `Results/` is a normal state.

---

### `list` — the projects

**Read-only.** One line per project — the index, not a summary: never opens `Notes/`.

1. **Enumerate** the folders directly under `Projects/`. Archived projects are not
   listed — that is `/archive list`.

2. **Read the overview frontmatter**: `id`, `title`, `area`, `deadline`, `tasks_ref`.
   A folder with no frontmatter is pre-convention — print it by folder name with
   `без метаданных`.

3. **Read the tasks** of each paired project (`task.list`, open), counted per `thresholds.md` «Task counts».

4. **Order** per `thresholds.md` «Project order».

5. **Render, in Russian**:

   ```
   **Проекты (4)**
   1. PROJ-0008 Проект А — Область А · до 31.10 (14 дн) · запланировано 2 · бэклог 3
   2. PROJ-0020 Проект Б — до 31.10 (14 дн) · запланировано 0 · бэклог 3
   3. PROJ-0009 Проект В — Область Б · до 28.02 · нет пары в менеджере задач · старый формат
   4. PROJ-0027 Проект Г — бэклог пуст
   ```

   - A past deadline: `дедлайн прошёл N дн назад`.
   - `старый формат` when legacy fields or `Tasks/` are present.
   - Drop any blank field rather than printing a placeholder. An empty `Projects/` is a
     valid answer: say it plainly.

## Archived and pre-convention projects

Projects in `Archive/` may predate the conventions: no frontmatter, no `PROJ-xxxx`
prefix, no subfolders. Read `# Цель` from the note, skip the tasks section and
**Приёмка**, and state plainly that it is archived and in the old format.

## Notes

- Compute, don't estimate: day counts, task counts and overdue spans come from the backend,
  the files and today's system date. If something cannot be computed because a field
  is blank, say it is blank rather than guessing.
- A summary reports on state; it does not judge the user. "просрочена на 5 дней", not
  "ты забросил проект".
- Everything in Russian, tasks included.
