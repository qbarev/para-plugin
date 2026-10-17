---
name: vault-lint
description: Check the Obsidian PARA vault for structural and schema problems — duplicate filenames, dangling wikilinks, notes in the wrong root, broken project ids, frontmatter that violates the schema, orphaned notes. Read-only by default. Use when the user says "проверь хранилище", "линтер", "что сломалось в хранилище", "проверь схему", "найди битые ссылки", "vault lint", or after a bulk move or rename.
argument-hint: (без аргументов — проверить всё) | --fix
---

# Vault lint

Mechanical check of the vault against its own conventions. **Read-only unless `--fix`
is passed**, and even then only the unambiguous repairs.

The point is to catch what silently rots: a renamed note leaves dangling links, a moved
file collides with another basename, a hand-edited date stops being a Date property.
None of it announces itself.

## Base layer

Read before acting, each as `../../para/<file>.md` relative to this skill's base directory (the vault config `areas.md` is the exception — it is in the vault) — the schema being checked lives there, not here:

- `../../para/paths.md` — the two roots
- `.claude/para/areas.md` (vault config, under `REPO_ROOT`) — the Areas model the schema checks depend on
- `../../para/note-format.md` — the frontmatter schema and allowed values
- `../../para/project-id.md` — the id invariant
- `../../para/confirm.md` — `--fix` edits notes, so Tier 2 applies
- `../../para/tasks.md` — the operations; pairing between `Projects/` and the task backend, area projects

Set `REPO_ROOT` and `PARA_ROOT` from `paths.md` before running anything below, and
`export LC_ALL=C` in the same shell. Under a Russian UTF-8 locale `sort` and `uniq`
compare by collation, and Cyrillic names collate as equal when they are not: `uniq -d`
then reports duplicates that do not exist, and `sort -u` silently drops distinct link
targets. Byte comparison is the only correct one here.

**Exclude `Templates/` from every check.** This includes the `id`, `project:` and
`REPO_ROOT` commands, which recurse into it unless told otherwise. A template is supposed to contain `{{title}}`
and bare `project/` placeholders — that is its job. Checking it produces a false positive
on every run, which is how a linter gets ignored. Every command below therefore carries
`--exclude-dir=Templates` (grep) or `-not -path "*/Templates/*"` (find), and dotfiles are
skipped the same way.

## Severity

Three groups, reported in this order. Never reorder them by count — a single broken
link matters more than thirty unlinked notes.

1. **Ломает хранилище** — links resolve to the wrong file or to nothing.
2. **Нарушает схему** — Obsidian or a skill will misread the metadata.
3. **Стоит посмотреть** — not errors. Reported once, without a recommendation to fix.

---

## Group 1 — ломает хранилище

**Хранилище не настроено.** Run this first: without `vault.md` and `areas.md` nothing
else can run correctly, and every finding below would be computed from a guess. The
reference copies are `../../config.example/` relative to this skill's base directory.

```bash
ls "$REPO_ROOT/.claude/para/vault.md" "$REPO_ROOT/.claude/para/areas.md" >/dev/null 2>&1 \
  || echo "vault.md or areas.md is missing"
diff <(grep -hoE '^\| `[A-Z_]+`' "$SKILL_DIR/../../config.example/"*.md | sort) \
     <(grep -hoE '^\| `[A-Z_]+`' "$REPO_ROOT/.claude/para/vault.md" "$REPO_ROOT/.claude/para/areas.md" | sort)
```

