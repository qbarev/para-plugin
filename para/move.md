# Moving and deleting files

How a file changes place without taking the vault's links down with it. Read `paths.md`
first.

## What actually protects wikilinks

`CLAUDE.md` notes that Obsidian is configured with `alwaysUpdateLinks: true`. That is a
feature of **Obsidian's own rename/move commands**. A skill moving a file with `mv`
bypasses Obsidian entirely, so nothing rewrites anything — do not rely on it, and do not
tell the user their links were updated.

Links survive a filesystem move for a different reason: Obsidian resolves `[[Wikilink]]`
by **filename, not path**. `[[Resource A]]` keeps working wherever that file
sits in the vault.

Two consequences, and they are the whole reason this file exists:

- **A move is safe as long as the basename does not change and stays unique.** Before
  moving, check the destination and the rest of the vault for a file with the same
  basename. Two files named the same make every link to that name ambiguous.
- **A rename or a delete breaks links, and nothing warns you.** Collect the backlinks
  first.

## Collecting backlinks

```bash
grep -rln "\[\[<basename without .md>\]\]" "$PARA_ROOT" --include="*.md"
```

Also match the aliased form `[[Name|text]]` and, for a project, links to its overview
filename including the `PROJ-xxxx ` prefix — that prefix is part of the link target.

Report what points at the file before touching it. For a delete, the user needs this to
answer at all; see `confirm.md`, Tier 2.

## Moving

A plain filesystem move. Move a project as a whole folder — its internal structure
is preserved untouched, and `project:` backlinks in its notes keep resolving because the
overview's filename does not change. Its backend project is not touched by a move;
`/archive` handles that side.

```bash
mv "$PARA_ROOT/Projects/PROJ-0003 Project C" "$PARA_ROOT/Archive/"
```

Quote both paths. Never move onto an existing path — check first; `mv` will happily
merge a folder into a same-named one.

## Deleting

Default is the macOS Trash, which keeps the action recoverable:

```bash
trash "$PARA_ROOT/Resources/Some note.md"
```

Use `rm -rf` only when the user explicitly asks for permanent deletion as a separate
request — never as a fallback because `trash` was not found. If `trash` is unavailable,
say so and ask.

After deleting, handle the backlinks you collected: leave them broken, strip the link
leaving the text, or remove the line. That is the user's call, and editing those other
notes is itself a Tier 2 action.
