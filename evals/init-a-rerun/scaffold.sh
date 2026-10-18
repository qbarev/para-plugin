#!/usr/bin/env bash
# The workspace is a vault exactly as /para:init (scenario A: en, PARA, files, none) left
# it, plus three edits the user made afterwards: IGNORE in vault.md, a line in
# Templates/Project.md, an extra key in .obsidian/app.json. Git keeps no empty folders,
# so the five empty PARA folders are made here.
set -eu
here=$(cd "$(dirname "$0")/../fixtures/init-a-done" && pwd)
cp -R "$here/." "$PWD/"
sed -i '' "s|__REPO_ROOT__|$PWD|" "$PWD/.claude/para/vault.md"
for d in Projects Areas Resources Archive Inbox; do mkdir -p "$PWD/PARA/$d"; done
