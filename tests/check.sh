#!/usr/bin/env bash
# Static checks over the plugin's skills and base layer.
# Exits non-zero and prints file:line for every violation.
set -u
cd "$(dirname "$0")/.." || exit 2

fail=0
report() { echo "$1"; fail=1; }

# Checks 1, 5 and 6 scan skills/*/SKILL.md and para/*.md only. skills/init/scenario-c.md
# is outside them by design: it is the one file that describes the old embedded layout
# (its paths, its planning sections, its todoist.md), read by /para:init in scenario C only.
# Check 1: no reference to the old location of the base layer or its local/ config.
# Config lives at <REPO_ROOT>/.claude/para/{vault,areas,adapter}.md and may be named.
# Match each reference on its own (grep -o), so an allowed reference on the same line
# cannot hide an old one.
while IFS= read -r hit; do
  report "old-location: $hit"
# init detects the old layout by name: its lines carrying the marker `old-layout` are exempt.
done < <(grep -nE '\.claude/para/' skills/*/SKILL.md para/*.md | grep -vE '^skills/init/SKILL\.md:[0-9]+:.*old-layout' \
           | grep -oE '^[^:]+:[0-9]+:|\.claude/para/([A-Za-z0-9_.-]*)' \
           | awk '/:$/{f=$0; next} {print f $0}' \
           | grep -vE '\.claude/para/(vault|areas|adapter)\.md$' \
           | grep -vE '\.claude/para/$' )
while IFS= read -r hit; do
  report "old-location (local/): $hit"
# (`.claude/local/` is the vault's own folder for local files such as planning.md, not the old one.)
done < <(grep -nE 'local\.example|local/|roots\.md|TODOIST_AREA_PROJECTS' skills/*/SKILL.md para/*.md \
           | sed 's#\.claude/local/##g' | grep -E 'local\.example|local/|roots\.md|TODOIST_AREA_PROJECTS' \
           | grep -vE '^skills/init/SKILL\.md:[0-9]+:.*old-layout')

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

# Check 5: planning (sprint, capacity, rhythms) is not part of the plugin (spec section 6).
while IFS= read -r hit; do
  report "planning: $hit"
done < <(grep -nEi 'sprint|спринт|capacity|ёмкость|Rhythm|Как я рабо[т]аю|Рабочий график|Calendar' skills/*/SKILL.md para/*.md) # cyrillic-ok

# Check 6: skills and the base layer speak in operations, not in one task app (spec 5.3).
# The app is named only in para/adapters/todoist.md (not scanned here), in skill
# `description:` lines, in lists of the TASKS values, and where the legacy frontmatter
# key `todoist` is named next to its replacement `tasks_ref`.
while IFS= read -r hit; do
  report "task-app-name: $hit"
done < <(grep -nE 'todoist|Todoist|mcp__' skills/*/SKILL.md para/*.md \
           | grep -vE 'SKILL\.md:[0-9]+:description:' \
           | grep -vE '`todoist`, `files`|`todoist` \| `files`|`todoist` or `files`' \
           | grep -vE 'todoist.*tasks_ref|tasks_ref.*todoist')

# Check 6b: the contract names the contract's operations and every adapter covers each one.
ops="inbox.add inbox.list inbox.close project.create project.archive project.restore project.delete task.add task.list task.move project.activity task.label project.list"
for op in $ops; do
  if [ -f para/tasks.md ]; then
    grep -qF "\`$op\`" para/tasks.md || report "missing-operation: para/tasks.md lacks $op"
  else
    report "missing-operation: para/tasks.md does not exist"; break
  fi
  for a in para/adapters/*.md; do
    [ -e "$a" ] || { report "missing-operation: no adapter files"; break; }
    case "$a" in */mcp-generic.md) continue ;; esac
    grep -qF "\`$op\`" "$a" || report "missing-operation: $a lacks $op"
  done
done

# Check 6c: the empty form of the generated adapter carries every operation and a blank pairing line.
for op in $ops; do
  grep -qF "### \`$op\`" config.example/adapter.md || report "missing-operation: config.example/adapter.md lacks $op"
done
grep -qE '^pairing:[[:space:]]*$' config.example/adapter.md || report "missing-pairing: config.example/adapter.md lacks a blank 'pairing:' line"

