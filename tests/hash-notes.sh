#!/usr/bin/env bash
# Print one line per note (.md file) under <dir>: its sha256 and its basename, sorted.
# Paths are left out on purpose, so a pure move leaves the output unchanged and any
# change to a note's content shows up as a changed line. Dot-entries (.obsidian, .claude)
# are skipped: they hold settings, not notes.
#
#   tests/hash-notes.sh <dir> > before; ...; tests/hash-notes.sh <dir> > after
#   comm -23 before after   # notes changed or gone — must be empty after /para:init
#   comm -13 before after   # notes that appeared — only what init created
set -eu
dir=${1:?usage: hash-notes.sh <dir>}
[ -d "$dir" ] || { echo "not a directory: $dir" >&2; exit 2; }
export LC_ALL=C
find "$dir" -mindepth 1 -name '.*' -prune -o -type f -name '*.md' -print0 \
  | while IFS= read -r -d '' f; do
      printf '%s  %s\n' "$(shasum -a 256 < "$f" | cut -d' ' -f1)" "$(basename "$f")"
    done | sort
