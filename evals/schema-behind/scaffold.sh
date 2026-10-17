#!/usr/bin/env bash
# The legacy fixture with its SCHEMA set back to 0: a vault older than the plugin.
set -eu
"$(dirname "$0")/../fixtures/setup.sh"
sed -i '' 's/^| `SCHEMA` | `1` |$/| `SCHEMA` | `0` |/' "$PWD/My Drive/legacy vault/.claude/para/vault.md"
grep -q '^| `SCHEMA` | `0` |$' "$PWD/My Drive/legacy vault/.claude/para/vault.md"