# Check 7: every adapter declares its pairing model once, as a line `pairing: separate|none`
# (tasks.md «Pairing»). The generic MCP adapter is exempt: it writes the value per vault.
for a in para/adapters/*.md; do
  [ -e "$a" ] || break
  case "$a" in */mcp-generic.md) continue ;; esac
  grep -qE '^pairing: (separate|none)$' "$a" || report "missing-pairing: $a does not declare 'pairing: separate' or 'pairing: none'"
done

# Check 8: the plugin's own text is English. Cyrillic is allowed only in lang/ru.md,
# templates/ru/, the `description:` line of a skill (the Russian trigger phrases),
# evals/fixtures/ (synthetic Russian vaults), evals/*/case.yaml (graders and prompts that
# match Russian output), and the lines of this file tagged with the marker `cyrillic-ok`
# (check 5's Russian words, which must stay in the pattern). Paths are checked too.
# BSD grep has no -P: Cyrillic (U+0400-04FF) is UTF-8 lead bytes D0-D3, matched bytewise.
cyr=$'[\xd0-\xd3]'
while IFS= read -r -d '' f; do
  case "$f" in
    lang/ru.md|templates/ru/*|evals/fixtures/*|evals/*/case.yaml) continue ;;
  esac
  [ -f "$f" ] || continue
  while IFS= read -r hit; do
    ln=${hit%%:*}; body=${hit#*:}
    case "$f" in
      skills/*/SKILL.md)
        # only the `description:` line inside the frontmatter block (before the second ---)
        fmend=$(awk '/^---$/{n++; if(n==2){print NR; exit}}' "$f")
        case "$body" in description:*) [ "$ln" -lt "${fmend:-0}" ] && continue ;; esac ;;
      tests/check.sh) case "$body" in *cyrillic-ok) continue ;; esac ;;
    esac
    report "cyrillic: $f:$ln"
  done < <(LC_ALL=C grep -nI "$cyr" "$f" 2>/dev/null)
done < <(git ls-files -z)
while IFS= read -r -d '' f; do
  case "$f" in evals/fixtures/*|templates/ru/*|lang/ru.md) continue ;; esac
  if printf '%s' "$f" | LC_ALL=C grep -q "$cyr"; then report "cyrillic: path $f"; fi
done < <(git ls-files -z)

# Check 9: every lang/<LANG>.md carries the same keys as lang/en.md (the reference), each
# once, none empty, with the same placeholder names. The language list is whatever
# lang/*.md exists; a new language is a new file and needs no edit here.
# An entry is a line `key: value`; a key is lowercase, dotted.
keyre='^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+'
langs=()
for f in lang/*.md; do [ -e "$f" ] && langs+=("$(basename "$f" .md)"); done
[ -f lang/en.md ] || report "lang: lang/en.md (the reference) does not exist"
if [ -f lang/en.md ]; then
  ken=$(grep -oE "$keyre:" lang/en.md | sort)
  while IFS= read -r k; do [ -n "$k" ] && report "lang: duplicate key '$k' in lang/en.md"; done < <(printf '%s\n' "$ken" | uniq -d)
  for l in "${langs[@]}"; do
    [ "$l" = en ] && continue
    kl=$(grep -oE "$keyre:" "lang/$l.md" | sort)
    while IFS= read -r k; do [ -n "$k" ] && report "lang: key '$k' is not in both en.md and $l.md"; done \
      < <(comm -3 <(printf '%s\n' "$kl") <(printf '%s\n' "$ken") | tr -d '\t')
    while IFS= read -r k; do [ -n "$k" ] && report "lang: duplicate key '$k' in lang/$l.md"; done < <(printf '%s\n' "$kl" | uniq -d)
    # placeholder names (the part before any |) must match per key
    while IFS= read -r k; do
      k=${k%:}
      pe=$(grep -E "^${k//./\\.}: " lang/en.md | head -1 | grep -oE '\{[a-z_]+' | sort -u | tr '\n' ' ')
      pl=$(grep -E "^${k//./\\.}: " "lang/$l.md" | head -1 | grep -oE '\{[a-z_]+' | sort -u | tr '\n' ' ')
      [ "$pe" = "$pl" ] || report "lang: key '$k' has different placeholders in en.md and $l.md"
    done < <(printf '%s\n' "$ken")
  done
  for l in "${langs[@]}"; do
    while IFS= read -r h; do report "lang: empty value $h"; done < <(grep -nE "$keyre:[[:space:]]*$" "lang/$l.md")
  done
fi

# Check 10: every lang key a skill, base-layer file or config example names exists.
# A key is a backticked dotted token under one of the lang namespaces. The operation
# names of tasks.md (`project.create`, `inbox.add` ...) share prefixes with keys and are
# skipped; `*.md` tokens are files; a token ending in `.*` names a group of keys and
# needs at least one member.
nsre='(project|common|area|resource|note|task|count|inbox|archive|overview|list|areas|lint|init)'
if [ -f lang/en.md ]; then
  while IFS=: read -r f ln tok; do
    tok=${tok//\`/}
    case "$tok" in *.md) continue ;; esac
    case " $ops " in *" $tok "*) continue ;; esac
    if [ "${tok%.\*}" != "$tok" ]; then
      grep -qE "^${tok%.\*}\." lang/en.md || report "lang-key: $f:$ln names $tok, no such keys in lang/en.md"
    else
      grep -qE "^${tok//./\\.}: " lang/en.md || report "lang-key: $f:$ln names $tok, not in lang/en.md"
    fi
  done < <(grep -noE "\`${nsre}(\.[a-z0-9_]+)+(\.\*)?\`" skills/*/SKILL.md para/*.md para/adapters/*.md config.example/*.md README.md)
fi

# Check 11: the seed templates exist for both languages with the same frontmatter keys
# and the same number of headings, and every section heading a lang key names is in that
# language's set of templates.
for t in Project Area Resource Note Task; do
  for l in "${langs[@]}"; do
    [ -f "templates/$l/$t.md" ] || { report "templates: templates/$l/$t.md does not exist"; continue; }
    [ "$l" = en ] && continue
    fm='/^---$/{n++; next} n==1 && /^[a-z_]+:/ {sub(/:.*/,""); print}'
    [ "$(awk "$fm" "templates/$l/$t.md")" = "$(awk "$fm" "templates/en/$t.md")" ] \
      || report "templates: $t.md frontmatter keys differ between $l and en"
    [ "$(grep -c '^# ' "templates/$l/$t.md")" = "$(grep -c '^# ' "templates/en/$t.md")" ] \
      || report "templates: $t.md has a different number of headings in $l and en"
  done
