# Definition of Done

The vault's single definition of what "finished" means for a project. Nothing else —
no skill, no CLAUDE.md section — restates these conditions; they are read from here.

## Two sections that look alike

A project's overview note carries two adjacent sections answering different questions.
Keep them apart — never write the same thing in both:

- the `project.expected_result` section — **what will exist**: the artifacts and where they live.
- the `project.dod` section — **how you check that what exists is good enough**: 2–5
  conditions, each answerable yes/no without consulting the author's intentions.
  Written as checkboxes (`- [ ]`) and ticked off when met.

## The four conditions

A project is **completed** only when all four hold:

1. every item in the overview's `project.dod` section is ticked;
2. `Results/` holds the artifact promised in the `project.expected_result` section;
3. its backend project has no open tasks (`tasks.md`) — each was completed, or
   deleted because it stopped being needed. Under `pairing: separate`, an unpaired
   project with a legacy `Tasks/` folder (`note-format.md`) is checked there instead: no task note left `To Do` or
   `In progress`. Under `pairing: none` (`TASKS = files`) the project's own `Tasks/` notes
   are the backend: none left `status: open`;
4. knowledge that outlives the project (a regulation, a derived principle) has been
   moved into `Areas/` or `Resources/` — only the project itself goes to the
   archive. If the project produced no such knowledge, say so out loud rather than
   skipping the point silently.

If the overview has no `project.dod` section at all (a note predating the
convention), say so and check the three remaining points.

These four say whether the project was *finished*. They do not say whether it was
*worth doing* — that is a separate question, asked once, at archiving time, by
`/archive`. Do not fold it into the conditions above: a project can be executed
perfectly and still have been the wrong project, and the vault should be able to
record that.

The other end of that question is asked before the project starts. the `project.value`
section (`note-format.md`) records what the user expected to gain; the
`project.what_changed` section, written by `/archive`, records what they actually got.
`/archive` reads the first aloud before
asking for the second, so the two can be compared later.

## What the check does and does not block

- It **does** decide whether the project may be recorded as completed. Four
  conditions, all of them, no exceptions granted because the user sounds finished.
- It **does not** block archiving. A project can be abandoned rather than finished, and
  abandoned projects belong in the archive too.

So when a project is being closed, the outcome is one of two:

- **Completed** — all four hold → archive, with the `project.what_changed` section
  opening with the `project.outcome.completed` string.
- **Abandoned** — some point does not hold → archive, with the `project.what_changed`
  section opening with the `project.outcome.abandoned` string, the reason (`{reason}`)
  in the user's words.

There is no `status` field (`note-format.md`): that first line is the record of which
outcome it was. Either way, name the unmet points out loud. Never move the folder
silently, and never write the `project.outcome.completed` string for a project that fails a
condition just because the user asked to close it — offer the abandoned outcome instead.

Finishing some of a project's tasks is not finishing the project.
