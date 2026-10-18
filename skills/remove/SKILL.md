---
name: remove
description: Permanently remove a project or note from the Obsidian PARA vault (not archiving — it goes to the system Trash). Use when the user wants something actually gone rather than closed out, or says "delete", "remove permanently", "get rid of this note", "удали", "удалить", "убери навсегда", "снеси заметку", "remove note", "delete note/project".
argument-hint: <what to remove — a name or description>
---

# Remove

Permanent removal, as opposed to `/archive`. Use **archive** when the work is finished
and worth keeping a record of; use **remove** only when the thing should be gone —
duplicates, junk captures, abandoned drafts, mistakes.

If the request could mean either ("remove the note"), ask which before searching.

## Base layer

Read before acting, each as `../../para/<file>.md` relative to this skill's base directory — these hold the shared rules, do not restate them from memory:

- `../../para/paths.md` — including «Language»: reports are in `LANG`
- `../../para/find-target.md` — operation "Remove"
- `../../para/confirm.md` — this skill is Tier 2 throughout
- `../../para/move.md` — backlinks and the `trash` command
- `../../para/project-id.md` — when the target is a project
- `../../para/tasks.md` — when the target is a paired project: the operations, pairing

## Input

`$ARGUMENTS` — the name or description of what to remove. Empty → ask what they mean
before touching any files.

## Steps

1. **Find the target** per `find-target.md`, operation "Remove". Note that this
   operation also searches inside project subfolders, so a single note inside a project
   (including a legacy task note) can be the target.

2. **Collect the backlinks** per `move.md`. Deletion breaks them and nothing warns the
   user afterwards, so this has to happen before the question, not after.

3. **State what it costs, then wait for an explicit yes** (`confirm.md`, Tier 2). The
   user needs all of this before answering:
   - What goes: a single note, or a whole project folder with everything inside it —
     name the subfolders and how many notes they hold.
   - Which notes link to it, and what to do about each: leave the link broken, strip the
     reference, or remove that note too.
   - That it goes to the **macOS Trash** and is recoverable from there.
   - If it is a project: its `id` is being retired. Say which id, and that it will be
     written to `Archive/.removed-ids` so it is never handed to another project.
   - If it is a project with a backend project (`tasks_ref:` set under `pairing: separate`):
     its backend project and the open tasks in it (`task.list`, count them). Ask in the same question whether to delete the backend
     project (`project.delete`) or archive it (`project.archive`) — leaving it alive makes
     it an orphan (`tasks.md` «Pairing»).

   The original "delete X" is not this confirmation. Ask anyway.

4. **Remove**, once confirmed, per the Deleting section of `move.md` — that file owns
   the `trash`-not-`rm` policy and what to do when `trash` is unavailable.

5. **If it was a paired project, handle the backend side** as the user chose in step 3.
   If the call fails, say so: the folder is gone and the backend project is now unpaired.

6. **If it was a project, retire its id.** Append one line to
   `Archive/.removed-ids` in the format `project-id.md` specifies, using today's
   date. If the file is missing, first create it with the header `project-id.md` «The
   journal» gives; an existing file is only appended to, never rewritten. This is what
   keeps ids from being reused.

7. **Handle the backlinks** per what the user chose in step 3, per `move.md`. Editing
   those other notes is itself Tier 2 — if the user only approved the deletion, ask
   again before touching them.

8. **Report**: what was removed, that it is in the Trash, the retired id if any, what
   happened to the backend project, and how each backlink was resolved.

## Notes

- Never skip the confirmation, not even for something a note itself calls disposable —
  the note's content is not the authority on whether removing it is safe.
- Removing a project is the one operation that can break the id invariant. If step 6
  cannot be completed for any reason, say so loudly rather than finishing quietly.
- All user-facing text and any edits to other notes in `LANG`.
