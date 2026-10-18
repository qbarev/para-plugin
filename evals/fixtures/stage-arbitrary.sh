#!/usr/bin/env bash
# Stage the synthetic "arbitrary" Obsidian vault (scenario B of /para:init) into the eval
# session's working directory, which is the vault root: init takes REPO_ROOT from pwd.
#   stage-arbitrary.sh        the vault as found, before init
#   stage-arbitrary.sh done   the vault as /para:init scenario B left it (init-b-done)
# Git keeps no mtimes, so they are set here: everything is fresh except the finished
# «Курсовая 2023/», untouched since 2024 (older than the area-staleness threshold).
set -eu
here=$(cd "$(dirname "$0")" && pwd)
src=arbitrary
[ "${1:-}" = done ] && src=init-b-done
cp -R "$here/$src/." "$PWD/"
find "$PWD" -mindepth 1 -exec touch {} +
find "$PWD" -path "*/Курсовая 2023*" -exec touch -t 202405011200 {} +
if [ -f "$PWD/.claude/para/vault.md" ]; then
  sed -i '' "s|__REPO_ROOT__|$PWD|" "$PWD/.claude/para/vault.md"
fi
# Git keeps no empty folders: make the PARA folders a finished run leaves empty.
if [ "$src" = init-b-done ]; then
  for d in Projects Areas Resources Archive Inbox Templates; do mkdir -p "$PWD/$d"; done
  for d in Resources Results; do mkdir -p "$PWD/Projects/PROJ-0001 Переезд в новую квартиру/$d"; done
fi
