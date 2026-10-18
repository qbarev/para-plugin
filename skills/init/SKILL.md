---
name: init
description: Set up a folder as a PARA vault run by this plugin, or bring an already set-up vault up to date — detect what the folder is, ask the setup questions one at a time, show one plan, apply it on one «yes», report. Re-running fills in what is missing and migrates an older vault schema. Use when the user says "set up the vault", "init the vault", "initialise PARA", "migrate the vault", "run /para:init", "настрой хранилище", "инициализируй хранилище", "подключи PARA", "мигрируй хранилище".
argument-hint: (no arguments — ask everything) | the answers given in advance
---

# Init

Turns the folder the session was started in into a PARA vault wired to this plugin,
and keeps it that way: a second run fills in what is missing and migrates an older
schema. It is the only skill that writes the vault's config, and the only one that runs
without it.

## What it writes

Everything below and nothing else. `REPO_ROOT`, `PARA_DIR`, `PARA_ROOT` as `paths.md`
defines them.

| What | Where | How |
|---|---|---|
| the PARA folders | `PARA_ROOT/` + `Projects`, `Areas`, `Resources`, `Archive`, `Inbox`, `Templates` | created when missing |
| the note templates | `PARA_ROOT/Templates/` | seeded from the plugin, only when missing («Templates») |
| vault config | `REPO_ROOT/.claude/para/vault.md`, `areas.md`; `adapter.md` only when `TASKS` is `mcp` | from `config.example/`; never overwritten |
| the plugin's block | `REPO_ROOT/CLAUDE.md` | between the markers only («CLAUDE.md») |
| the skills' permissions | `REPO_ROOT/.claude/settings.json` | merged, never replaced («Settings») |
| Obsidian settings | `REPO_ROOT/.obsidian/app.json`, `templates.json` | merged («Obsidian») |
| the user's notes and folders (B only) | from where they are into the PARA folders | **moved, never edited** — only the moves the approved plan lists («Scenario B») |
| project overviews (B only) | `PARA_ROOT/Projects/PROJ-xxxx <title>/` | new, for a folder the user called a project («Scenario B») |

## Base layer

Read before acting, each as `../../para/<file>.md` relative to this skill's base directory
(and `../../config.example/`, `../../lang/`, `../../templates/` the same way):

- `../../para/paths.md` — always: the two roots, «Language», the adapter for `TASKS`.
  Everything `init` writes has to agree with it.
- `../../para/tasks.md` — the operations, «Pairing», «Backend missing»
- `../../para/adapters/mcp-generic.md` — when `TASKS` is `mcp`; the adapter for any
  other value is named by `paths.md`
- `../../para/note-format.md` — the frontmatter schema the templates must match
- `../../para/migrations.md` — the plugin's current `SCHEMA` and how a migration runs
- `../../para/claude-md-block.md` — the block for `CLAUDE.md`
- `../../para/confirm.md` — the tiers; the plan below is how `init` meets them
- `../../config.example/vault.md`, `areas.md`, `adapter.md` — the shape of the config
- scenario B only: `../../para/move.md` (how a move keeps links), `../../para/project-id.md`
  (issuing an id), `../../para/thresholds.md` (the area-staleness threshold and «The limit
  of mtime»), `paths.md` «IGNORE»
- `../../lang/<LANG>.md` once `LANG` is known: the `init.*` strings

`SKILL_DIR` below is this skill's base directory, as the harness announces it.

## Rules for the whole run

- **`REPO_ROOT` is the session's working directory**, as an absolute path (`pwd`). This
  is the one place the plugin takes a root from the working directory: `init` is what
  writes it down for every other skill. The plan says which folder it is, so a session
  started in the wrong place is caught before anything is written.
- **Nothing is written before the plan's «yes».** Inspecting, asking and probing the task
  backend are read-only.
- **`vault.md` is written last.** It is what marks a vault as set up; an interrupted run
  leaves no `vault.md` and the next run starts over, finding the work already done.
- **Every step is idempotent**: create when missing, merge when present, never
  overwrite. Running `init` twice in a row changes nothing the second time.
