---
name: vault-lint
description: Check the Obsidian PARA vault for structural and schema problems — duplicate filenames, dangling wikilinks, notes in the wrong root, broken project ids, frontmatter that violates the schema, orphaned notes. Read-only by default. Use when the user says "check the vault", "lint the vault", "what is broken in the vault", "check the schema", "find broken links", "проверь хранилище", "линтер", "что сломалось в хранилище", "проверь схему", "найди битые ссылки", "vault lint", or after a bulk move or rename.
argument-hint: (no arguments — check everything) | --fix
---

# Vault lint

Mechanical check of the vault against its own conventions. **Read-only unless `--fix`
is passed**, and even then only the unambiguous repairs.

The point is to catch what silently rots: a renamed note leaves dangling links, a moved
file collides with another basename, a hand-edited date stops being a Date property.
None of it announces itself.

## Base layer

Read before acting, each as `../../para/<file>.md` relative to this skill's base directory (the vault config `areas.md` is the exception — it is in the vault) — the schema being checked lives there, not here:

- `../../para/paths.md` — the two roots, and «Language»: finding names and headings come from `lang/<LANG>.md`
- `.claude/para/areas.md` (vault config, under `REPO_ROOT`) — the Areas model the schema checks depend on
- `../../para/note-format.md` — the frontmatter schema and allowed values
- `../../para/project-id.md` — the id invariant
- `../../para/confirm.md` — `--fix` edits notes, so Tier 2 applies
- `../../para/tasks.md` — the operations; pairing between `Projects/` and the task backend, area projects

Set `REPO_ROOT` and `PARA_ROOT` from `paths.md` before running anything below, and
`export LC_ALL=C` in the same shell. Under a UTF-8 locale `sort` and `uniq`
compare by collation, and non-Latin names (Cyrillic, say) can collate as equal when they are not: `uniq -d`
then reports duplicates that do not exist, and `sort -u` silently drops distinct link
targets. Byte comparison is the only correct one here.

**`IGNORE`** (`paths.md` «IGNORE») — the paths PARA leaves alone. Define `ignore_list`
and `not_ignored` as `paths.md` gives them. **Every check leaves ignored paths out**:
the `find` lists below pipe through `not_ignored`, and a `grep` hit whose file is
ignored is dropped (Group 2 runs over a pre-filtered note list). The one exception is
`lint.finding.duplicate_names`, which deliberately includes them: links resolve across
the whole vault, ignored paths included. `--fix` never edits an ignored path.

**Exclude `Templates/` from every check.** This includes the `id`, `project:` and
`REPO_ROOT` commands, which recurse into it unless told otherwise. A template is supposed to contain `{{title}}`
and bare `project/` placeholders — that is its job. Checking it produces a false positive
on every run, which is how a linter gets ignored. Every command below therefore carries
`--exclude-dir=Templates` (grep) or `-not -path "*/Templates/*"` (find), and dotfiles are
skipped the same way.

## Severity

Three groups, reported in this order. Never reorder them by count — a single broken
link matters more than thirty unlinked notes. Each finding below is printed under the
name its `lint.finding.*` key gives, and each group under its `lint.group.*` key.

1. `lint.group.breaks` — links resolve to the wrong file or to nothing.
2. `lint.group.schema` — Obsidian or a skill will misread the metadata.
3. `lint.group.review` — not errors. Reported once, without a recommendation to fix.

---

## Group 1 — `lint.group.breaks`

**`lint.finding.not_configured`.** Run this first: without `vault.md` and `areas.md` nothing
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

**`lint.finding.duplicate_names`.** Wikilinks resolve by basename, so two files with the same name
make every link to that name ambiguous. Check across `REPO_ROOT`, not just `PARA_ROOT`,
and **including** `IGNORE` (`paths.md` «IGNORE»).

```bash
find "$REPO_ROOT" -name "*.md" -not -path "*/.*" -not -path "*/Templates/*" -exec basename {} \; | sort | uniq -d
```

**`lint.finding.dangling_links`.** Collect every link target, strip aliases (`|`) and heading
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

**`lint.finding.notes_in_repo_root`.** Notes belong under `PARA_ROOT`; anything else is a dropped
path prefix.

```bash
find "$REPO_ROOT" -maxdepth 1 -name "*.md" \
  ! -name "CLAUDE.md" ! -name "README.md" ! -name "CHANGELOG.md" | not_ignored
find "$REPO_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name ".*" ! -name "$PARA_DIR" | not_ignored
```

With `PARA_DIR = .` the PARA folders sit directly in `REPO_ROOT`, so the second command is
skipped there; the rule becomes "no notes outside the PARA folders" (`paths.md`).

`-mindepth 1` matters: without it `find` reports `REPO_ROOT` itself as a hit on every run.
The three excluded names are the repository's own files, not notes — they sit in
`REPO_ROOT` because that is where a repository keeps them, and `.obsidian/app.json`
hides them from the file explorer via `userIgnoreFilters`.

**`lint.finding.extra_folders`.** Only the folders `paths.md` maps belong directly under
`PARA_ROOT`. Anything else — an old numbered `1. Projects/` brought back by a sync, a
folder created from Obsidian — holds notes no skill will ever look at.

