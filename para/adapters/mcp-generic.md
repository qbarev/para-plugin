# Adapter: generic MCP

The procedure `/para:init` follows when `TASKS = mcp`: it maps the tools of any
connected to-do app onto the operations in `tasks.md`, and writes the result as the
vault's own adapter. This file is not an adapter itself and is never read at run time;
the file it produces is. Skills then read that file exactly as they read `todoist.md`
or `files.md`.

The operations, their inputs and results, and what «not supported» means for a skill
are owned by `tasks.md`; this file does not restate them. «Unsupported» there is the
single rule for what a skill does at an operation the adapter marks «not supported».

## Procedure

1. **List the tools.** Take the connected app's MCP tools (names and input schemas) from
   the session. None connected: say so in one line and stop; never guess tool names.
2. **Match each operation.** For every operation in the `tasks.md` table, including the
   optional ones, propose one tool and its arguments:
   - read the tool's description and schema, not just its name; a plausible name with
     the wrong effect is the usual mistake (a «delete» that is really an archive, a
     «move» that resets the date);
   - fill in every contract input from the schema. An input the tool cannot take
     (labels, duration, due, a rename on move) is noted as unsupported *for that
     input*, not guessed around;
   - an operation that needs several calls (look up a project, then act) lists them
     in order;
   - `inbox.close` must complete or otherwise close the capture without destroying it
     (`tasks.md`). A tool that can only delete leaves it «not supported».
   - `task.add`, `task.list` and `task.move` take both addressing forms, `project_ref`
     and `area` (exactly one per call); say how each is met, including how an `area`
     name is resolved to a project. `task.move` also takes the optional `title`
     (a rename on move); a tool that cannot rename marks that input unsupported;
   - an app with no inbox concept marks `inbox.add`, `inbox.list` and `inbox.close`
     «not supported»;
   - **confirm a change by re-reading the object, never trust the tool's echo.** For
     `project.archive`, `project.restore`, `task.label`, `task.move` and
     `task.complete`, the proposal
     names the read call that confirms the change (for example reading the project
     list or the task back), and the generated section carries that read step;
   - `project.activity` must return `state` always (from the project list: absent is
     `missing`) and may leave `last_event` absent;
   - `task.complete` must complete the task without destroying it, as `inbox.close`
     must; a tool that can only delete leaves it «not supported»;
   - `project.list`, `task.complete` and `task.label` are optional, and «not supported»
     is a normal answer for them.
3. **Mark what does not match** «not supported», with a one-line reason. Never
   substitute a tool whose effect differs. Never claim support for an operation that
   was not found.
4. **Find the app's specifics** the adapter needs, as `todoist.md` does in its list at
   the top: how the inbox is addressed, what `ref` is, which fields map to `text`,
   `due`, `created`, whether lists are paged, required arguments with defaults the
   adapter must send (never chosen by the adapter on the user's behalf).
5. **Choose `pairing`** (`tasks.md` «Pairing»): `separate` for an app with projects of
   its own, which is the normal case; `none` only for an app with no project concept,
   where a project folder is its own list. Say which and why.
6. **Verify reads (optional, with the user's consent).** Ask once. If the user agrees,
   call only read operations (`project.list`, `inbox.list`, `task.list`) to confirm the
   result mapping and the paging: follow cursors until exhausted (an empty page with a
   cursor is not the end). Correct the proposal where the real result differs. **Never
   call a mutating tool during the procedure.** Every mutating operation
   (`inbox.add`, `inbox.close`, `project.create`, `project.archive`,
   `project.restore`, `project.delete`, `task.add`, `task.move`, `task.complete`,
   `task.label`) is marked
   «behaviour unverified» in the table, and in its section of the generated file.
7. **Show the table**: one row per operation, with the tool, its arguments and the
   result mapping, and the `pairing` line. Ask for a «yes» (`confirm.md`). Nothing is
   written before it. On anything else, change the table and show it again.
8. **Write** `<REPO_ROOT>/.claude/para/adapter.md` (`REPO_ROOT` from `vault.md`), in the
   shape below. This is the only file the procedure writes; it makes no write
   calls; read calls only with the user's consent (step 6). `init` writes the file from
   `config.example/adapter.md` without that file's preamble (the bold vault-specific
   paragraph), so the vault's `adapter.md` begins at the `# Adapter:` heading and the
   description line.

## Shape of the generated file

The same shape as `todoist.md`:

```
# Adapter: <app name>

How each operation in `tasks.md` is carried out with <app>'s MCP tools. Used when
`TASKS = mcp`.

pairing: separate | none

If the tools are not available in the session, `tasks.md` «Backend missing» applies.

<specifics that hold for every operation, one bullet each>

## Operations

### `inbox.add`
<tool, arguments, result>
... one section per operation, in the order of the `tasks.md` table ...
```

- Every operation of `tasks.md` has its own section, headed by its name in backticks.
  An operation without a match has the section too, with the body `not supported` and
  the reason.
- `pairing:` is a line of its own, `separate` or `none`, exactly once.
- An operation that changes something (`project.archive`, `project.restore`,
  `task.label`, `task.move`, `task.complete`) carries its confirming read in its section: «confirm by
  re-reading <object> with <tool>; the tool's echo is not evidence».
- A mutating operation not exercised during `init` carries «behaviour unverified».
- Tool names appear only in this generated file, as in `todoist.md`.

`config.example/adapter.md` is the empty form of this shape: every section present,
every body blank, `pairing:` blank.
