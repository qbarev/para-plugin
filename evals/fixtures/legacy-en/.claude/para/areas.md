# Areas model

## Keys

| Key | Value |
|---|---|
| `GROUPING` | `sphere` — the frontmatter field recording which group a note belongs to. |
| `GROUPS` | `Work`, `Home` |
| `PLACEMENT` | `Areas/<GROUP>/<title>.md` |
| `REVIEW_GROUPING` | one block per group, groups with nothing to report dropped |
| `PLACEMENT_CHECK` | a note's `GROUPING` field must name the top-level folder it sits under; a disagreement is a lint finding |
| `AREA_TASK_PROJECTS` | `Work`, `Home` |

## Shape of `areas review` output

```
## Areas

**Work** — notes: 1, last edit 12 d ago

**Home** — notes: 1, last edit 3 d ago
```
