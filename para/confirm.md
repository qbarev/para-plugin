# Confirming before acting

One policy for every PARA skill. Which tier an operation falls into depends on whether
the user can undo it, not on how big it feels.

## Tier 1 — reversible: announce, then proceed

Creating a note, adding a Todoist task or project, archiving, restoring, moving,
editing a frontmatter field. The user can undo any of these by hand in seconds.

State what you found and what you are about to do, then **do it without waiting**.
Announcing exists so a wrong target gets caught, not to collect permission:

> Нашёл `Projects/PROJ-0003 Проект В/`. Переношу в `Archive/`,
> архивирую его проект в Todoist.

Do not ask "продолжать?" here. A question on every reversible action trains the user
to answer yes without reading, which is exactly how the wrong file gets archived.

This bans asking for *permission*, not asking for *information*. A reversible operation
that cannot be performed correctly because a required value is missing is Tier 1.5
below — that question is allowed, and skills should not invent their own exception to
this section to justify it.

## Tier 1.5 — input is missing: ask, then proceed

Distinct from Tier 2, and the distinction matters: here you are not asking permission,
you are asking for a value you cannot invent. The operation is already authorised — it
just cannot be carried out correctly yet.

Ask when a field the note cannot be written without has no answer in what the user said:

- a project with no discernible `# Цель`, or no criteria you could turn into real checks;
- an area with no value for the grouping field `areas.md` names — it decides
  which folder the file goes in;
- a basename that already exists somewhere in the vault (see `note-format.md`);
- a restore whose destination the frontmatter does not settle;
- a target that resolved to more than one candidate (see `find-target.md`).

Ask the one question, take the answer, and continue without a second question. Never
fill such a field by inference to avoid asking — an invented grouping is worse than a
pause. Everything the user *did* supply is not re-confirmed.

The line against Tier 1: if you could carry the operation out correctly right now, you
are not missing input, and you do not ask.

**One named exception — planning.** The rhythms in `todoist.md` («Rhythms») set and
move dates and durations in Todoist. Those writes are reversible, but a plan is a
proposal the user shapes, not an announced action: show the whole proposal, wait for
«да», then write. A correction («ВТ не надо, перенеси на ЧТ») is a new proposal, not a
yes.

## Tier 2 — irreversible: explicit yes, then proceed

Deleting anything, overwriting a file that already has content, clearing ticked
checkboxes, editing a note that is not the target of the request.

State exactly what will happen — the full path, what it contains, what else points at
it, and where it goes — then **stop and wait for a clear yes**.

> Найдено: `Resources/<Тема>/Заметка А.md`.
> На заметку ссылаются 2 другие: …
> Уйдёт в корзину macOS. Удаляю?

- The original request is not the confirmation. "удали X" starts the operation; it does
  not pre-approve it. Ask anyway.
- A yes covers the one operation you described. The next irreversible step asks again.
- Silence, an emoji, or a change of subject is not a yes.
- Never bundle a Tier 2 action into a Tier 1 announcement to avoid the question.

## When the request itself is ambiguous

Tier does not apply until you know what the user means. "убери заметку" can mean archive
or delete. Ask which before searching — see `find-target.md` for resolving *which*
object, this is about resolving *which operation*.
