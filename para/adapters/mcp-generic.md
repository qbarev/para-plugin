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
   - `project.activity` must return `state` always (from the project list: absent is
     `missing`) and may leave `last_event` absent;
   - `project.list` and `task.label` are optional, and «not supported» is a normal
     answer for them.
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
6. **Show the table**: one row per operation, with the tool, its arguments and the
   result mapping, and the `pairing` line. Ask for a «yes» (`confirm.md`). Nothing is
   written before it. On anything else, change the table and show it again.
7. **Write** `<REPO_ROOT>/.claude/para/adapter.md` (`REPO_ROOT` from `vault.md`), in the
   shape below. This is the only file the procedure writes; it makes no call to the
   app's tools beyond reading their list.

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
- Tool names appear only in this generated file, as in `todoist.md`.

`config.example/adapter.md` is the empty form of this shape: every section present,
every body blank, `pairing:` blank.