```bash
find "$PARA_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name ".*" \
  ! -name "Inbox" ! -name "Projects" ! -name "Areas" ! -name "Resources" \
  ! -name "Archive" ! -name "Templates" | not_ignored
```

**`lint.finding.inbox_files`.** Skip under `TASKS = files` (`paths.md`: there every file is a capture, not a finding). Otherwise the folder is Obsidian's fallback, not a destination (`paths.md`);
whatever sits there was created by hand and is waiting to be routed. Name each file and
point at `/inbox process`. `--fix` never touches them — routing is a decision.

```bash
find "$PARA_ROOT/Inbox" -name "*.md"
```

**`lint.finding.duplicate_ids`.** Two projects with one id make every `project:` backlink ambiguous.

```bash
grep -rhoE '^id: PROJ-[0-9]{4}' "$PARA_ROOT/Projects" "$PARA_ROOT/Archive" | sort | uniq -d
```

**`lint.finding.id_mismatch`.** The frontmatter is the source of truth; a
mismatch means one of them was edited by hand.

**`lint.finding.dangling_project`.** Every `project:` value is a wikilink to
an overview filename — check the target exists.

```bash
grep -rhoE '^project: "\[\[[^]]+\]\]"' "$PARA_ROOT" | sed 's/.*\[\[//; s/\]\]"//' | sort -u
```

---

## Group 2 — `lint.group.schema`

Check every note carrying frontmatter **outside `IGNORE`** — an adopted vault's daily
notes keep their own frontmatter, and reporting it would flood the group. Build the list
once and run each `grep` below over it instead of over `"$PARA_ROOT"`:

```bash
find "$PARA_ROOT" -name "*.md" -not -path "*/.*" -not -path "*/Templates/*" | not_ignored \
  | tr '\n' '\0' > "$TMPDIR/para-notes"
xargs -0 grep -nE '<pattern>' /dev/null < "$TMPDIR/para-notes"   # in place of grep -rnE … "$PARA_ROOT"
```

Values come from `note-format.md`; do not hardcode a second copy of the allowed list
here — read it.

- **`area`**, **`type`** and the Area grouping field — any value outside the allowed
  set for that field, or a field carrying more than one value. Read the sets from the
  "Allowed values" list in `note-format.md` at run time, which for `area` and the
  grouping field means `GROUPS` in `areas.md`. The lists are deliberately not
  repeated here, so that changing one there changes this check.
- **`lint.finding.dates`** — `deadline`, `created` not matching `YYYY-MM-DD`. A non-ISO date stops
  being a Date property in Obsidian and silently drops out of sorting. Legacy `due` in
  old task notes is checked too, while they exist.

  ```bash
  grep -rnE '^(deadline|due|created):[[:space:]]*[^[:space:]]' "$PARA_ROOT" --include="*.md" --exclude-dir=Templates \
    | grep -vE ':[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*$'
  ```

- **`lint.finding.tag_placeholders`** — a bare trailing slash never replaced with a real slug.

  ```bash
  grep -rnE '^[[:space:]]+- (project|area|resource|topic)/[[:space:]]*$' "$PARA_ROOT" --include="*.md" --exclude-dir=Templates
  ```

- **`lint.finding.missing_subfolders`** — `Notes/`, `Resources/`, `Results/`. Check
  only projects in `Projects/`; archived ones predate the rule. A `Tasks/` folder is
  not required and not an error here (legacy or not: `note-format.md` «Legacy fields»).
- **`lint.finding.misplaced_fields`** — both belong to a Project overview only
  (`note-format.md`).

  ```bash
  grep -rlE '^(short|tasks_ref|todoist):' "$PARA_ROOT" --include="*.md" --exclude-dir=Templates \
    | grep -vE '/(Projects|Archive)/[^/]+/[^/]+\.md$'
  ```

- **`lint.finding.pair`** — only under `pairing: separate` (`tasks.md` «Pairing»).
  For every overview in `Projects/` with a non-blank `tasks_ref`, read
  `project.activity` and use its `state` (always returned; `last_event` is irrelevant
  here):
  - `missing` → the `lint.pair_lost` string (`{id}` = the `tasks_ref`);
  - `archived` while the folder is in `Projects/` → the `lint.pair_closed` string —
    offer `/archive`, never move it here;
  - the same id on two overviews → name both (a file check, no call needed).

  If the backend is unavailable, say so in one line and skip this check — never report every project as
  broken (`tasks.md` «Backend missing»).

---

## Group 3 — `lint.group.review`

Not errors. Report each as a plain list, **with no suggestion to fix** — these are states
the vault is allowed to be in.

- **`lint.finding.legacy`** — projects in `Projects/` carrying legacy fields or a
  legacy `Tasks/` folder (`note-format.md` «Legacy fields», which says when it is not
  legacy: then drop the `Tasks/` part of the command below). Count first, then one line per project
  naming what it carries. This is the migration agenda, not noise.

  ```bash
  for d in "$PARA_ROOT/Projects"/*/; do f="$d$(basename "$d").md"; l=""
    [ -f "$f" ] && l=$(grep -oE '^(status|priority|value|estimate):' "$f" | tr -d ':' | tr '\n' ' ')
    [ -d "${d}Tasks" ] && l="$l Tasks/($(ls "${d}Tasks" | wc -l | tr -d ' '))"
    [ -n "$l" ] && echo "$(basename "$d") — $l"
  done
  ```

