#!/usr/bin/env bash
# Stage the synthetic "legacy" vault into the eval session's working directory.
#   setup.sh            vault with config; the cwd's .claude is a symlink to the vault's .claude
#   setup.sh no-config  same vault without .claude/para/vault.md and without the symlink
# The vault lives under a directory whose name contains a space, so every skill path
# that is not quoted fails here.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
dest="$PWD/My Drive/legacy vault"
mkdir -p "$dest"
cp -R "$here/legacy/." "$dest/"
sed -i '' "s|__REPO_ROOT__|$dest|" "$dest/.claude/para/vault.md"
if [ "${1:-}" = "no-config" ]; then
  rm "$dest/.claude/para/vault.md"
else
  ln -s "$dest/.claude" "$PWD/.claude"
fi
