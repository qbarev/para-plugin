#!/usr/bin/env bash
# Stage the synthetic "embedded" vault (scenario C of /para:init: the old embedded tooling
# in .claude/para/ and .claude/skills/) into the eval session's working directory, which
# is the vault root: init takes REPO_ROOT from pwd.
#   stage-embedded.sh        the vault as found, before init
#   stage-embedded.sh done   the vault as /para:init scenario C left it (init-c-done)
set -eu
here=$(cd "$(dirname "$0")" && pwd)
src=embedded
[ "${1:-}" = done ] && src=init-c-done
cp -R "$here/$src/." "$PWD/"
for f in "$PWD/.claude/para/local/roots.md" "$PWD/.claude/para/vault.md"; do
  [ -f "$f" ] && sed -i '' "s|__REPO_ROOT__|$PWD|" "$f"
done
# Git keeps no empty folders: make the PARA folders the vault has.
for d in Projects Areas Resources Archive Inbox Templates; do mkdir -p "$PWD/Second-brain/$d"; done
exit 0
