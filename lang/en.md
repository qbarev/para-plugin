# Language: en

Every string a skill writes into a note or prints to chat comes from this file; the
language is chosen per vault by `LANG` in `vault.md` (`paths.md` «Language»). The
Russian file `ru.md` carries exactly the same keys.

Format: one entry per line, `key: value`. A key is lowercase, dotted, named by meaning.
Placeholders in braces (`{n}`, `{title}`) are filled by the skill. A plural placeholder
`{n|one|other}` stands for the number followed by the right form of the noun (the rule
is written once, in `paths.md` «Language»). Dates are built from `{yyyy}`, `{mm}`, `{dd}`. Section values are the
heading text without the leading `#`. Nothing else on a line that starts with a key.

## Note sections

project.goal: Goal
project.problem: Problem
project.value: Value
project.expected_result: Expected result
project.scope: Scope of work
project.dod: Definition of Done
project.what_changed: What changed
common.links: Links
area.current_state: Current state
area.notes: Notes
resource.summary: Summary
resource.own_thoughts: My thoughts
note.essence: Essence
note.open_questions: Open questions

## Values

resource.type.article: article
resource.type.book: book
resource.type.video: video
resource.type.own_thought: own thought
project.outcome.completed: Completed.
project.outcome.abandoned: Abandoned: {reason}.
archive.no_outcome: no outcome recorded
common.no_metadata: no metadata
common.schema_behind: This vault's schema is version {vault}, the plugin expects {plugin}: run `/para:init` to migrate.
common.schema_ahead: This vault's schema is version {vault}, newer than the plugin's {plugin}: update the plugin.

## Tasks

task.unpaired: no pair in the task manager
task.overdue_by: overdue by {n|day|days}
task.research.name: Research «{short}»: define the scope of work
task.research.done: in the project note the «{scope}» section is filled in and tasks exist for its items
task.waiting.name: Check whether {who} has replied
count.scheduled: scheduled
count.overdue: overdue
count.backlog: in backlog
count.backlog_short: backlog
count.closed: closed
common.unit.min: min
common.unit.hour: h
common.unit.day: d
common.weekdays: Mon Tue Wed Thu Fri Sat Sun
common.date: {yyyy}-{mm}-{dd}
common.date_short: {mm}-{dd}
common.days: {n|day|days}

## Inbox

inbox.name: Inbox
inbox.header: **{n} in the Inbox**, oldest {days} d
inbox.strays: {k|file|files} more in the Inbox/ folder — I will take them in /inbox process
inbox.route.action: Action
inbox.route.project_task: Project task
inbox.route.project: Project
inbox.route.area: Area
inbox.route.resource: Resource
inbox.route.keep: Keep
inbox.route.delete: Delete

## Archive

archive.list.projects: **Archived projects ({n})**
archive.list.notes: **Archived notes ({n})**
archive.list.deadline: deadline {date}
archive.ask_changed: what did this project change?
archive.expected: Expected: {value}. Did it come true?

## Projects

overview.area: Area
overview.deadline: Deadline
overview.tasks: Tasks
overview.acceptance: Acceptance
overview.essence: Essence
overview.scheduled: Scheduled
overview.backlog: Backlog
overview.digest: Digest
overview.signals: Signals
overview.backlog_more: …and {n} more
overview.legacy: Old format: {fields} — migrate when grooming
overview.legacy_tasks: Tasks/ ({n|file|files})
list.header: **Projects ({n})**
list.until: until {date}
list.deadline_passed: deadline passed {n} d ago
list.backlog_empty: backlog empty
list.legacy: old format
list.orphans: No pair in the vault: {names}

## Areas

areas.review.heading: Areas
areas.review.group: **{group}** — {n|note|notes}, last edit {days|day|days} ago
areas.review.no_notes: no notes
areas.review.stale: «{title}» unchanged for {days|day|days}

## Vault lint

lint.heading: Vault check — {n|note|notes}
lint.group.breaks: Breaks the vault
lint.group.schema: Violates the schema
lint.group.review: Worth a look
lint.finding.not_configured: Vault not configured
lint.finding.duplicate_names: Duplicate filenames
lint.finding.dangling_links: Dangling wikilinks
lint.finding.notes_in_repo_root: Notes in REPO_ROOT
lint.finding.extra_folders: Extra folders in PARA_ROOT
lint.finding.inbox_files: Files in Inbox/
lint.finding.duplicate_ids: Duplicate ids
lint.finding.id_mismatch: id does not match the folder prefix
lint.finding.dangling_project: Note points at a nonexistent project
lint.finding.dates: Dates
lint.finding.tag_placeholders: Tag placeholders
lint.finding.missing_subfolders: Project missing one of the three subfolders
lint.finding.misplaced_fields: short or tasks_ref in the wrong place
lint.finding.pair: Pair with the task manager
lint.finding.legacy: Old format
lint.finding.sync_copies: Sync copies
lint.finding.unpaired: Unpaired
lint.finding.old_field_name: Old field name
lint.finding.orphans: Orphan notes
lint.finding.no_frontmatter: Notes without frontmatter
lint.pair_lost: pair lost: no project with id `{id}` in the task manager
lint.pair_closed: closed in the task manager, not in the vault
lint.unpaired_counts: {vault} in the vault, {backend} in the task manager
lint.clean: No duplicate ids, links to nonexistent projects, notes in the root or lost pairs.

## Init

init.plan.heading: Plan
init.plan.approve: Apply this plan? Answer «yes», or say what to change.
init.report.heading: Done
init.report.skipped: Skipped
init.nothing_to_do: Everything is in place — nothing to change.
