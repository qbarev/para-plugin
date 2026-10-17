#!/usr/bin/env bash
# Static checks over the plugin's skills and base layer.
# Exits non-zero and prints file:line for every violation.
set -u
cd "$(dirname "$0")/.." || exit 2

fail=0
report() { echo "$1"; fail=1; }

# Check 1: no reference to the old location of the base layer or its local/ config.
# Config lives at <REPO_ROOT>/.claude/para/{vault,areas,adapter}.md and may be named.
# Match each reference on its own (grep -o), so an allowed reference on the same line
# cannot hide an old one.
while IFS= read -r hit; do
  report "old-location: $hit"
done < <(grep -noE '\.claude/para/([A-Za-z0-9_.-]*)' skills/*/SKILL.md para/*.md \
           | grep -vE '\.claude/para/(vault|areas|adapter)\.md$' \
           | grep -vE '\.claude/para/$' )
while IFS= read -r hit; do
  report "old-location (local/): $hit"
done < <(grep -nE 'local\.example|local/|roots\.md|TODOIST_AREA_PROJECTS' skills/*/SKILL.md para/*.md)

# Check 2: every ../../para/X.md reference in a skill resolves to an existing file.
for f in skills/*/SKILL.md; do
  dir=$(dirname "$f")
  while IFS=: read -r line ref; do
    [ -e "$dir/$ref" ] || report "missing-target: $f:$line -> $ref"
  done < <(grep -noE '\.\./\.\./para/[A-Za-z0-9_./-]+\.md' "$f")
done

# Check 2b: references between base-layer files (bare `name.md` in backticks) resolve
# to an existing para/ file. Vault config names are exempt; they live in the vault.
for f in para/*.md; do
  while IFS=: read -r line ref; do
    ref=${ref//\`/}
    case "$ref" in vault.md|areas.md|adapter.md) continue ;; esac
    [ -e "para/$ref" ] || report "missing-target: $f:$line -> $ref"
  done < <(grep -noE '(^|[^/A-Za-z0-9_.-])`[a-z][a-z-]*\.md`' "$f" | sed -E 's/^([0-9]+):[^`]*(`[^`]+`)$/\1:\2/')
done

# Check 3: vault paths must be built from PARA_ROOT / REPO_ROOT.
#  a) no literal vault directory name, home path or absolute user path
while IFS= read -r hit; do
  report "literal-path: $hit"
done < <(grep -nE 'Second-brain|/Users/|~/' skills/*/SKILL.md para/*.md)
#  b) inside bash/sh code fences, a PARA folder path needs PARA_ROOT or REPO_ROOT on the line
while IFS= read -r hit; do
  report "unrooted-path: $hit"
done < <(awk '
  FNR==1 { inb=0 }
  /^```(bash|sh|zsh)[[:space:]]*$/ { inb=1; next }
  /^```/ { inb=0; next }
  inb && /(Projects|Areas|Resources|Archive|Templates|Inbox)\// && !/PARA_ROOT|REPO_ROOT/ { print FILENAME ":" FNR ": " $0 }
' skills/*/SKILL.md para/*.md)

# Check 4 (R7): optional denylist of personal terms, one per line, kept outside the repo.
if [ -z "${PARA_DENYLIST:-}" ]; then
  echo "denylist check skipped (PARA_DENYLIST not set)"
elif [ ! -f "$PARA_DENYLIST" ] || [ ! -r "$PARA_DENYLIST" ]; then
  report "denylist: PARA_DENYLIST is set but is not a readable file"
else
  # Print file:line only, never the matching text.
  files=()
  while IFS= read -r -d '' f; do files+=("$f"); done < <(git ls-files -z)
  dl_out=$(grep -nIiF -f "$PARA_DENYLIST" "${files[@]}" 2>&1)
  rc=$?
  dl_out=$(printf '%s\n' "$dl_out" | sed -E 's/^([^:]+:[0-9]+):.*/\1/')
  if [ "$rc" -gt 1 ]; then
    report "denylist: grep failed (exit $rc)"
  else
    while IFS= read -r hit; do [ -n "$hit" ] && report "denylist: $hit"; done <<<"$dl_out"
  fi
fi

if [ "$fail" -ne 0 ]; then
  echo "check.sh: FAILED"
  exit 1
fi
echo "check.sh: OK"
