# Areas model

How Areas are organised is a decision each vault makes for itself, so every rule that
depends on that decision lives here rather than in a skill. `skills/areas/SKILL.md` keeps the
algorithm; this file supplies the model it runs on.

Read the values. If this file is missing, stop and say so — do not infer a model from
the folders that happen to exist.

## Keys

| Key | Value |
|---|---|
| `GROUPING` | `none` |
| `GROUPS` | |
| `PLACEMENT` | `Areas/<title>.md` |
| `REVIEW_GROUPING` | `one flat list` |
| `PLACEMENT_CHECK` | `none` |
| `AREA_TASK_PROJECTS` | `Areas` |

## Where these values are used

- **`GROUPING` and `GROUPS`** give the allowed values for **two** frontmatter fields,
  not one: the Area field named by `GROUPING`, and `area` on a Project. They share a
  vocabulary deliberately — a project belongs to the same responsibility an area tracks.
  If you rename or drop the field, change the key name in `Templates/Area.md` and
  `Templates/Project.md` to match.
- **`PLACEMENT`** is what `/areas create` follows, and what makes the grouping field one
  that cannot be left blank: it decides where the file goes.
- **`PLACEMENT_CHECK`** is one of `/vault-lint`'s schema checks.
- **`AREA_TASK_PROJECTS`** names the task-app projects that hold tasks belonging to
  no project (`tasks.md`, «Area projects»). They have no folder in `Projects/` and are
  never reported as unpaired.

## Shape of `areas review` output

The output groups by this model, so its shape belongs here too. Render in `LANG`, with
the `areas.review.*` strings of `lang/<LANG>.md` (`areas.review.heading`,
`areas.review.group`, `areas.review.no_notes`, `areas.review.stale`). The names below are
placeholders — replace them along with the keys:

```
## Areas

**Group 1** — notes: 4, last edit 12 d ago
- «Area A» unchanged for 74 d

**Group 2** — no notes
```

With `GROUPING = none` there are no blocks: one flat list of area notes, same lines
underneath.
