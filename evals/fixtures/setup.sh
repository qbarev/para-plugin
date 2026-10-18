#!/usr/bin/env bash
# Stage the synthetic "legacy" vault into the eval session's working directory.
#   setup.sh            vault with config; the cwd's .claude is a symlink to the vault's .claude
#   setup.sh no-config  same vault without .claude/para/vault.md and without the symlink
#   setup.sh files      the TASKS = files fixture (tasks as notes on disk); no connector needed
# The vault lives under a directory whose name contains a space, so every skill path
# that is not quoted fails here.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
fixture=legacy
if [ -n "${1:-}" ] && [ -d "$here/$1" ]; then fixture=$1; shift; fi
dest="$PWD/My Drive/$fixture vault"
mkdir -p "$dest"
cp -R "$here/$fixture/." "$dest/"
sed -i '' "s|__REPO_ROOT__|$dest|" "$dest/.claude/para/vault.md"
if [ "${1:-}" = "no-config" ]; then
  rm "$dest/.claude/para/vault.md"
else
  ln -s "$dest/.claude" "$PWD/.claude"
fi
