# para

A Claude Code plugin that carries the skills for an Obsidian PARA vault.

Work in progress.

## Layout

- `skills/` — one `SKILL.md` per command (`inbox`, `projects`, `areas`, `resources`, `archive`, `remove`, `vault-lint`).
- `para/` — the shared base layer. A skill reads `../../para/<file>.md` relative to its own base directory. `para/tasks.md` is the backend-neutral task contract; `para/adapters/` holds one adapter per backend (`todoist.md` so far).
- `config.example/` — templates for the vault's own config, which lives in the vault at `.claude/para/` (`vault.md`, `areas.md`).
- `evals/` — `claude plugin eval` cases; `evals/fixtures/legacy/` is a synthetic vault staged under a directory whose name contains a space.

## Tests

```bash
tests/check.sh    # static checks over skills/ and para/
claude plugin eval . --scaffold --trust-plugin --allow-tools Bash Write Edit --max-cost-usd 3 --ablation none
```

The eval child has no claude.ai connectors, so the cases assert only behaviour that does not need a task app.
