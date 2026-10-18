# Areas model — local to this vault

**Vault-specific.** Read the values.

## Keys

| Key | Value |
|---|---|
| `GROUPING` | `sphere` — the frontmatter field recording which group a note belongs to. `none` means Areas are not grouped at all. |
| `GROUPS` | `Работа`, `Дом` |
| `PLACEMENT` | `Areas/<GROUP>/<title>.md` |
| `REVIEW_GROUPING` | one block per group, groups with nothing to report dropped |
| `PLACEMENT_CHECK` | a note's `GROUPING` field must name the top-level folder it sits under; a disagreement is a lint finding |
| `TODOIST_AREA_PROJECTS` | `Работа`, `Дом` |

## Shape of `areas review` output

```
## Области

**Работа** — 1 заметка, последняя правка 12 дней назад
```