done
for l in "${langs[@]}"; do
  [ -f "lang/$l.md" ] || continue
  for k in project.goal project.problem project.value project.expected_result project.scope project.dod common.links \
           area.current_state area.notes resource.summary resource.own_thoughts note.essence note.open_questions; do
    v=$(sed -nE "s/^${k//./\\.}: //p" "lang/$l.md")
    [ -n "$v" ] || continue
    cat templates/$l/*.md 2>/dev/null | grep -qxF "# $v" || report "templates: no template in templates/$l has the heading '# $v' ($k)"
  done
done

# Check 12: init's inputs. The CLAUDE.md block carries each marker exactly once, begin
# before end; migrations.md states the current SCHEMA once and has a section for it.
if [ -f para/claude-md-block.md ]; then
  nb=$(grep -cxF '<!-- para:begin -->' para/claude-md-block.md)
  ne=$(grep -cxF '<!-- para:end -->' para/claude-md-block.md)
  lb=$(grep -nxF '<!-- para:begin -->' para/claude-md-block.md | cut -d: -f1)
  le=$(grep -nxF '<!-- para:end -->' para/claude-md-block.md | cut -d: -f1)
  if [ "$nb" != 1 ] || [ "$ne" != 1 ]; then
    report "claude-md-block: each marker must appear exactly once on a line of its own"
  elif [ "$lb" -ge "$le" ]; then
    report "claude-md-block: para:begin must come before para:end"
  fi
else
  report "claude-md-block: para/claude-md-block.md does not exist"
fi
if [ -f para/migrations.md ]; then
  sv=$(grep -E '^SCHEMA: [0-9]+$' para/migrations.md)
  if [ "$(printf '%s\n' "$sv" | grep -c .)" != 1 ]; then
    report "migrations: para/migrations.md must state 'SCHEMA: <n>' exactly once"
  else
    grep -qx "### ${sv#SCHEMA: }" para/migrations.md || report "migrations: no '### ${sv#SCHEMA: }' section for the current schema"
  fi
else
  report "migrations: para/migrations.md does not exist"
fi

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
