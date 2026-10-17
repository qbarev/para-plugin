---
name: resources
description: Work with Resources in the Obsidian PARA vault — capture reference material or an evergreen idea as a resource note, with a summary of the source and a place for the user's own thinking. Use when the user says "сохрани статью", "заведи ресурс", "законспектируй", "добавь в ресурсы", "сохрани книгу", "запиши свою мысль" about something worth keeping.
argument-hint: create <ссылка или текст>
---

# Resources

Reference material and evergreen knowledge: articles, books, videos, and the user's own
matured thoughts. What separates a resource from a capture in the Todoist inbox is durability — a
resource is something worth rereading in a year, not a note about today.

Resources are grouped by topic in nested folders (`Resources/<Тема>/<Подтема>/`).

## Base layer

Read before acting, each as `../../para/<file>.md` relative to this skill's base directory — these hold the shared rules, do not restate them from memory:

- `../../para/paths.md` — always
- `../../para/note-format.md` — always
- `../../para/confirm.md` — this skill writes a note; a name collision is Tier 1.5

## Subcommands

`create` is the only one; it is also the default, so `/resources <ссылка>` works without
the keyword. Empty `$ARGUMENTS` → ask what to save.

---

### `create <ссылка или текст>` — save a resource

1. **Read `Templates/Resource.md`** from disk, verbatim.

2. **Work out the `type`** — one of `статья` / `книга` / `видео` / `своя мысль`. A URL
   usually settles it; the user's own reasoning with no source is `своя мысль`.

3. **Get the content.**
   - A URL → fetch and read it. If it cannot be fetched (paywall, login), say so and ask
     the user to paste the text rather than writing a summary from the title alone.
   - Pasted text → use it as given.
   - `своя мысль` → the user's own words are the content; there is nothing to fetch.

4. **Derive a title** per `note-format.md` — what the thing *says*, not its headline.
   A resource is found later by what it taught, so derive the title from the claim it
   makes, never from the publisher's headline.

5. **Fill the frontmatter** per the Resource row of the schema in `note-format.md`:
   - `tags` — both `resource/<slug>` and `topic/<slug>`, real slugs, no trailing slash.
   - `source` — the URL, or the book's author and title. Blank for `своя мысль`.
   - `type` — from step 2.

6. **Fill the body:**
   - `# Ссылки` — wikilinks to related notes already in the vault. Search for them; a
     resource that links to nothing is a resource nobody will find again.
   - `# Конспект` — the substance, in the user's language and in your own words: what it
     claims, on what grounds, what follows. Not a table of contents, not a quote dump.
     For `своя мысль`, this is where the thought itself goes.
   - `# Свои мысли` — **leave empty.** This section is the user's reaction to the
     material, and writing it for them defeats its purpose. Say in the report that it is
     waiting for them.

7. **Choose the folder.** Place it under the existing topic folder it belongs to —
   list `Resources/` first and reuse a folder rather than inventing a sibling with a
   near-identical name. A genuinely new topic gets a new folder; say that you created it.

8. **Check the basename** for a vault-wide collision, **write**, and **report** the path,
   the type, and that `# Свои мысли` is left for them.

## Notes

- Thinking *about* someone else's material stays inside that material's note, under
  `# Свои мысли` — it does not become a separate note. Only a thought that stands on its
  own becomes a resource of type `своя мысль`.
- If the thing is time-bound — a decision, a state of affairs, something true only this
  quarter — it is not a resource. Offer `/inbox add` or the relevant project's `Notes/`.
- Everything in Russian, including the conspectus of an English-language source.