- **`lint.finding.sync_copies`** — `<name> 2.md` next to `<name>.md` in the same folder: the
  cloud sync's conflict copy. Which one is current is the user's call; name the pairs.

  ```bash
  find "$PARA_ROOT" -name "* 2.md" -not -path "*/.*" | while IFS= read -r f; do
    [ -f "${f% 2.md}.md" ] && echo "$f"; done
  ```

- **`lint.finding.unpaired`** — only under `pairing: separate`; two lists (counts printed
  with the `lint.unpaired_counts` string). Projects in `Projects/` with
  a blank or missing `tasks_ref`. Backend projects that no overview in `Projects/` or
  `Archive/` points at: `project.list` once, matched by `ref`, leaving out the inbox
  (`is_inbox`) and the `AREA_TASK_PROJECTS` names (`areas.md`); an archived backend
  project paired with an overview in `Archive/` is the normal closed state, not a
  finding. Skip the second list when `project.list` is not supported.
- **`lint.finding.old_field_name`** — overviews carrying `todoist:` where `tasks_ref:` is now
  expected (`note-format.md`). Count and names; renaming is the user's call.

- **`lint.finding.orphans`** — nothing anywhere links to them, so they are reachable only by
  search. Expected for a fresh project note; interesting for an old resource.

  Exclude legacy task notes (`*/Tasks/*`): projects never linked down to them, so every
  one is an orphan by this definition and they swamp the finding that matters.

  ```bash
  find "$PARA_ROOT" -name "*.md" -not -path "*/.*" -not -path "*/Templates/*" \
       -not -path "*/Tasks/*" | not_ignored | while IFS= read -r f; do
    b=$(basename "$f" .md)
    grep -rqlF "[[$b" "$PARA_ROOT" --include="*.md" --exclude-dir=Templates || echo "$b"
  done
  ```

  Report the count, then list only the orphans outside `Inbox/` and `Archive/` —
  a stray is already reported in Group 1, and an archived note is supposed to be
  unlinked.

- **`lint.finding.no_frontmatter`** — they predate the convention. `CLAUDE.md` says to leave
  them alone, so this is a count and a list, never a migration offer. Do not repeat the
  full list on every run if it is long — give the count and the folders.

---

## Output

In `LANG`, grouped by severity, counts in the headers. The title is the `lint.heading`
string, the group headings are the `lint.group.*` strings, each finding is named by its
`lint.finding.*` string. Drop any group that is empty — a clean vault should print three
short lines, not a wall of ✓. The sentences after a finding's name are written fresh in
`LANG`. Shown here with the English strings:

```
## Vault check — N notes

### Breaks the vault (2)
- Duplicate filenames: «Area A.md» in `Areas/<Group 1>/` and `Resources/<Topic>/`
  — links `[[Area A]]` resolve to one of the two at random
- Dangling wikilinks: `[[Note B]]` from `Resources/<Topic>/Resource A.md`

### Violates the schema (2)
- Dates: `Projects/PROJ-0002 Project B/PROJ-0002 Project B.md` — `deadline: 15.06.2026`,
  expected YYYY-MM-DD
- Pair with the task manager: `Projects/PROJ-0003 Project C/PROJ-0003 Project C.md` —
  pair lost: no project with id `abcd…` in the task manager

### Worth a look
- Old format: 3 projects — PROJ-0008 (status, priority, value, estimate, Tasks/(7)), …
- Unpaired: 3 in the vault, 1 in the task manager («Project D»)
- Orphan notes: 12 (1 of them in Archive — that is normal)
- Notes without frontmatter: 8, all in `Resources/<Topic>/` and `Archive/`
```

End with one line naming what is clean, so a green run says something: the `lint.clean`
string.

## `--fix`

Only the repairs with exactly one correct answer:

- non-ISO dates where the intent is unambiguous (`15.06.2026` → `2026-06-15`;
  **not** `06/07/2026`, which is ambiguous — report it instead)
- tag placeholders — fill the slug from the note's title
- missing project subfolders — create the empty folder

None of them touches a path under `IGNORE`. Everything else is reported, never fixed:
a duplicate basename needs a naming decision, a dangling link needs to know whether the
target was renamed or dropped, a lost backend pair needs to know which side is right,
and legacy fields are removed only in the migration with the user.

Editing notes is Tier 2 (`confirm.md`): list every intended edit, wait for a yes, then
apply. Re-run the check afterwards and show what remains.

## Notes

- Reading is free; do not sample. This vault is a few hundred notes at most — check
  every one of them, and never extrapolate from a subset.
- Never report a pre-convention note as a schema violation. It is exempt by rule, not
  overlooked.
- A finding names the file and what is wrong with it. It does not comment on the user's
  habits.
