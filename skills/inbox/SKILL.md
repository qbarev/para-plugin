---
name: inbox
description: Work with the inbox of the PARA vault, which lives in the task manager's inbox (Todoist «Входящие») — capture a raw thought into Todoist, list what is sitting there unprocessed, or process captures one by one into their proper PARA folder. Use when the user wants to capture a note, or says "capture this", "add to the inbox", "what is in the inbox", "process the inbox", "запиши", "закинь в инбокс", "что в инбоксе", "покажи инбокс", "разбери инбокс", "разгреби инбокс".
argument-hint: add <text> | list | process
---

# Inbox

The vault's capture buffer is the task backend's inbox, not a folder — `paths.md` owns
that rule and what `Inbox/` on disk is for. A capture leaves the buffer for a proper
PARA folder once it is clear what it is, or stays in the backend if it is just an action.

Under `TASKS = files` the inbox is the `Inbox/` folder (`paths.md` says what that means,
including strays); the steps below are unchanged except the strays handling.

Every task call is an operation from `tasks.md`, run per the adapter for `TASKS`. If the
backend is unavailable, `tasks.md` «Backend missing» applies: say so and stop — never
fall back to writing a file.

## Base layer

Read before acting, each as `../../para/<file>.md` relative to this skill's base directory — these hold the shared rules, do not restate them from memory:

- `../../para/paths.md` — always, including «Language»: the strings below come from `lang/<LANG>.md`
- `../../para/tasks.md` — always: the operations; for `process` also what a task is, area projects
- `../../para/note-format.md` — for `process`
- `../../para/confirm.md` — for `process`
- `../../para/move.md` — for `process`, when it routes a stray file out of `Inbox/`

## Subcommands

The first word of `$ARGUMENTS` picks the subcommand. Anything that is not `list` or
`process` is treated as the text of an `add`, so `/inbox a thought about sleep` captures that
thought — the `add` keyword is optional. Empty `$ARGUMENTS` → show the three subcommands
and ask.

---

### `add <text>` — capture

1. **`inbox.add`** with a `title` and optional `description`. A short text is the title
   as given. A long one gets a short title in `LANG` derived from it (6 words or fewer)
   and the full text verbatim as the description.
2. **Set nothing else** — no date, priority or labels unless the user said them.
   This is a buffer, not a place to tidy the user's thought into shape.
3. **Report** in one line what was created, so the user can rename if they disagree.

If the capture obviously belongs somewhere specific, say so in the report and offer
`/inbox process` — do not route it unasked.

---

### `list` — show what is unprocessed

Read only.

1. **`inbox.list`** — every open capture.
2. **Print** a numbered list, oldest first, headed with the `inbox.header` string
   (`{n}` captures, `{days}` the age of the oldest). Titles only, no descriptions.
3. **Strays.** Not under `TASKS = files` (`paths.md`). List `*.md` in `Inbox/` (filenames only, do not open them). If any exist,
   add one line, the `inbox.strays` string (`{k}` files).
4. An empty inbox is a valid, good answer: say so plainly.

---

### `process` — route the captures

The valve on the buffer. Interactive, **one capture at a time** — never dump the whole
inbox with proposed destinations and ask the user to approve in bulk.

1. **List the inbox** as above — backend captures first, oldest first, then strays from
   `Inbox/` (under `TASKS = files` `inbox.list` has them all, `paths.md`). Say how many there are and start with the first.

2. **For each capture**: show the title and the content (the description, or the file
   body for a stray) — briefly if it is long. Then give your read of what it is, and
   offer the routes. The route names are the `inbox.route.*` strings of
   `lang/<LANG>.md`; the left column below is the key:

   | Route | What happens |
   |---|---|
   | `inbox.route.action` | a to-do outside any project → move it to the area the user picks (`task.move` with `area`; the names are those `tasks.md` gives for `area`, which under `TASKS = files` are `GROUPS` in `areas.md`); wording checked per `tasks.md` «What a task is», a rewording proposed before the move |
   | `inbox.route.project_task` | a step of an existing project → the project found per `find-target.md`, the wording proposed per `tasks.md` «What a task is», then `task.move` with that `project_ref` and the new `title`; the task stays open, nothing is created or closed. Under `TASKS = files` a taken basename is a collision: `note-format.md` «Name collisions» |
   | `inbox.route.project` | an effort with an end state → hand off to `/projects create` |
   | `inbox.route.area` | ongoing responsibility → `/areas create`, or append to an existing Area |
   | `inbox.route.resource` | knowledge worth keeping → `/resources create` |
   | `inbox.route.keep` | not ripe yet — stays in the inbox, no shame in it |
   | `inbox.route.delete` | junk → close it (see below) |

   Recommend one, with a reason in a sentence. The user decides.

3. **Carry out the route**, handing the capture's text to the skill that owns the
   destination — it builds the note from its own template. Never write a note here.

4. **Close the capture** once its route is carried out:

   - **Backend capture** — routed into the vault, or junk →
     `inbox.close` — reversible (`tasks.md`), so Tier 1 (`confirm.md`). `inbox.route.action` and
     `inbox.route.project_task` move the task itself (`task.move`) and leave it open;
     `inbox.route.keep` leaves it where it is.
   - **Stray file** in `Inbox/` — after `/projects create`, `/areas create` or
     `/resources create` has taken its content, remove the file via `/remove`; for
     `inbox.route.delete`, hand it to `/remove` directly. `inbox.route.action` turns it into a task
     with `task.add` and `area`, then remove the file the same way.

5. **Then go to the next capture.** Do not batch the closing to the end.

6. **Stop when the user says stop**, and report how many were processed and how many
   remain. Getting through the whole inbox in one sitting is not the goal.

## Notes

- The inbox is deliberately low-friction: `add` never asks a question it can avoid.
  `process` is where the thinking happens.
- Everything in `LANG`, tasks included.