(`SKILL_DIR` is this skill's base directory, as the harness announces it.)

- `vault.md` or `areas.md` missing → report only this, and stop: "run `/para:init` from the
  vault root". Running the rest would produce noise, not findings.
- A key present in `config.example/` but not in the vault's config → **name the key**.
  This is what a tooling update looks like from the inside: the plugin added a setting
  and this vault has not filled it in yet.
- A key still holding its placeholder text (`*italic between asterisks*`) → name it the
  same way.

**Дубли имён файлов.** Wikilinks resolve by basename, so two files with the same name
make every link to that name ambiguous. Check across `REPO_ROOT`, not just `PARA_ROOT`.

```bash
find "$REPO_ROOT" -name "*.md" -not -path "*/.*" -not -path "*/Templates/*" -exec basename {} \; | sort | uniq -d
```

**Висячие вики-ссылки.** Collect every link target, strip aliases (`|`) and heading
anchors (`#`), and check a file of that name exists somewhere.

```bash
grep -rhoE '\[\[[^]]+\]\]' "$PARA_ROOT" --include="*.md" --exclude-dir=Templates \
  | sed 's/^\[\[//; s/\]\]$//; s/|.*//; s/#.*//' | sed 's/[[:space:]]*$//' \
  | sort -u | while IFS= read -r t; do
      [ -z "$t" ] && continue
      case "$t" in
        */*) [ -e "$REPO_ROOT/$t.md" ] || [ -e "$REPO_ROOT/$t" ] || echo "$t" ;;   # path from REPO_ROOT
        *)   find "$REPO_ROOT" \( -name "$t.md" -o -name "$t" \) -not -path "*/.*" | grep -q . || echo "$t" ;;
      esac
    done
```

A target with a `/` is a path from Obsidian's vault root, which is `REPO_ROOT`
(`paths.md`), and is checked at that exact path.

The target is looked up both as a note (`<name>.md`) and as written, so an attachment
(`.pdf`, `.jpg`) and a note whose title contains a dot both resolve.

For each hit, report which notes point at it (`grep -rl`), since the fix depends on
whether the target was renamed, deleted, or never written.

**Заметки в `REPO_ROOT`.** Notes belong under `PARA_ROOT`; anything else is a dropped
path prefix.

```bash
find "$REPO_ROOT" -maxdepth 1 -name "*.md" \
  ! -name "CLAUDE.md" ! -name "README.md" ! -name "CHANGELOG.md"
find "$REPO_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name ".*" ! -name "$PARA_DIR"
```

With `PARA_DIR = .` the PARA folders sit directly in `REPO_ROOT`, so the second command is
skipped there; the rule becomes "no notes outside the PARA folders" (`paths.md`).

`-mindepth 1` matters: without it `find` reports `REPO_ROOT` itself as a hit on every run.
The three excluded names are the repository's own files, not notes — they sit in
`REPO_ROOT` because that is where a repository keeps them, and `.obsidian/app.json`
hides them from the file explorer via `userIgnoreFilters`.

**Лишние папки в `PARA_ROOT`.** Only the folders `paths.md` maps belong directly under
`PARA_ROOT`. Anything else — an old numbered `1. Projects/` brought back by a sync, a
folder created from Obsidian — holds notes no skill will ever look at.

```bash
find "$PARA_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name ".*" \
  ! -name "Inbox" ! -name "Projects" ! -name "Areas" ! -name "Resources" \
  ! -name "Archive" ! -name "Templates"
```

**Файлы в `Inbox/`.** Skip under `TASKS = files`: there `Inbox/` is the real inbox and its
files are open captures (`paths.md`), not findings. Otherwise the folder is Obsidian's fallback, not a destination (`paths.md`);
whatever sits there was created by hand and is waiting to be routed. Name each file and
point at `/inbox process`. `--fix` never touches them — routing is a decision.

```bash
find "$PARA_ROOT/Inbox" -name "*.md"
```

**Дубли `id`.** Two projects with one id make every `project:` backlink ambiguous.

```bash
grep -rhoE '^id: PROJ-[0-9]{4}' "$PARA_ROOT/Projects" "$PARA_ROOT/Archive" | sort | uniq -d
```

**`id` не совпадает с префиксом папки.** The frontmatter is the source of truth; a
mismatch means one of them was edited by hand.

**Заметка указывает на несуществующий проект.** Every `project:` value is a wikilink to
an overview filename — check the target exists.

```bash
grep -rhoE '^project: "\[\[[^]]+\]\]"' "$PARA_ROOT" | sed 's/.*\[\[//; s/\]\]"//' | sort -u
```

---

## Group 2 — нарушает схему

Check every note carrying frontmatter. Values come from `note-format.md`; do not
hardcode a second copy of the allowed list here — read it.

- **`area`**, **`type`** and the Area grouping field — any value outside the allowed
  set for that field, or a field carrying more than one value. Read the sets from the
  "Allowed values" list in `note-format.md` at run time, which for `area` and the
  grouping field means `GROUPS` in `areas.md`. The lists are deliberately not
  repeated here, so that changing one there changes this check.
- **Даты** — `deadline`, `created` not matching `YYYY-MM-DD`. A non-ISO date stops
  being a Date property in Obsidian and silently drops out of sorting. Legacy `due` in
  old task notes is checked too, while they exist.

  ```bash
  grep -rnE '^(deadline|due|created):[[:space:]]*[^[:space:]]' "$PARA_ROOT" --include="*.md" --exclude-dir=Templates \
    | grep -vE ':[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*$'
  ```

- **Плейсхолдеры тегов** — a bare trailing slash never replaced with a real slug.

  ```bash
  grep -rnE '^[[:space:]]+- (project|area|resource|topic)/[[:space:]]*$' "$PARA_ROOT" --include="*.md" --exclude-dir=Templates
  ```

- **Проект без одной из трёх подпапок** — `Notes/`, `Resources/`, `Results/`. Check
  only projects in `Projects/`; archived ones predate the rule. A `Tasks/` folder is
  not required and not an error here — it is legacy (Group 3), unless `TASKS = files`,
  where it is the backend's folder and nothing to report.
- **`short` или `tasks_ref` не на своём месте** — both belong to a Project overview only
  (`note-format.md`).

  ```bash
  grep -rlE '^(short|tasks_ref|todoist):' "$PARA_ROOT" --include="*.md" --exclude-dir=Templates \
    | grep -vE '/(Projects|Archive)/[^/]+/[^/]+\.md$'
  ```

- **Пара с менеджером задач** — only under `pairing: separate` (`tasks.md` «Pairing»).
  For every overview in `Projects/` with a non-blank `tasks_ref`, read
  `project.activity` and use its `state` (always returned; `last_event` is irrelevant
  here):
  - `missing` → «пара потеряна»;
  - `archived` while the folder is in `Projects/` → «в менеджере задач закрыт, в
    хранилище нет» — offer `/archive`, never move it here;
  - the same id on two overviews → name both (a file check, no call needed).

  If the backend is unavailable, say so in one line and skip this check — never report every project as
  broken (`tasks.md` «Backend missing»).

---

## Group 3 — стоит посмотреть

Not errors. Report each as a plain list, **with no suggestion to fix** — these are states
the vault is allowed to be in.

- **Старый формат** — projects in `Projects/` carrying legacy fields or, unless
  `TASKS = files`, a `Tasks/` folder (`note-format.md` «Legacy fields»); under
  `TASKS = files` drop the `Tasks/` part of the command below. Count first, then one line per project
  naming what it carries. This is the migration agenda, not noise.

  ```bash
  for d in "$PARA_ROOT/Projects"/*/; do f="$d$(basename "$d").md"; l=""
    [ -f "$f" ] && l=$(grep -oE '^(status|priority|value|estimate):' "$f" | tr -d ':' | tr '\n' ' ')
    [ -d "${d}Tasks" ] && l="$l Tasks/($(ls "${d}Tasks" | wc -l | tr -d ' '))"
    [ -n "$l" ] && echo "$(basename "$d") — $l"
  done
  ```

- **Копии синхронизации** — `<имя> 2.md` next to `<имя>.md` in the same folder: the
  cloud sync's conflict copy. Which one is current is the user's call; name the pairs.

  ```bash
  find "$PARA_ROOT" -name "* 2.md" -not -path "*/.*" | while IFS= read -r f; do
    [ -f "${f% 2.md}.md" ] && echo "$f"; done
  ```

- **Без пары** — only under `pairing: separate`; two lists. Projects in `Projects/` with
  a blank or missing `tasks_ref`. Backend projects that no overview in `Projects/` or
  `Archive/` points at: `project.list` once, matched by `ref`, leaving out the inbox
  (`is_inbox`) and the `AREA_TASK_PROJECTS` names (`areas.md`); an archived backend
  project paired with an overview in `Archive/` is the normal closed state, not a
  finding. Skip the second list when `project.list` is not supported.
- **Старое имя поля** — overviews carrying `todoist:` where `tasks_ref:` is now
  expected (`note-format.md`). Count and names; renaming is the user's call.

- **Заметки-сироты** — nothing anywhere links to them, so they are reachable only by
  search. Expected for a fresh project note; interesting for an old resource.

  Exclude legacy task notes (`*/Tasks/*`): projects never linked down to them, so every
  one is an orphan by this definition and they swamp the finding that matters.

  ```bash
  find "$PARA_ROOT" -name "*.md" -not -path "*/.*" -not -path "*/Templates/*" \
       -not -path "*/Tasks/*" | while IFS= read -r f; do
    b=$(basename "$f" .md)
    grep -rqlF "[[$b" "$PARA_ROOT" --include="*.md" --exclude-dir=Templates || echo "$b"
  done
  ```

  Report the count, then list only the orphans outside `Inbox/` and `Archive/` —
  a stray is already reported in Group 1, and an archived note is supposed to be
  unlinked.

- **Заметки без frontmatter** — they predate the convention. `CLAUDE.md` says to leave
  them alone, so this is a count and a list, never a migration offer. Do not repeat the
  full list on every run if it is long — give the count and the folders.

---

## Output

Russian, grouped by severity, counts in the headers. Drop any group that is empty —
a clean vault should print three short lines, not a wall of ✓.

```
## Проверка хранилища — N заметок

### Ломает хранилище (2)
- Дубль имени: «Область А.md» в `Areas/<Группа 1>/` и `Resources/<Тема>/`
  — ссылки `[[Область А]]` ведут в одно из двух наугад
- Висячая ссылка `[[Заметка Б]]` из `Resources/<Тема>/Ресурс А.md`

### Нарушает схему (2)
- `Projects/PROJ-0002 Проект Б/PROJ-0002 Проект Б.md` — `deadline: 15.06.2026`,
  ожидается YYYY-MM-DD
- `Projects/PROJ-0003 Проект В/PROJ-0003 Проект В.md` — пара потеряна: проекта
  в менеджере задач с id `abcd…` нет

### Стоит посмотреть
- Старый формат: 3 проекта — PROJ-0008 (status, priority, value, estimate, Tasks/(7)), …
- Без пары: в хранилище 3, в менеджере задач 1 («Проект Д»)
- Сирот: 12 (из них 1 в Archive — это нормально)
- Без frontmatter: 8, все в `Resources/<Тема>/` и `Archive/`
```

End with one line naming what is clean, so a green run says something:
`Дублей id, ссылок на несуществующие проекты, заметок в корне и потерянных пар нет.`

## `--fix`

Only the repairs with exactly one correct answer:

- non-ISO dates where the intent is unambiguous (`15.06.2026` → `2026-06-15`;
  **not** `06/07/2026`, which is ambiguous — report it instead)
- tag placeholders — fill the slug from the note's title
- missing project subfolders — create the empty folder

Everything else is reported, never fixed: a duplicate basename needs a naming decision,
a dangling link needs to know whether the target was renamed or dropped, a lost backend
pair needs to know which side is right, and legacy fields are removed only in the
migration with the user.

Editing notes is Tier 2 (`confirm.md`): list every intended edit, wait for a yes, then
apply. Re-run the check afterwards and show what remains.

## Notes

- Reading is free; do not sample. This vault is a few hundred notes at most — check
  every one of them, and never extrapolate from a subset.
- Never report a pre-convention note as a schema violation. It is exempt by rule, not
  overlooked.
- A finding names the file and what is wrong with it. It does not comment on the user's
  habits.
