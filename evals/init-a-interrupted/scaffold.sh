#!/usr/bin/env bash
# An interrupted first run of /para:init: the folder is empty except for the areas.md
# init writes before vault.md (taken from the init-a-done fixture).
set -eu
mkdir -p "$PWD/.claude/para"
cp "$(dirname "$0")/../fixtures/init-a-done/.claude/para/areas.md" "$PWD/.claude/para/areas.md"