- Quote every path (`paths.md` «Rules»). `REPO_ROOT` may contain spaces.
- **Language.** Until `LANG` is chosen, speak the language the user wrote in (English
  when there is nothing to go by — a bare `/para:init`). From then on, everything is in
  `LANG` per `paths.md` «Language», including the remaining questions; the plan and
  report headings are the `init.*` strings.

## Answers given in advance

`$ARGUMENTS` may already carry answers: the language, `PARA_DIR` («the default» means
the proposed one), the task backend, the Areas model, in scenario B the sorting answers
(per folder or root note, and for the duplicate names), the snapshot answer, and an
approval of the plan. Take every answer given and **do not ask it again**; ask only
what is missing. An answer that is not a valid choice is asked again, saying why.

An approval given in advance means: **show the plan, then apply it without waiting** —
but only while every line of the plan adds something (a folder, a file, a key, an
entry). A line that changes or replaces something that already exists (a differing
Obsidian value, a different `CLAUDE.md` block, a template in a migration, `REPO_ROOT`
in an existing `vault.md`) is Tier 2 (`confirm.md`): the plan is shown and `init` waits
for a «yes» even then.

Scenario B's moves do not count as such lines: a move changes where a note is, never
what it says, and `confirm.md` puts moving in Tier 1. They are covered by the plan's
«yes», given then or in advance — the snapshot is offered before them all the same
(Step 4). A sorting question answered in advance is not asked; one left unanswered is
asked, and nothing is applied before its answer, approval or not.

---

## Step 1 — Inspect

Read-only. Find out what the folder is and name the scenario.

```bash
REPO_ROOT=$(pwd)
ls -A "$REPO_ROOT"
ls "$REPO_ROOT/.claude" "$REPO_ROOT/.claude/para" "$REPO_ROOT/.claude/skills" 2>/dev/null
# the old embedded layout (scenario C): its config folder, its base layer, its skills
ls -d "$REPO_ROOT/.claude/para/local" "$REPO_ROOT/.claude/para/paths.md" 2>/dev/null   # old-layout
for s in inbox projects areas resources archive remove vault-lint; do
  [ -f "$REPO_ROOT/.claude/skills/$s/SKILL.md" ] && echo "old skill: $s"; done
# notes: every .md not under a dot-entry of REPO_ROOT, except the repository's own files
# and templates (dot-entries are pruned relative to REPO_ROOT, so a vault that itself
# lives under a dot-directory is still seen)
find "$REPO_ROOT" -mindepth 1 -name '.*' -prune -o -name "*.md" -not -path "*/Templates/*" \
  ! -path "$REPO_ROOT/CLAUDE.md" ! -path "$REPO_ROOT/README.md" ! -path "$REPO_ROOT/CHANGELOG.md" -print | head -50
# a vault above this folder: init was started in a subfolder
d=$(dirname "$REPO_ROOT")
while [ "$d" != "/" ] && [ "$d" != "$HOME" ]; do
  { [ -e "$d/.claude/para/vault.md" ] || [ -d "$d/.obsidian" ]; } && echo "vault above: $d"
  d=$(dirname "$d")
done
```

Stop before anything else when:

- `REPO_ROOT` is `$HOME` or `/` — not a vault; say so.
- a vault was found above — say «run `/para:init` from `<that folder>`» and stop; never
  set up a vault inside another one.

Then decide, **in this order**, and say what was found and which case it is:

1. **Set up** — `.claude/para/vault.md` exists → «Re-run and migration» below.
2. **Scenario C** — the old embedded tooling, recognised by its own layout only (the
   `old-layout` lines above): its config folder `local/` or its base layer file
   `paths.md` inside `.claude/para/`, or a `SKILL.md` of a PARA skill in
   `.claude/skills/` (`inbox`, `projects`, `areas`, `resources`, `archive`, `remove`,
   `vault-lint`). → «Scenario C».
   A `.claude/para/` holding only this plugin's config files (`areas.md`, `adapter.md`)
   and no `vault.md` is **not** C: it is a first run of `init` that was interrupted or
   refused before `vault.md`. Go on to B or A below as if it were not there, except that
   those files are the vault's config — never overwritten — and a question they already
   answer (question 4 for `areas.md`) is not asked again. The run fills in the rest.
