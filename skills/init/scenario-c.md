# Scenario C — the old embedded tooling

Read by `/para:init` only, and only once it has named scenario C (`SKILL.md` Step 1) or
found leftovers of it on a re-run. It is the one file in the plugin that describes the
old layout, so it is exempt from the checks that keep old paths out of the skills and the
base layer (`tests/check.sh`).

**Narrow and one-off.** C migrates a vault built from the old PARA vault template at its
last version — the one that moved tasks into Todoist. There is no version detection and
no support for hand edits to the old shared layer: what is described here is what C
expects to find, and anything else is reported, never guessed.

`SKILL.md`'s rules for the whole run hold here too: nothing is written before the
plan's «yes», `vault.md` is the last config written, every step is idempotent, every
path is quoted. `SKILL_DIR` is this skill's base directory.

## The old layout

| Path under `REPO_ROOT` | What it is | C does |
|---|---|---|
| `.claude/para/local/roots.md` | the old `REPO_ROOT` | values into `vault.md`; then to the Trash, last |
| `.claude/para/local/areas.md` | the old Areas model, with `TODOIST_AREA_PROJECTS` | values into `areas.md`; then to the Trash, last |
| `.claude/para/local.example/` | blank copies of the two | to the Trash |
| `.claude/para/<name>.md` — every `.md` directly in `.claude/para/` except `vault.md`, `areas.md`, `adapter.md` | the old base layer (`paths`, `find-target`, `confirm`, `note-format`, `move`, `project-id`, `dod`, `todoist`, `thresholds`) | planning lifted out («Planning»), then to the Trash |
| `.claude/skills/<s>/` for `inbox`, `projects`, `areas`, `resources`, `archive`, `remove`, `vault-lint` | the old embedded skills | to the Trash |
| `CLAUDE.md` | the old one — it names `.claude/para/local/roots.md` | to the Trash, replaced («CLAUDE.md») |
| `README.md` whose first line is `# PARA vault template`; `CHANGELOG.md` that names `.claude/para/local/` | the old template's docs; their content lives in the plugin's repository now | to the Trash. Any other `README.md` or `CHANGELOG.md` is the user's and is not touched |

The old layout's fixed values: `PARA_DIR` is `Second-brain` (its `roots.md` says the name
is not configurable), `LANG` is `ru` (the old tooling wrote Russian only), `TASKS` is
`todoist`.

**Left alone**, and named in the plan's «not done»: `.claude/specs/`, `.claude/plans/`,
`.claude/settings.local.json`, every other folder in `.claude/skills/`, every other
dot-entry of `REPO_ROOT`, the vault's `Templates/` except the one line «Plan» item 3b
names, and every note except the one frontmatter key «Plan» item 3a names.

## C1 — Inspect

Read-only. After this step `LANG` is `ru`: everything from here on is in it, the plan
and report headed by the `init.*` strings.

```bash
REPO_ROOT=$(pwd); PARA_ROOT="$REPO_ROOT/Second-brain"
cat "$REPO_ROOT/.claude/para/local/roots.md" "$REPO_ROOT/.claude/para/local/areas.md"
ls -A "$REPO_ROOT/.claude/para" "$REPO_ROOT/.claude/para/local.example" "$REPO_ROOT/.claude/skills"
# the overviews: one per PROJ- folder under Projects/ and Archive/, and the old key inside
# the frontmatter only (from the first line `---` to the next `---`)
for d in "$PARA_ROOT/Projects"/PROJ-* "$PARA_ROOT/Archive"/PROJ-*; do
  f="$d/$(basename "$d").md"; [ -f "$f" ] || continue
  awk -v f="$f" 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {exit}
    fm && /^todoist:/ {print f ":" NR ": " $0}' "$f"
done
awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {exit} fm && /^todoist:/ {print FILENAME ":" NR}' \
  "$PARA_ROOT/Templates/Project.md"
head -1 "$REPO_ROOT/README.md" 2>/dev/null; grep -l '\.claude/para/local/' "$REPO_ROOT/CHANGELOG.md" 2>/dev/null
# the sections the planning file is built from
grep -nE '^#{2,3} ' "$REPO_ROOT/.claude/para/todoist.md" "$REPO_ROOT/.claude/para/thresholds.md"
grep -n 'exception' "$REPO_ROOT/.claude/para/confirm.md"
# the plugin enabled at project level
grep -n '"para@' "$REPO_ROOT/.claude/settings.json" 2>/dev/null
```

Then compare the `REPO_ROOT` of `roots.md` with this folder, both resolved (`pwd -P`). A
difference is said in the plan: `vault.md` takes this folder, as `SKILL.md` «Rules for
the whole run» says, and the old value goes to the Trash with `roots.md`.

`local/areas.md` missing → ask `SKILL.md` question 4, the one setup question C may ask.
Any other piece of the table above missing is no error: there is nothing to do for it.

## C2 — Values and the probe

