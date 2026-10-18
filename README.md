# para

A Claude Code plugin for running an Obsidian vault organised by the PARA method:
Projects, Areas, Resources, Archive. The vault holds the notes; the plugin's skills
operate on them, and tasks live in a task backend of your choice — Todoist, plain notes
in the vault, or any other to-do app connected over MCP.

| Skill | What it does |
|---|---|
| `/para:init` | sets a folder up as a vault, or brings a vault up to date |
| `/para:inbox` | `add <text>` · `list` · `process` — capture into the backend's inbox and route captures into the vault |
| `/para:projects` | `list` · `create <description>` · `overview <project>` · `task <project> <task>` |
| `/para:areas` | `create <name>` · `review` |
| `/para:resources` | `create <link or text>` |
| `/para:archive` | `<what>` · `list` · `restore <what>` |
| `/para:remove` | `<what>` — to the macOS Trash, after an explicit yes |
| `/para:vault-lint` | checks the vault against its schema; read-only unless `--fix` |

macOS only (the skills use `trash` and `stat -f`).

## Install

Add the marketplace and enable the plugin **at project level**, from the vault's root:

```bash
claude plugin marketplace add <this repository or its folder> --scope project
claude plugin install para@para --scope project
```

That records `extraKnownMarketplaces` and `enabledPlugins` in the vault's
`.claude/settings.json`. For development, `claude --plugin-dir <this folder>` loads the
plugin for one session.

## Set up a vault

Start Claude Code in the folder that is (or will be) the vault root and run
`/para:init`. It looks at the folder, asks the setup questions one at a time, shows one
plan of everything it will create or change, and applies it on one «yes».

- **A — an empty folder:** creates the PARA folders and templates and writes the config.
- **B — an existing Obsidian vault:** sorts what is obvious into PARA, asks about the
  rest in groups, and only ever moves notes — never edits one. Daily notes, attachments
  and your own templates stay where they are.
- **C — a vault built from the old PARA vault template** (skills embedded in
  `.claude/skills/`, config in `.claude/para/local/`): moves the config, renames the
  overview key `todoist` to `tasks_ref`, keeps planning in a file of the vault's own,
  and moves the old tooling to the Trash.

A snapshot zip is offered before B and C. Running `/para:init` again fills in what is
missing and migrates an older schema; when nothing is missing it changes nothing.

## What lives where

In the vault, owned by the vault and never overwritten by the plugin:

- `.claude/para/vault.md` — `REPO_ROOT`, `PARA_DIR`, `LANG`, `TASKS`, `SCHEMA`, `IGNORE`;
- `.claude/para/areas.md` — how Areas are grouped; `adapter.md` when `TASKS` is `mcp`;
- `<PARA_DIR>/Templates/` — the note templates the skills read;
- `CLAUDE.md` — the plugin's block between `<!-- para:begin -->` and `<!-- para:end -->`,
  everything else yours.

In the plugin:

- `skills/` — one `SKILL.md` per command; `skills/init/scenario-c.md` is the one file that
  describes the old embedded layout.
- `para/` — the shared base layer every skill reads (`../../para/<file>.md` from its base
  directory): paths, the confirmation tiers, the note format, moves, project ids, the
  Definition of Done, thresholds, migrations. `para/tasks.md` is the backend-neutral task
  contract and `para/adapters/` holds the adapters (`todoist.md`, `files.md`) and the
  procedure that builds one for any other MCP app (`mcp-generic.md`).
- `config.example/` — the forms the vault's config is filled in from.
- `lang/<LANG>.md` — every string that reaches a note or the chat (`ru`, `en`);
  `templates/<LANG>/` — seed templates. A new language is those two and no skill edits.

Planning — sprints, capacity, daily and weekly rhythms — is not part of the plugin. A
vault that plans keeps its rules in a file of its own and points to it from `CLAUDE.md`.

## Tests

```bash
tests/check.sh    # static checks over skills/, para/, lang/ and templates/
claude plugin eval . --scaffold --trust-plugin --allow-tools Bash Write Edit --max-cost-usd 3 --ablation none
```

`PARA_DENYLIST=<file>` adds a check that no listed term appears in a tracked file.

- `evals/fixtures/` holds synthetic vaults: `legacy/` and `files/` (staged by
  `setup.sh` under a directory whose name contains a space), `arbitrary/` (~50 notes for
  scenario B, `stage-arbitrary.sh`), `embedded/` (the old embedded tooling for scenario
  C, `stage-embedded.sh`), and `init-a-done/`, `init-b-done/`, `init-c-done/` — the
  vaults as each scenario left them, for the re-run cases.
- `tests/hash-notes.sh <dir>` prints a hash per note keyed by basename, so notes can be
  compared before and after `/para:init` (a pure move leaves the output unchanged).
- The eval child has no claude.ai connectors, so Todoist-backed cases assert only what
  needs no task app; the `files-*` cases run end to end. It may not write into
  `.claude/`, so the `init-*` cases grade config files by the write the run attempted.
  Scenario C always waits for a «yes» to its Tier 2 lines, so `init-c` grades the plan;
  applying it is checked by hand in a two-turn run.