3. **Scenario B** — notes were found (the `find` above printed anything). →
   «Scenario B».
4. **Scenario A** — otherwise: an empty folder, or one holding only non-note files
   (an `.obsidian/` of a new Obsidian vault, a `CLAUDE.md`). → Step 2.

---

## Step 2 — Questions

One at a time, in this order, skipping every one answered in advance. Each question
shows its choices and, where there is one, the default.

1. **Language** (`LANG`). The choices are the languages the plugin ships: a code with
   both `lang/<code>.md` and `templates/<code>/` (`paths.md` «Language»):

   ```bash
   for f in "$SKILL_DIR"/../../lang/*.md; do l=$(basename "$f" .md)
     [ -d "$SKILL_DIR/../../templates/$l" ] && echo "$l"; done
   ```

2. **PARA folder** (`PARA_DIR`). Default per scenario: A — `PARA`, a subfolder, so the
   tooling and the notes stay apart; B — `.`, so the PARA folders sit next to the
   user's own folders, except as «Scenario B» says. `.` puts the PARA folders straight
   into `REPO_ROOT`. Valid: `.` or one folder name — no `/`, not starting with `.`, not one
   of the PARA folder names themselves.

3. **Task backend** (`TASKS`). The choices are `todoist`, `files` or `mcp`; the first is
   recommended. Say in one line what each means: an app's inbox and projects; task
   notes in the vault, no app; any other to-do app connected over MCP. Then **probe** —
   «Probing the backend» below. A value whose probe failed is never recorded.