No setup question is asked. `vault.md`: `REPO_ROOT` this folder, `PARA_DIR`
`Second-brain`, `LANG` `ru`, `TASKS` `todoist`, `SCHEMA` the current one
(`migrations.md`), `IGNORE` empty. `areas.md`: every key of `local/areas.md` with its
cell **as it is**, except that `TODOIST_AREA_PROJECTS` becomes `AREA_TASK_PROJECTS`.
An `areas.md` already in `.claude/para/` — an earlier C run that stopped at C4's gate —
is the vault's config: kept, never rewritten, and the plan says so.

Probe the backend as `SKILL.md` «Probing the backend» says (`inbox.list`, read-only, the
count only). **A failed probe does not change `TASKS` here** — C's one exception to «a
value whose probe failed is never recorded»: the value is inherited, not chosen, and the
overviews already hold its project ids, so recording another backend would orphan every
pair. The plan and the report say that the probe failed and that the skills will stop
with «Backend missing» (`tasks.md`) until the app is connected.

## C3 — The plan

`SKILL.md` Step 3, in its order, with these lines:

1. `REPO_ROOT`, `PARA_ROOT`; the old `REPO_ROOT` if it differs.
2. Folders missing (normally none).
3. Templates missing (`Task.md` is not copied under `todoist`), then:
   - **a.** one line per overview: `<path>: todoist: "<id>" → tasks_ref: "<id>"` — the key
     only, the value unchanged, `Projects/` and `Archive/` alike. Tier 1 (`confirm.md`:
     editing a frontmatter field). The total is the number of lines C1 printed.
   - **b.** `Templates/Project.md`: `todoist:` → `tasks_ref:`, a line of its own and Tier 2
     (`migrations.md`: a template is never changed silently). Declined, the template
     keeps the old key: new projects carry it, the skills read it as `tasks_ref`
     (`note-format.md`) and `/para:vault-lint` reports it.
   - **c.** `.claude/local/planning.md`, new: its sections and where each comes from
     («Planning»). Already there → kept, not rewritten.
   - **d.** to the Trash — Tier 2 — every path the table above sends there, one line
     each (the seven skills may share a line), with `local/` marked «after `vault.md`».
     They go to the macOS Trash (`move.md`) and can be put back from it.
4. The config: every key of `vault.md` and `areas.md` with its value.
5. `CLAUDE.md` replaced — Tier 2 («CLAUDE.md»); `.claude/settings.json` and `.obsidian/`
   per `SKILL.md` «Settings», «Obsidian» (normally only the missing permissions); and
   the plugin's enablement («Plugin enabled»).
6. The probe result.
7. Not done: the «Left alone» list, and anything C1 found missing.

The plan always holds Tier 2 lines (3b, 3d, 5), so **C always waits for a «yes»**, even
with an approval given in advance (`SKILL.md` «Answers given in advance»). The snapshot
is offered in the same message (`SKILL.md` Step 4). The user may decline single lines —
keep the README, keep the template — which makes a new plan, shown again.

## C4 — Apply

In this order, after the «yes» (and the snapshot, if asked for). The new config goes in
**before** anything of the old tooling goes out: the one state C must never leave behind
is a vault with neither the old config nor the new one.

1. Folders and templates missing (`SKILL.md` Step 5.1–5.2).
2. `.claude/local/planning.md` («Planning»), when missing.
3. `.obsidian/`, `.claude/settings.json` (`SKILL.md` Step 5.3–5.4).
4. `areas.md`, then `vault.md`, from `config.example/` as `SKILL.md` Step 5 says.
5. **Gate.** `planning.md` (when the plan wrote it), `areas.md` and `vault.md` must now be
   on disk. If one is not — a write into `.claude/` refused, say — **stop here**: no key
   renamed, nothing to the Trash, `CLAUDE.md` untouched. The old tooling keeps working
   as it did; the report names what failed, and the next run picks up from there
   («Leftovers on a re-run»). A refusal is reported, never worked around.
6. The overview renames (3a), then the template (3b) if approved. One file at a time,
   the key inside the frontmatter only, the file's mtime kept (staleness falls back to
   mtime, `thresholds.md`, so a rename must not make every project look fresh):

   ```bash
   f="<overview>"; t="$f.para-tmp"
   awk 'NR==1 && $0=="---" {fm=1; print; next} fm && $0=="---" {fm=0}
     fm && /^todoist:/ {sub(/^todoist:/, "tasks_ref:")} {print}' "$f" > "$t" \
     && [ "$(diff "$f" "$t" | grep -c '^[<>]')" = 2 ] && touch -r "$f" "$t" && mv "$t" "$f" \
     || { rm -f "$t"; echo "not renamed: $f"; }
   ```

   The `diff` guard lets exactly one changed line through; anything else leaves the file
   as it was and is reported.
7. The Trash (3d), except `CLAUDE.md` and `local/`: `trash "<path>"` for each, quoted.
   Then `rmdir` `.claude/skills` if it is empty — never `rm -r`. `trash` missing or
   failing is reported, never replaced by `rm` (`move.md`).
