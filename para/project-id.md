# Issuing a PROJ id

Every project carries a unique `id: PROJ-xxxx`, zero-padded to four digits, issued once
at creation and never changed. Read `paths.md` first.

## The invariant

**An id is never reused.** Notes, tasks and archived projects refer to projects by id;
handing the same id to a second project turns those references into quiet lies rather
than visible broken links.

Archiving preserves this by itself — the folder stays in the vault. Deletion does not,
which is why deletion writes to the journal below.

## Issuing the next id

The highest id currently spoken for is the maximum across three sources:

1. `Projects/` — the `id:` field in each project's overview frontmatter
2. `Archive/` — likewise
3. `Archive/.removed-ids` — ids of deleted projects

```bash
{ grep -rhoE 'PROJ-[0-9]{4}' "$PARA_ROOT/Projects" "$PARA_ROOT/Archive" \
    --include='*.md' 2>/dev/null
  grep -ohE 'PROJ-[0-9]{4}' "$PARA_ROOT/Archive/.removed-ids" 2>/dev/null
} | sort | tail -1
```

The journal's header line (below) spells the format as `PROJ-xxxx`, which this pattern
does not match — that is intentional, so the header can never be mistaken for a retired
id.

Add 1 to the number, zero-pad to four digits. No hits at all → `PROJ-0001`.

The `id` field in frontmatter is the source of truth, not the folder name prefix. Old
archived projects have neither (`Old project`); they were never issued an id and
do not affect the count.

## The journal

`Archive/.removed-ids` — a header line, then one line per deleted project, appended by
`/remove`. The header is exactly this line, the one statement of it:

```
# Ids of deleted projects, never to be reused. One per line: PROJ-xxxx  YYYY-MM-DD  title
```

`/para:init` creates the file holding only the header when it is missing; `/remove`
does the same if it is still missing when it appends. An existing file is never
rewritten, header or not. An entry:

```
PROJ-0042  2026-09-12  Title of the deleted project
```

The id in that example is deliberately one no project has ever held. Never copy a
real, live id into this file as an illustration — a literal paste would retire a
project that still exists.

A dotfile, so Obsidian does not show it and it never appears as a note. It is a
tombstone list, not a record worth curating — never edit or prune it, and never
reissue an id found there.
