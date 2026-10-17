# para

A Claude Code plugin that carries the skills for an Obsidian PARA vault.

Work in progress.

## Layout

- `skills/` — one `SKILL.md` per command (`inbox`, `projects`, `areas`, `resources`, `archive`, `remove`, `vault-lint`).
- `para/` — the shared base layer. A skill reads `../../para/<file>.md` relative to its own base directory. `para/tasks.md` is the backend-neutral task contract; `para/adapters/` holds one adapter per backend (`todoist.md`, `files.md`).
- `config.example/` — templates for the vault's own config, which lives in the vault at `.claude/para/` (`vault.md`, `areas.md`).
- `lang/<LANG>.md` — every fixed string the skills write to a note or print to chat (`ru` and `en` ship), the same keys in every file; `LANG` in the vault's `vault.md` picks the file.
- `templates/<LANG>/` — seed note templates (`Project`, `Area`, `Resource`, `Note`, and `Task` for `TASKS = files`); the vault's own `Templates/` is the source of truth.
- `evals/` — `claude plugin eval` cases; `evals/fixtures/legacy/` and `evals/fixtures/files/` (`TASKS = files`) are synthetic vaults staged under a directory whose name contains a space.

## Tests

```bash
tests/check.sh    # static checks over skills/, para/, lang/ and templates/
claude plugin eval . --scaffold --trust-plugin --allow-tools Bash Write Edit --max-cost-usd 3 --ablation none
```

The eval child has no claude.ai connectors, so the Todoist-backed cases assert only behaviour that does not need a task app; the `files-*` cases run end to end.