8. `CLAUDE.md`: the old one to the Trash, the new one written («CLAUDE.md»).
9. `local/` to the Trash, last.

Every other failure follows `SKILL.md` Step 5: reported, and the steps after it still run.

## C5 — Report

`SKILL.md` Step 6, plus: the overviews renamed (counted again from the disk: no
frontmatter `todoist:` left under `Projects/` and `Archive/`), the template, the
planning file, every path now in the Trash, what was left alone, the probe, the
plugin's enablement if missing. End with: run `/para:vault-lint` and compare it with a
run from before the migration — the only new differences should be the renamed key and
the scheduled count that replaced the old planning count.

## Leftovers on a re-run

On a re-run (`vault.md` exists) `SKILL.md` «Re-run and migration» step 3 looks for what
C leaves when interrupted or partly declined: a path of the old layout still there, an
overview or `Templates/Project.md` still carrying a frontmatter `todoist:` key, a missing
`.claude/local/planning.md` while the old `todoist.md` is still there to lift it from.
Each joins the plan as the C3 line it is; a Tier 2 line the user declined is shown again
once per run, as `SKILL.md` says. Nothing found → nothing to do.

## Plugin enabled

`init` runs inside the plugin, so it is installed for this session — but C checks that
the vault enables it **at project level**: an `enabledPlugins` entry `para@<marketplace>`
set to `true` in `.claude/settings.json`. `init` never writes `enabledPlugins` or
`extraKnownMarketplaces` itself: they name where the plugin comes from, which is the
user's choice. Missing → a «not done» line saying how, from `REPO_ROOT`:
`claude plugin marketplace add <the plugin's repository or folder> --scope project`, then
`claude plugin install para@<marketplace> --scope project`.

## CLAUDE.md

The new file is the vault's local part, a blank line, then the block exactly as
`SKILL.md` «CLAUDE.md» takes it. The local part is in English, like the old file:

- the old title and its first paragraph, and the old «What This Is» section as it is;
- **This vault** — `REPO_ROOT` is this folder, `PARA_ROOT` is `REPO_ROOT/Second-brain`;
  the config is in `.claude/para/`; notes and chat are in Russian (`LANG`);
- **Planning** — the old file's planning sentence, its trigger phrases kept, now pointing
  at `.claude/local/planning.md` instead of the old base layer;
- **Where the PARA skills come from** — «The PARA skills come from the `para` plugin,
  enabled at project level. Change them in the plugin's repository, never in the plugin
  cache and never as copies in `.claude/skills/`. Other skills of this vault stay in
  `.claude/skills/`.»

Nothing else of the old file is kept: the rest of it described the old tooling.

## Planning

`REPO_ROOT/.claude/local/planning.md` belongs to the vault, not to the plugin: no skill
reads it, and the local part of `CLAUDE.md` points at it. It is **lifted, not
rewritten**: the old text is copied as it is — English rules, the old Russian examples,
the user's numbers, the name of the user's schedule note — and only the references
change. It builds on the plugin's task contract and adapter and restates neither.

Sections, in this order:

| Section of `planning.md` | Lifted from (old base layer) |
|---|---|
| title and a header paragraph | new: what the file is; that it builds on the `para` plugin's `para/tasks.md` (operations, what a task is, the fields and the date rule, the research task) and `para/adapters/todoist.md`, and restates neither |
| the schedule | `todoist.md`: the paragraph naming the user's note that holds the schedule; `thresholds.md`: the section on where the hours live |
| numbers | `thresholds.md`: the table of the anchor, the length and the planned share, values verbatim, with the sentence after it |
| the planning period | `todoist.md`: its section on the period and when a task is in it; and the planning sentences of the shared sections — the waiting project kept in the period by its check task (the task itself is `tasks.md`'s), area tasks spending the same hours, the duration, date and time rows of the fields table, and the paragraph on task types |
| counts | `thresholds.md` «Task counts»: the count of tasks inside the current period — the plugin reports the scheduled count (`count.scheduled`) instead, so planning computes this one itself |
| plan vs fact | `todoist.md`, its section of that name |
| writing dates | `todoist.md` «Writing to Todoist»: the lines on giving, moving, timing and removing a date, verbatim; the line on moving a task between projects → «per the adapter's `task.move`»; the line on new tasks → «`task.add`, `tasks.md`» |
| the planning exception | `confirm.md`: its named planning exception, verbatim |
| the rhythms | `todoist.md`: the section listing them and every subsection, verbatim |

References change as follows and nothing else is rephrased: a section of the old
`thresholds.md` or `todoist.md` that was lifted → that section of this file; one that was
not → the plugin's file that owns it now (`thresholds.md`, `tasks.md`, the adapter);
the old `confirm.md` exception → this file's; `local/areas.md` → `.claude/para/areas.md`;
`TODOIST_AREA_PROJECTS` → `AREA_TASK_PROJECTS`. An old section that is missing is named
in the plan and the report, never invented.