4. **Areas model** (`areas.md`). One question: are Areas grouped — `none`, or the
   names of the groups (for example Work, Home)? Everything else is derived and shown in
   the plan, where the user can change it:

   | Key | Grouped | `none` |
   |---|---|---|
   | `GROUPING` | the field name, `sphere` unless the user named one (the seed templates' key) | `none` |
   | `GROUPS` | the names given | empty |
   | `PLACEMENT` | `Areas/<GROUP>/<title>.md` | `Areas/<title>.md` |
   | `REVIEW_GROUPING` | one block per group, groups with nothing to report dropped | one flat list |
   | `PLACEMENT_CHECK` | a note's `GROUPING` field must name the top-level folder it sits under | `none` |
   | `AREA_TASK_PROJECTS` | the `GROUPS` names | one name: the `areas.review.heading` string |

### Probing the backend

The probe is `inbox.list`, run per the adapter for the chosen value (`paths.md`). It is
read-only; an empty inbox is a success. Print only the count, never the captures.

- **`files`** — nothing to probe: the adapter is the disk, and «Backend missing» cannot
  happen (`tasks.md`).
- **`mcp`** — run steps 1–6 of `adapters/mcp-generic.md` now. Step 1 finding no tools is
  a failed probe. Step 6 is the probe when the user agrees to it and the app has an
  inbox; otherwise the plan says the mapping is unverified. Steps 7–8 belong to the
  plan and to «Step 5» below.
- **Any other value** — run `inbox.list` per its adapter. If the adapter's tools are not
  in this session, or the call fails: say so in one line (`tasks.md` «Backend
  missing»), **do not record the value**, and offer `files` instead — or connecting the
  app and running `/para:init` again. Never write a `TASKS` value whose probe did not
  succeed, and never record one value while promising to switch later.

---

## Step 3 — The plan

**One list of everything** that will be created, merged or changed, headed by the
`init.plan.heading` string. It is a proposal the user edits, not an announcement: an
edit makes a new plan, shown again. It ends with the `init.plan.approve` string, and
nothing is applied before a «yes» (or the approval given in advance, within the limit
«Answers given in advance» sets).

The plan names, in this order:

1. `REPO_ROOT` (this folder) and `PARA_ROOT`.
2. The folders to create.
3. The templates to copy, each with the changes «Templates» makes to it.
   In scenario B, here: the moves, the projects, `IGNORE`, the held duplicates and the
   links that will break («Scenario B», «The plan's B part»).
4. The config: every key of `vault.md` and `areas.md` with its value; for `mcp`, the
   adapter table (`mcp-generic.md` step 7 — the plan's «yes» is that table's «yes»).
5. `CLAUDE.md`, `.claude/settings.json`, `.obsidian/app.json`, `.obsidian/templates.json`:
   what is added to each. **Each existing value that would change is a line of its
   own**, showing the old and the new value.
6. The probe result: the backend answered (with the inbox count), or `files`.
7. What will not be done, and why (a template already present, a value kept).

## Step 4 — Snapshot (B and C only)

Before applying a plan that touches an existing vault, offer a zip copy next to it —
always asked, refusal accepted, an answer given in advance taken. It is asked in the same
message as the plan's approval (the `init.snapshot` string), so the user answers once:

```bash
zip_path="$(dirname "$REPO_ROOT")/$(basename "$REPO_ROOT")-backup-$(date +%Y-%m-%d).zip"
ditto -c -k --keepParent "$REPO_ROOT" "$zip_path"
```

Scenario A has nothing to save and skips this step.

## Step 5 — Apply

In this order, each step create-when-missing / merge-when-present:

1. Folders — `mkdir -p` each, quoted.
2. Templates («Templates»).
   - Scenario B: then the moves and the projects («Scenario B», «B4»).
     They need the folders and `Templates/Project.md` in place, and they come before
     anything is written outside the PARA folders.
3. Obsidian settings («Obsidian»).
4. `.claude/settings.json` («Settings»).
5. `CLAUDE.md` («CLAUDE.md»).
6. `areas.md`; `adapter.md` for `mcp` (`mcp-generic.md` step 8).
7. `vault.md` — last.

Config files are written from `config.example/<file>`, keeping its title, its «Keys»
table and every section after it, and dropping the paragraphs addressed to someone
filling in the form (the one opening with bold «Vault-specific», and «Fill this in from
scratch»). In the table, every *italic placeholder* is replaced by the value **in
backticks** — ``| `LANG` | `en` |`` — and an empty value leaves the cell empty
(`IGNORE` in scenario A, `GROUPS` under `GROUPING = none`); a list is the backticked
items separated by commas. `REPO_ROOT` is the absolute path, no `~`. `SCHEMA` is the
current one from `migrations.md`.

A step that fails is reported as it is, and the steps after it still run. When a PARA
folder or a template could not be written, the vault is not there: **skip `areas.md`,
`adapter.md` and `vault.md`** (no config without a vault), report it, and the next run
starts over as a first run. Any other failure (`areas.md`, `adapter.md`, a merge into
`CLAUDE.md`, `.claude/settings.json` or `.obsidian/`) does not hold `vault.md` back: the
report names it, the skills stop on a missing `areas.md` or `adapter.md` by themselves,
and the next run fills the gap. Writes into `.claude/` may need the user's permission; a
refusal is a failure like any other, reported and never worked around.

## Step 6 — Report

Headed by the `init.report.heading` string: what was created or changed, as short paths.
Then the `init.report.skipped` string and what was not done, each with its reason (a
template kept because it was already there, an Obsidian value the user kept, a backend
that did not answer). In scenario B, also the B part of the report («Scenario B»).
End with one line on what to try next: `/para:inbox add …`,
`/para:vault-lint`. When `TASKS` has an app behind it, say that `init` did not create
the `AREA_TASK_PROJECTS` projects in it — the user creates them when first needed.

---

## The pieces

### Templates

Copy each file of `templates/<LANG>/` into `PARA_ROOT/Templates/` **only when that file
is missing there**. A template already present belongs to the vault — the vault's
`Templates/` is what `note-format.md` reads, and the user may have edited it — and is
never replaced, except by a migration (`migrations.md`). Changes made while copying, so
that the copy matches the schema of this vault (`note-format.md` «Frontmatter schema»):

- `Task.md` — copied only when `TASKS` is `files`. Under any other backend a task
  template contradicts «`Tasks/` is legacy» (`note-format.md`).
- `Area.md` — the seed's grouping key `sphere:` is renamed to the `GROUPING` field
  name; with `GROUPING = none` the line is removed.
- `Project.md` — with `GROUPING = none` the `area:` line is removed; under
  `pairing: none` (the adapter's, `tasks.md` «Pairing») the `tasks_ref:` line is removed.

Nothing else in a template changes.

### Obsidian

`.obsidian/` sits in `REPO_ROOT` (`paths.md`). Merge — read the file, set only the keys
below, keep every other key and value, write valid JSON; create the file (and the
folder) when missing. A file that is not plain JSON (comments, trailing commas, a
syntax error) is not touched: report it, as with unbalanced `CLAUDE.md` markers.

| File | Key | Value |
|---|---|---|
| `app.json` | `newFileLocation` | `"folder"` |
| `app.json` | `newFileFolderPath` | `"<PARA_DIR>/Inbox"`, or `"Inbox"` when `PARA_DIR` is `.` (`paths.md`) |
| `app.json` | `alwaysUpdateLinks` | `true` |
| `app.json` | `userIgnoreFilters` | contains `"CLAUDE.md"` — appended, other entries kept |
| `templates.json` | `folder` | `"<PARA_DIR>/Templates"`, or `"Templates"` when `PARA_DIR` is `.` |

A key already holding a different value is a plan line of its own (old → new). If the
user keeps the old value, keep it and say in the report what follows from it (new files
from Obsidian land elsewhere; links stop updating on rename).

### Settings

Merge into `REPO_ROOT/.claude/settings.json` — never replace it; a file that is not
plain JSON is not touched and is reported, as in «Obsidian». Add each of these to
`permissions.allow` when it is not there yet, keeping every other key and entry. They
are the permissions the skills use (inspection commands; `sed` is among them because
the skills use it to read, never with `-i`):

`Bash(find:*)`, `Bash(grep:*)`, `Bash(stat:*)`, `Bash(cat:*)`, `Bash(ls:*)`,
`Bash(sed:*)`, `Bash(head:*)`, `Bash(tail:*)`, `Bash(sort:*)`, `Bash(uniq:*)`,
`Bash(wc:*)`, `Bash(diff:*)`, `Bash(basename:*)`, `Bash(date:*)`, `Bash(tr:*)`

Nothing else in the file is touched: no permission is removed, none that writes is added.

### CLAUDE.md

The block is the text from `<!-- para:begin -->` to `<!-- para:end -->` in
`claude-md-block.md`, both markers included, verbatim.

- No `CLAUDE.md` → create it holding the block.
- `CLAUDE.md` without the markers → append a blank line and the block at the end.
- The markers present once each, the text between them identical → nothing to do.
- The markers present, the text differs → a plan line of its own (Tier 2): replace what
  is between them. Everything outside the markers is never touched.
- A marker missing its pair, or present twice → touch nothing; report it.

---

## Re-run and migration

`vault.md` exists. The config is never overwritten, and its questions are not asked
again: their answers are in it.

1. **Read `vault.md`.** Compare its `REPO_ROOT` with this folder, both resolved
   (`pwd -P`, and `cd "<value>" && pwd -P`), so a symlink or a `/private` prefix is not
   a move. If they differ, the vault has moved: a plan line of its own (Tier 2) to
   update that one key.
2. **Compare `SCHEMA`** with `migrations.md`. Higher → stop, as `paths.md` «Schema
   version» says. Lower or missing → the steps `migrations.md` lists for each version up
   to the current one join the plan, run as it says.
3. **Check every piece** of «Step 5» against the disk with the stored values: missing
   folders, missing templates (`Task.md` only under `files`), `areas.md` (missing → ask
   question 4 only), `adapter.md` under `mcp` (missing → the `mcp-generic.md` procedure),
   the Obsidian keys, the permissions, the `CLAUDE.md` block. Only what is missing or
   different joins the plan.
4. **Probe** the backend (read-only, as in Step 2) and say the result; a failure is
   reported and changes nothing in the config.
5. An answer given in advance that disagrees with `vault.md` is not applied: say which
   value the vault keeps, and that changing it is an edit to `vault.md`, not a re-run.
   A Tier 2 line the user declined on an earlier run (an Obsidian value, the
   `CLAUDE.md` block) is shown again, once per run, as a plan line; declined again, the
   report says the old value was kept.
6. **A re-run never sorts notes again.** Scenario B happens once, on the first run:
   the `IGNORE` list, the folders the user left as they are and anything added since
   are not reclassified, and the sorting answers in `$ARGUMENTS` are not used. Notes
   outside the PARA folders are `/para:vault-lint`'s to report.
7. **Nothing missing** → say the `init.nothing_to_do` string and stop. Write nothing — not
   even a file rewritten with the same content.
8. Otherwise the plan, the «yes», the application and the report, as on a first run.

---

## Scenario A — an empty folder

Steps 2, 3, 5 and 6 as above, with `PARA_DIR` defaulting to `PARA`. Every file and
folder is new, so the plan is additions only (an approval given in advance applies),
except where an existing `.obsidian/` or `CLAUDE.md` holds a different value.

## Scenario B — an existing Obsidian vault

The folder holds notes this plugin did not write. `init` sorts what is obvious into PARA
itself, asks about what is disputed — in groups — and moves; nothing else. Steps 2–6
run as above, with the additions below. `PARA_DIR` defaults to `.`.

**The rule over everything else: a note is never changed.** Not its body, not its
frontmatter, not its name, and none is deleted — `note-format.md` «Notes predating the
convention». Checkboxes are left as they are. The only thing done to a user's note or
folder is a plain move (`move.md`), only of what the approved plan lists, never onto an
existing path. Everything `init` writes is a new file: the PARA folders, the templates,
the project overviews, the config.

### A vault with nothing to sort

A new Obsidian vault holds one note, Obsidian's own `Welcome.md`, at its top level. When
that is the only note found, there is nothing to sort: say so, and run scenario A
(`PARA_DIR` defaulting to `PARA`, no snapshot) with one more plan line — `Welcome.md`
stays where it is and joins `IGNORE`. The user may delete it instead; `init` does not.

### B1 — Survey

Read-only, before the setup questions, so that question 2's default is known.

```bash
# the units: every top-level entry but the dot-entries and the repository's own files
find "$REPO_ROOT" -mindepth 1 -maxdepth 1 ! -name '.*' \
  ! -name CLAUDE.md ! -name README.md ! -name CHANGELOG.md | sort
# every file outside the dot-entries, with its mtime: counts per folder, newest change
find "$REPO_ROOT" -mindepth 1 -name '.*' -prune -o -type f -exec stat -f '%m %N' {} +
# what Obsidian says: the attachments, daily-notes and templates folders
cat "$REPO_ROOT/.obsidian/app.json" "$REPO_ROOT/.obsidian/daily-notes.json" \
    "$REPO_ROOT/.obsidian/templates.json" 2>/dev/null
# notes with checkboxes; notes with an unticked one
find "$REPO_ROOT" -mindepth 1 -name '.*' -prune -o -type f -name '*.md' -print0 \
  | xargs -0 grep -lE '^[[:space:]]*[-*+] \[[ xX]\]' /dev/null
find "$REPO_ROOT" -mindepth 1 -name '.*' -prune -o -type f -name '*.md' -print0 \
  | xargs -0 grep -lE '^[[:space:]]*[-*+] \[ \]' /dev/null
# basenames that occur more than once
find "$REPO_ROOT" -mindepth 1 -name '.*' -prune -o -type f -name '*.md' -print \
  | sed 's|.*/||' | LC_ALL=C sort | LC_ALL=C uniq -d
# links that carry a path: wikilinks and embeds with a folder in them, markdown links
find "$REPO_ROOT" -mindepth 1 -name '.*' -prune -o -type f -name '*.md' -print0 \
  | xargs -0 grep -nHoE '!?\[\[[^]|#]*/[^]]*\]\]|\]\([^)]+\)' /dev/null \
  | grep -vE '\]\((https?|mailto|obsidian|file):|\]\(#'
```

**The PARA folders already there.** When `REPO_ROOT` already has a folder named like a
PARA folder (`Projects`, `Areas`, `Resources`, `Archive`, `Inbox`, `Templates`), `.`
would pour the user's folder into PARA's: the default `PARA_DIR` is then `PARA`, and
question 2 says why. If `PARA` exists too, question 2 has no default. With `PARA_DIR`
a subfolder, every destination below is under `PARA_ROOT` as usual.

### B2 — Classify

**The unit is a folder, not a note.** Each top-level folder is one unit with everything
under it. A folder one rule below decides as a whole moves as one. A **mixed** folder —
its notes do not all fall under one rule — is split once: the notes directly in it that a
rule decides go their own way, one by one; the rest of it (its other notes and its
subfolders) is one disputed unit. Each note at the top level is a unit of its own.
Non-note files at the top level stay and join `IGNORE`.

The rules, first match wins:

| # | Unit | Signs | Goes |
|---|---|---|---|
| 1 | daily notes | the `folder` of `.obsidian/daily-notes.json`; or notes named by date (`2026-09-01.md`) | stays, `IGNORE` |
| 2 | attachments | the `attachmentFolderPath` of `.obsidian/app.json`; or a folder of files with no note in it | stays, `IGNORE` |
| 3 | the user's Obsidian templates | the `folder` of `.obsidian/templates.json`; or notes made of `{{date}}`, `{{title}}` placeholders | stays, `IGNORE` — never mixed into the plugin's `Templates/` |
| 4 | reference | named as one (reference, cheat sheet, glossary, how-to, wiki — in any language), or reading as one: commands, definitions, links, quotes; no unticked checkbox, no date ahead | `Resources/<name>` |
| 5 | finished | its newest file untouched for longer than the area-staleness threshold (`thresholds.md`), and no sign of active work: no unticked checkbox, no date from today on | `Archive/<name>` |
| 6 | anything else | — | disputed: asked (B3) |

- A folder that reads as a project — a goal, an end, open checkboxes — is never obvious:
  it becomes a project only on the user's «yes» (rule 6).
- When every file's mtime falls inside one hour (a copy or a sync — `thresholds.md`
  «The limit of mtime»), rule 5 decides nothing: those units are asked.
- **Duplicates come before the rules.** Every note whose basename occurs more than once
  across `REPO_ROOT` stays where it is and is in no move, whatever its folder does: a
  folder that moves while holding one is moved entry by entry around it, and stays
  behind holding it (B4). The duplicates are asked about (B3). This is `move.md`: a
  move is safe only while the basename is unique.
- **Collisions.** A destination that already exists, or a project overview name that
  already exists anywhere under `REPO_ROOT` (`note-format.md` «Name collisions»), holds
  that unit: it is asked about, with the reason, and never moved onto.

### B3 — Questions

After the setup questions, **one message** with every disputed unit, numbered:

1. the folders, largest first (by notes), each as the `init.b.question` string, with what
   helps to answer — how long it has been unchanged (the span, never a verdict:
   `thresholds.md`), two or three note names, how many notes carry checkboxes, and
   `init`'s guess when it has one;
2. the top-level notes, one line each, with the same choices;
3. the duplicates: the `init.b.duplicates` string, each name with all its paths, and the
   `init.b.duplicates_choice` string.

The user answers them all in one reply. **Never one question per note inside a folder**
— a flood of questions is as unpredictable as silent decisions. If the user wants a
folder split, they say how; `init` never proposes it note by note. Answers:

- **project** → «Projects» below.
- **area** → `Areas/<name>`; when `GROUPING` is not `none`, under the group the user
  names, `Areas/<GROUP>/<name>` (Tier 1.5 if not named). The notes move as they are; no
  area note is written for them — the report suggests `/para:areas create`.
- **resource** → `Resources/<name>`; **archive** → `Archive/<name>`.
- **leave as is** (`init.b.leave`) → stays, joins `IGNORE`.
- **duplicates, leave** → every copy stays and its path joins `IGNORE` — or, for a copy
  left behind in a folder that otherwise moved, that folder's path, since the copy is all
  it still holds (otherwise `/para:vault-lint` reports the folder as stray); say that
  `/para:vault-lint` keeps reporting the name until one is renamed (`paths.md` «IGNORE»).
  **Duplicates, stop** → stop the whole run: nothing is written, and the next run is a
  first run again. `init` never renames a note itself.

### Projects

A folder becomes a project only on the user's «yes» for that folder. Then:

- the id is issued per `project-id.md`, one per project in plan order;
- the title is the folder's name, cleaned as `note-format.md` «Title and filename» says;
  `short` is proposed in the plan (`note-format.md` «Filling fields»);
- the new folder is `Projects/PROJ-xxxx <title>/` with `Notes/`, `Resources/`, `Results/`
  (`paths.md` «Map»). Every entry of the old folder moves into `Notes/` as it is —
  subfolders and attachments too — except a held duplicate. The emptied old folder is
  removed with `rmdir`, which refuses one that is not empty; never `rm -r`;
- the overview `PROJ-xxxx <title>.md` is written from the vault's
  `Templates/Project.md` (copied in Step 5.2 of this run, or the vault's own) per
  `note-format.md`: title, `short`, id, the tag slug, `created` today. Every other field
  and section stays blank — `init` adopts a folder and does not invent a goal;
- `project.create` runs only under `pairing: separate` (`tasks.md` «Pairing»), and its
  id goes into the new overview's `tasks_ref`. A failed call leaves the project
  unpaired and is reported (`tasks.md` «Backend missing»).

### The plan's B part

At the plan's item 3, each block headed by its string:

- `init.b.moves` — one line per move, `from → to`, grouped by destination; a folder
  moved whole is one line; a folder moved around a held duplicate says what stays.
  A project line names the new folder, its id, its `short` and the overview. Then the
  totals: moves, notes moved.
- `init.b.ignore` — every path that joins `IGNORE`, each with why.
- `init.b.duplicates` — the names, their paths, the answer.
- `init.b.links` — every link the moves break: the note, the line, the link. A link
  breaks when its target moves, or when it is a relative markdown link and its note
  moves while its target does not (a link inside a folder that moves whole keeps
  working). Resolve a wikilink's path from `REPO_ROOT`, a markdown link's (`%20` is a
  space) from its note's folder, then from `REPO_ROOT`. «None» when there are none.

### B4 — Applying the B part

At Step 5.2, line by line in plan order. Each move checks first and never forces:

```bash
src="$REPO_ROOT/<from>"; dest="$PARA_ROOT/<to>"
if [ -e "$dest" ]; then echo "exists, not moved: $dest"
elif [ ! -e "$src" ]; then echo "gone, not moved: $src"
else mkdir -p "$(dirname "$dest")" && mv "$src" "$dest"; fi
```

A folder holding a held duplicate is moved entry by entry: `mkdir -p "$dest"`, then the
same check and `mv` for each entry of `find "$src" -mindepth 1 -maxdepth 1`, skipping the
duplicate (and descending into the subfolder that holds it, if it is deeper).

Then check that nothing was lost: every note the survey found is at its old path or at
its planned new one, and the number of notes outside the dot-entries is the survey's
count plus the files `init` created:

```bash
find "$REPO_ROOT" -mindepth 1 -name '.*' -prune -o -type f -name '*.md' -print | wc -l
```

A mismatch is reported first in the report, with the paths. The `IGNORE` entries go
into `vault.md` at Step 5.7: paths relative to `REPO_ROOT`, as `paths.md` «IGNORE»
spells the value.

### The report's B part

- what moved: the count per destination, the projects with their ids;
- what stays (`IGNORE`), and the duplicates left in place;
- the `init.b.links` list again — these links are broken now;
- the `init.b.checkboxes` string with the count, and the folders those notes sit in;
- the snapshot's path, if one was made.

## Scenario C — a vault with the old embedded tooling

**Not supported by this version yet.** Name the scenario, say that it is not supported
yet and that nothing was changed, and stop. (Planned: moving the old config into
`.claude/para/`, renaming the pair field to `tasks_ref`, the snapshot, retiring the
embedded skills.)
