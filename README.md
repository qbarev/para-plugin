# para

A Claude Code plugin that carries the skills for an Obsidian PARA vault.

Work in progress.

## Layout

- `skills/` — one `SKILL.md` per command (`init`, `inbox`, `projects`, `areas`, `resources`, `archive`, `remove`, `vault-lint`). `/para:init` sets a folder up as a vault (scenario A, an empty folder; B and C are not supported yet), fills in what is missing on a re-run, and migrates an older `SCHEMA`.
- `para/` — the shared base layer. A skill reads `../../para/<file>.md` relative to its own base directory. `para/tasks.md` is the backend-neutral task contract; `para/adapters/` holds one adapter per backend (`todoist.md`, `files.md`) and the procedure for any other MCP app (`mcp-generic.md`). `para/migrations.md` holds the plugin's `SCHEMA` and what each version migrates; `para/claude-md-block.md` is the block `init` writes into the vault's `CLAUDE.md`.
- `config.example/` — templates for the vault's own config, which lives in the vault at `.claude/para/` (`vault.md`, `areas.md`).
- `lang/<LANG>.md` — every fixed string the skills write to a note or print to chat (`ru` and `en` ship), the same keys in every file; `LANG` in the vault's `vault.md` picks the file.
- `templates/<LANG>/` — seed note templates (`Project`, `Area`, `Resource`, `Note`, and `Task` for `TASKS = files`); the vault's own `Templates/` is the source of truth.
- `evals/` — `claude plugin eval` cases; `evals/fixtures/legacy/` and `evals/fixtures/files/` (`TASKS = files`) are synthetic vaults staged under a directory whose name contains a space; `evals/fixtures/init-a-done/` is a vault as `/para:init` scenario A left it; `evals/fixtures/arbitrary/` is an existing Obsidian vault of ~50 synthetic notes for scenario B, staged by `evals/fixtures/stage-arbitrary.sh`, and `evals/fixtures/init-b-done/` is that vault as scenario B left it. `tests/hash-notes.sh <dir>` prints a hash per note keyed by basename, so a vault's notes can be compared before and after `/para:init` (a pure move leaves the output unchanged).

## Tests

```bash
tests/check.sh    # static checks over skills/, para/, lang/ and templates/
claude plugin eval . --scaffold --trust-plugin --allow-tools Bash Write Edit --max-cost-usd 3 --ablation none
```

The eval child has no claude.ai connectors, so the Todoist-backed cases assert only behaviour that does not need a task app; the `files-*` cases run end to end. The eval child may not write into `.claude/` (the Write tool asks there, and the sandbox refuses `settings.json`), so the `init-*` cases grade the config files by the write the run attempted.
