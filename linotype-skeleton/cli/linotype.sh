#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$ROOT_DIR/docs"
LEARNING_DIR="$DOCS_DIR/learning"
WORK_DIR="$DOCS_DIR/work"
PLANNING_DIR="$WORK_DIR/planning"
QUEUE_DIR="$WORK_DIR/queue"
DOING_DIR="$WORK_DIR/doing"
REVIEW_DIR="$WORK_DIR/review"
DONE_DIR="$WORK_DIR/done"
BUNDLES_DIR="$ROOT_DIR/dist/bundles"
TEMPLATES_DIR="$PLANNING_DIR/_templates"

LEARNING_INBOX_DIR="$LEARNING_DIR/inbox"
LEARNING_SIGNALS_DIR="$LEARNING_DIR/signals"
LEARNING_PROPOSALS_DIR="$LEARNING_DIR/proposals"
LEARNING_SNAPSHOTS_DIR="$LEARNING_DIR/snapshots"
LEARNING_TEMPLATES_DIR="$LEARNING_DIR/_templates"

usage() {
  cat <<'USAGE'
Linotype CLI

Usage:
  cli/linotype init
  cli/linotype galley new <galley-name>
  cli/linotype galley move <galley-name> planning|queue|doing|review|done
  cli/linotype galley list
  cli/linotype galley auto
  cli/linotype slug new <galley-name> <slug-name>
  cli/linotype exec opencode <galley-name> [--copy]
  cli/linotype bundle ai <galley-name>
  cli/linotype bundle project
  cli/linotype bundle review [--since 30d|7d|YYYY-WW|all] [--weekly]
  cli/linotype bundle snapshot [--app <app>] [--area <area>]
  cli/linotype signal add "<description>" [--app <app>] [--area <area>] [--type <type>] [--status <status>] [--pointer <pointer>]
  cli/linotype signal normalise [--app <app>] [--area <area>]
  cli/linotype bundle review --weekly   # writes docs/review/weekly/YYYY-WW.md (schedule weekly)

Notes:
- galley-name: kebab-case, prefer YYYYMMDD-topic (e.g. 20260206-model-compare)
- slug-name: kebab-case, e.g. auth-login
-
Learning layer:
- Raw reflections can be dropped into docs/learning/inbox/ (any format).
- Signals are written to docs/learning/signals/ using YYYY-MM-DD__app__area__signals__daily.md.

USAGE
}

ok() { printf "✓ %s
" "$1"; }
warn() { printf "⚠ %s
" "$1"; }
fail() { printf "✗ %s
" "$1" >&2; }

ensure_dirs() {
  mkdir -p "$PLANNING_DIR" "$QUEUE_DIR" "$DOING_DIR" "$REVIEW_DIR" "$DONE_DIR" "$BUNDLES_DIR"
  mkdir -p "$LEARNING_INBOX_DIR" "$LEARNING_SIGNALS_DIR" "$LEARNING_PROPOSALS_DIR" "$LEARNING_SNAPSHOTS_DIR" "$LEARNING_TEMPLATES_DIR"
}

kebab_case() {
  local s="$1"
  s="$(printf "%s" "$s" | tr '[:upper:]' '[:lower:]')"
  s="$(printf "%s" "$s" | sed -E 's/[ _]+/-/g; s/[^a-z0-9-]+/-/g; s/-+/-/g; s/^-|-$//g')"
  printf "%s" "$s"
}

now_slug_id() { date +"SLUG-%Y%m%d-%H%M"; }

render_template() {
  local src="$1" dest="$2" galley="$3" slug_id="${4:-}" slug_name="${5:-}"
  mkdir -p "$(dirname "$dest")"
  if [ -f "$src" ]; then
    sed -e "s/{{GALLEY_NAME}}/${galley}/g"         -e "s/{{SLUG_ID}}/${slug_id}/g"         -e "s/{{SLUG_NAME}}/${slug_name}/g"         "$src" > "$dest"
  else
    cat > "$dest" <<EOF
# ${galley}
EOF
  fi
}

today_iso() { date +%Y-%m-%d; }

learning_daily_signals_file() {
  local app="${1:-linotype}" area="${2:-core}" d
  d="$(today_iso)"
  printf "%s/%s__%s__%s__signals__daily.md" "$LEARNING_SIGNALS_DIR" "$d" "$app" "$area"
}

learning_daily_snapshot_file() {
  local app="${1:-linotype}" area="${2:-core}" d
  d="$(today_iso)"
  printf "%s/%s__%s__%s__snapshot__daily.md" "$LEARNING_SNAPSHOTS_DIR" "$d" "$app" "$area"
}

signal_next_id() {
  # Find max S-### across signals + weekly reconcile files; default S-001.
  local max="0"
  local f
  shopt -s nullglob
  for f in "$LEARNING_SIGNALS_DIR"/*.md "$LEARNING_SIGNALS_DIR"/*.markdown "$LEARNING_SIGNALS_DIR"/*.txt; do
    [ -f "$f" ] || continue
    # Extract numbers from S-### patterns.
    local m
    m="$(grep -Eo 'S-[0-9]{3,}' "$f" 2>/dev/null | sed -E 's/^S-//' | sort -n | tail -n1 || true)"
    [ -n "$m" ] || continue
    if [ "$m" -gt "$max" ] 2>/dev/null; then max="$m"; fi
  done
  shopt -u nullglob
  printf "S-%03d" $((max + 1))
}

ensure_learning_templates() {
  # Install minimal templates if missing (safe, idempotent).
  local t
  t="$LEARNING_TEMPLATES_DIR/signals-daily.md"
  if [ ! -f "$t" ]; then
    cat > "$t" <<'T'
# Signals (daily)

Date:
App:
Area:

Format:
- S-### [status] [type] [app/area] -> pointer | description

Statuses:
new | planned | done | failed | deferred | noise | reopened
T
  fi

  t="$LEARNING_TEMPLATES_DIR/snapshot-daily.md"
  if [ ! -f "$t" ]; then
    cat > "$t" <<'T'
# Snapshot (daily)

Purpose: paste into ChatGPT/agents to avoid planning drift.

Includes:
- Galley stages summary
- Latest signals
- Recent review learnings (weekly, if present)
T
  fi
}

find_galley_dir() {
  local galley="$1" d
  for d in "$PLANNING_DIR" "$QUEUE_DIR" "$DOING_DIR" "$REVIEW_DIR" "$DONE_DIR"; do
    if [ -d "$d/$galley" ]; then
      printf "%s" "$d/$galley"
      return 0
    fi
  done
  return 1
}

galley_stage_of_dir() {
  local gdir="$1"
  case "$gdir" in
    "$PLANNING_DIR"/*) printf "planning" ;;
    "$QUEUE_DIR"/*) printf "queue" ;;
    "$DOING_DIR"/*) printf "doing" ;;
    "$REVIEW_DIR"/*) printf "review" ;;
    "$DONE_DIR"/*) printf "done" ;;
    *) printf "unknown" ;;
  esac
}

slug_header_field() {
  local file="$1" key="$2"
  # Extract a simple "key: value" from the first ~60 lines (cheap and good enough).
  awk -v k="$key" '
    NR>60 { exit }
    {
      # normalise Windows CR if present
      gsub(/\r$/, "")
      if (tolower($0) ~ "^" tolower(k) ":[[:space:]]*") {
        sub("^[^:]+:[[:space:]]*", "", $0)
        print $0
        exit
      }
    }
  ' "$file" 2>/dev/null || true
}

cmd_exec_opencode() {
  ensure_dirs
  local galley_raw="${1:-}"
  shift || true
  if [ -z "$galley_raw" ]; then
    fail "Usage: cli/linotype exec opencode <galley-name> [--copy]"
    exit 1
  fi

  local copy=0
  while [ $# -gt 0 ]; do
    case "${1:-}" in
      --copy) copy=1; shift ;;
      *) break ;;
    esac
  done

  local galley; galley="$(kebab_case "$galley_raw")"
  local gdir; gdir="$(find_galley_dir "$galley" || true)"
  if [ -z "${gdir:-}" ]; then fail "Galley not found: $galley"; exit 1; fi

  local stage; stage="$(galley_stage_of_dir "$gdir")"
  if [ "$stage" != "queue" ]; then
    warn "Galley is in $stage (preferred: queue). Proceeding."
  fi

  local run_sheet="$gdir/run-sheet.md"
  if [ ! -f "$run_sheet" ]; then
    warn "Missing run-sheet.md in ${gdir#"$ROOT_DIR/"}. Executor brief will be generated from slugs only."
  fi

  # Collect slug files (exclude README.md)
  shopt -s nullglob
  local slugs=()
  local s
  for s in "$gdir"/slugs/*.md; do
    [ -f "$s" ] || continue
    [ "$(basename "$s")" = "README.md" ] && continue
    slugs+=("$s")
  done
  shopt -u nullglob

  if [ "${#slugs[@]}" -eq 0 ]; then
    warn "No slugs found under ${gdir#"$ROOT_DIR/"}/slugs/"
  fi

  # Build brief to stdout (optionally copied).
  local brief
  brief="$(
    {
      echo "# Executor brief (generated by linotype)"
      echo
      echo "Galley: $galley"
      echo "Stage: $stage"
      echo "Galley dir: ${gdir#"$ROOT_DIR/"}"
      echo
      echo "## Execution contract"
      echo "- Execute slugs in order without waiting for confirmation."
      echo "- Stop only when:"
      echo "  - blocked by ambiguity that changes behaviour"
      echo "  - acceptance checks fail and cannot be fixed safely"
      echo "  - a decision marked gated is reached"
      echo "- If not blocked: make the safest minimal assumption and record an open question in review.md or the slug."
      echo
      echo "## Branch, isolation, commits"
      echo "- One branch per galley; prefer a dedicated worktree."
      echo "- Commit after each slug:"
      echo "  - slug: slug:<slug-name> done - <summary> #galley:$galley"
      echo "  - galley: galley:$galley ready for review - <summary>"
      echo

      if [ -f "$run_sheet" ]; then
        echo "## Run Sheet"
        echo
        cat "$run_sheet"
        echo
      fi

      echo "## Slugs (in filesystem order)"
      echo
      local i=1
      local f
      for f in "${slugs[@]}"; do
        local base; base="$(basename "$f")"
        local autonomy; autonomy="$(slug_header_field "$f" "autonomy" | head -n1)"
        local purpose; purpose="$(slug_header_field "$f" "purpose" | head -n1)"
        [ -z "$autonomy" ] && autonomy="continuous"
        echo "${i}. ${base} (autonomy: ${autonomy})"
        if [ -n "$purpose" ]; then
          echo "   - purpose: $purpose"
        fi
        echo "   - file: ${f#"$ROOT_DIR/"}"
        i=$((i + 1))
      done
      echo
      echo "## Notes for the executor tool"
      echo "- Work within allowed paths and the active galley scope."
      echo "- Do not refactor unrelated code."
    } | cat
  )"

  if [ "$copy" -eq 1 ]; then
    if command -v pbcopy >/dev/null 2>&1; then
      printf "%s" "$brief" | pbcopy
      ok "Copied executor brief to clipboard (pbcopy)"
      return 0
    fi
    if command -v xclip >/dev/null 2>&1; then
      printf "%s" "$brief" | xclip -selection clipboard
      ok "Copied executor brief to clipboard (xclip)"
      return 0
    fi
    warn "No clipboard tool found (pbcopy/xclip). Printing to stdout instead."
  fi

  printf "%s\n" "$brief"
}

cmd_galley_new() {
  ensure_dirs
  local galley_raw="${1:-}"
  if [ -z "$galley_raw" ]; then fail "Missing <galley-name>"; usage; exit 1; fi

  local galley; galley="$(kebab_case "$galley_raw")"
  local galley_dir="$PLANNING_DIR/$galley"
  if [ -d "$galley_dir" ]; then fail "Galley exists: $galley_dir"; exit 1; fi

  mkdir -p "$galley_dir/slugs"
  render_template "$TEMPLATES_DIR/galley/README.md"  "$galley_dir/README.md"  "$galley"
  render_template "$TEMPLATES_DIR/galley/context.md" "$galley_dir/context.md" "$galley"
  render_template "$TEMPLATES_DIR/galley/review.md"  "$galley_dir/review.md"  "$galley"
  render_template "$TEMPLATES_DIR/galley/run-sheet.md" "$galley_dir/run-sheet.md" "$galley"

  ok "Created: docs/work/planning/$galley/"
}

cmd_init() {
  ensure_dirs
  # SLUG-001: two variants (bootstrap = new product, index = existing product); SLUG-002: first vertical slice
  local starters=( "slug-001-bootstrap-linotype" "slug-001-index-linotype" "slug-002-first-vertical-slice" )
  local g
  for g in "${starters[@]}"; do
    if [ ! -d "$PLANNING_DIR/$g" ]; then
      cmd_galley_new "$g"
    else
      echo "⊘ $g (exists)"
    fi
  done
  ok "Init complete. Starter galleys: ${starters[*]}"
}

cmd_galley_move() {
  ensure_dirs
  local galley_raw="${1:-}" stage="${2:-}"
  if [ -z "$galley_raw" ] || [ -z "$stage" ]; then
    fail "Usage: cli/linotype galley move <galley-name> planning|queue|doing|review|done"
    exit 1
  fi

  local galley; galley="$(kebab_case "$galley_raw")"
  local src; src="$(find_galley_dir "$galley" || true)"
  if [ -z "${src:-}" ]; then fail "Galley not found: $galley"; exit 1; fi

  local dest_root
  case "$stage" in
    planning) dest_root="$PLANNING_DIR" ;;
    queue) dest_root="$QUEUE_DIR" ;;
    doing) dest_root="$DOING_DIR" ;;
    review) dest_root="$REVIEW_DIR" ;;
    done) dest_root="$DONE_DIR" ;;
    *) fail "Unknown stage: $stage"; exit 1 ;;
  esac

  local dest="$dest_root/$galley"
  if [ -d "$dest" ]; then fail "Destination exists: $dest"; exit 1; fi

  mv "$src" "$dest"
  ok "Moved galley to $stage: docs/work/$stage/$galley"
}

cmd_galley_list() {
  ensure_dirs
  local name
  printf "planning:\n"
  shopt -s nullglob
  for g in "$PLANNING_DIR"/*/; do
    [ -d "$g" ] || continue
    name="$(basename "$g")"
    case "$name" in _templates|"<galley-name>") continue ;; esac
    printf "  %s\n" "$name"
  done
  printf "queue (ready for pickup):\n"
  for g in "$QUEUE_DIR"/*/; do
    [ -d "$g" ] || continue
    printf "  %s\n" "$(basename "$g")"
  done
  printf "doing (active):\n"
  for g in "$DOING_DIR"/*/; do
    [ -d "$g" ] || continue
    printf "  %s\n" "$(basename "$g")"
  done
  printf "review:\n"
  for g in "$REVIEW_DIR"/*/; do
    [ -d "$g" ] || continue
    name="$(basename "$g")"
    [ "$name" = "weekly" ] && continue
    printf "  %s\n" "$name"
  done
  printf "done:\n"
  for g in "$DONE_DIR"/*/; do
    [ -d "$g" ] || continue
    printf "  %s\n" "$(basename "$g")"
  done
  shopt -u nullglob
}

slug_is_done() {
  local f="$1"
  grep -qiE 'state:\s*done|^\s*-\s*\[\s*x\s*\]|✓' "$f" 2>/dev/null
}

cmd_galley_auto() {
  ensure_dirs
  local moved=0
  shopt -s nullglob

  # planning → doing: if galley has any slug files (excluding README)
  for g in "$PLANNING_DIR"/*/; do
    [ -d "$g" ] || continue
    local galley; galley="$(basename "$g")"
    case "$galley" in _templates|"<galley-name>") continue ;; esac
    local slug_count=0
    for s in "$g"slugs/*.md; do
      [ -f "$s" ] && [ "$(basename "$s")" != "README.md" ] && slug_count=$((slug_count + 1))
    done
    if [ "$slug_count" -gt 0 ]; then
      mv "$g" "$DOING_DIR/$galley"
      ok "planning → doing: $galley (has $slug_count slug(s))"
      moved=$((moved + 1))
    fi
  done

  # doing → review: if all slugs have a done marker
  for g in "$DOING_DIR"/*/; do
    [ -d "$g" ] || continue
    local galley; galley="$(basename "$g")"
    local total=0 done_count=0
    for s in "$g"slugs/*.md; do
      [ -f "$s" ] || continue
      [ "$(basename "$s")" = "README.md" ] && continue
      total=$((total + 1))
      if slug_is_done "$s"; then done_count=$((done_count + 1)); fi
    done
    if [ "$total" -gt 0 ] && [ "$total" -eq "$done_count" ]; then
      mv "$g" "$REVIEW_DIR/$galley"
      ok "doing → review: $galley (all $total slug(s) done)"
      moved=$((moved + 1))
      local review_md="$REVIEW_DIR/$galley/review.md"
      if [ -f "$review_md" ] && ! grep -q '## Learnings' "$review_md" 2>/dev/null; then
        warn "review.md lacks ## Learnings — add before closing galley"
      fi
    fi
  done

  shopt -u nullglob
  [ "$moved" -eq 0 ] && ok "No galleys to move"
}

cmd_slug_new() {
  ensure_dirs
  local galley_raw="${1:-}" slug_raw="${2:-}"
  if [ -z "$galley_raw" ] || [ -z "$slug_raw" ]; then
    fail "Usage: cli/linotype slug new <galley-name> <slug-name>"
    exit 1
  fi

  local galley slug_name; galley="$(kebab_case "$galley_raw")"; slug_name="$(kebab_case "$slug_raw")"
  local gdir; gdir="$(find_galley_dir "$galley" || true)"
  if [ -z "${gdir:-}" ]; then fail "Galley not found: $galley"; exit 1; fi

  local slug_id; slug_id="$(now_slug_id)"
  local fname="${slug_id}-${slug_name}.md"
  local slug_path="$gdir/slugs/$fname"
  if [ -f "$slug_path" ]; then fail "Slug exists: $slug_path"; exit 1; fi

  render_template "$TEMPLATES_DIR/slug/slug.md" "$slug_path" "$galley" "$slug_id" "$slug_name"
  ok "Created slug: ${slug_path#"$ROOT_DIR/"}"
}

cmd_bundle_ai() {
  ensure_dirs
  local galley_raw="${1:-}"
  if [ -z "$galley_raw" ]; then fail "Usage: cli/linotype bundle ai <galley-name>"; exit 1; fi

  local galley; galley="$(kebab_case "$galley_raw")"
  local gdir; gdir="$(find_galley_dir "$galley" || true)"
  if [ -z "${gdir:-}" ]; then fail "Galley not found: $galley"; exit 1; fi

  local out_dir="$BUNDLES_DIR/${galley}-ai"
  rm -rf "$out_dir"
  mkdir -p "$out_dir"

  for f in architecture overview glossary; do
    if [ -f "$DOCS_DIR/$f.md" ]; then
      cp "$DOCS_DIR/$f.md" "$out_dir/docs-$f.md"
      ok "Bundled: docs-$f.md"
    else
      warn "Missing: docs/$f.md"
    fi
  done

  if [ -f "$gdir/README.md" ]; then cp "$gdir/README.md" "$out_dir/${galley}-README.md"; ok "Bundled: ${galley}-README.md"; else warn "Missing: $gdir/README.md"; fi
  if [ -f "$gdir/context.md" ]; then cp "$gdir/context.md" "$out_dir/${galley}-context.md"; ok "Bundled: ${galley}-context.md"; else warn "Missing: $gdir/context.md"; fi

  ok "AI bundle ready: ${out_dir#"$ROOT_DIR/"}"
}

# Project-context bundle: key docs in one folder for ChatGPT / external chat (zip and drop).
# Output: dist/bundles/project-context/ with numbered files for suggested reading order.
cmd_bundle_project() {
  ensure_dirs
  local out_dir="$BUNDLES_DIR/project-context"
  rm -rf "$out_dir"
  mkdir -p "$out_dir"

  local pairs="
    docs/overview.md:01-overview.md
    docs/architecture.md:02-architecture.md
    docs/glossary.md:03-glossary.md
    docs/shared-standards.md:04-shared-standards.md
    docs/domain/index.md:05-domain-index.md
    docs/AGENTS.md:06-agents.md
    README.md:07-readme.md
  "
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    local src="${line%%:*}" dest="${line##*:}"
    if [ -f "$ROOT_DIR/$src" ]; then
      cp "$ROOT_DIR/$src" "$out_dir/$dest"
      ok "Bundled: $dest"
    else
      warn "Missing: $src"
    fi
  done <<< "$pairs"

  cat > "$out_dir/README.md" <<'BUNDLEREADME'
# Aviary project context

Drop this folder into ChatGPT (or another chat): upload the folder or paste file contents for full project context.

**Suggested reading order** (file prefix): 01-overview → 02-architecture → 03-glossary → 04-shared-standards → 05-domain-index → 06-agents → 07-readme.

To pack for upload: zip this directory, then attach the zip or add files to your chat.
BUNDLEREADME
  ok "Wrote: project-context/README.md (usage instructions)"

  ok "Project bundle ready: ${out_dir#"$ROOT_DIR/"}. Zip it to drop into ChatGPT."
}

extract_sections_py() {
  python3 - "$1" "$2" <<'PY'
import re, sys, pathlib
src, dest = sys.argv[1], sys.argv[2]
lines = pathlib.Path(src).read_text(encoding="utf-8", errors="ignore").splitlines()
wanted = {"Learnings","Reflection","Surprises","Follow-ups"}
out = []
i = 0
while i < len(lines):
    m = re.match(r"^##\s+(.*)\s*$", lines[i])
    if m and m.group(1).strip() in wanted:
        title = m.group(1).strip()
        out.append(f"## {title}")
        i += 1
        while i < len(lines) and not re.match(r"^##\s+", lines[i]):
            out.append(lines[i])
            i += 1
        out.append("")
        continue
    i += 1
pathlib.Path(dest).write_text("\n".join(out).strip() + "\n", encoding="utf-8")
PY
}

cmd_bundle_review() {
  ensure_dirs
  local since="all" weekly=0
  while [ $# -gt 0 ]; do
    case "${1:-}" in
      --weekly) weekly=1; since="7d"; shift ;;
      --since) since="${2:-all}"; shift 2 ;;
      *) break ;;
    esac
  done

  if [ "$weekly" -eq 1 ]; then
    mkdir -p "$REVIEW_DIR/weekly"
    local week_id; week_id="$(date +%G-W%V)"
    local out_file="$REVIEW_DIR/weekly/${week_id}.md"
    {
      echo "# Weekly review ${week_id}"
      echo "Generated: $(today_iso)"
      echo ""
    } > "$out_file"
    shopt -s nullglob
    for g in "$DONE_DIR"/*; do
      [ -d "$g" ] || continue
      local galley; galley="$(basename "$g")"
      local review="$g/review.md"
      if [ ! -f "$review" ]; then continue; fi
      local tmp="${out_file}.${galley}.tmp"
      extract_sections_py "$review" "$tmp"
      if [ -s "$tmp" ]; then
        echo "## ${galley}" >> "$out_file"
        cat "$tmp" >> "$out_file"
        echo "" >> "$out_file"
        rm -f "$tmp"
      fi
    done
    shopt -u nullglob
    ok "Weekly review written: docs/work/review/weekly/${week_id}.md"
    return 0
  fi

  local out_dir="$BUNDLES_DIR/review/$since"
  rm -rf "$out_dir"
  mkdir -p "$out_dir"

  shopt -s nullglob
  for g in "$DONE_DIR"/*; do
    [ -d "$g" ] || continue
    local galley; galley="$(basename "$g")"
    local review="$g/review.md"
    if [ ! -f "$review" ]; then warn "No review.md for $galley"; continue; fi

    local out="$out_dir/${galley}-review-learnings.md"
    {
      echo "# ${galley}"
      echo "Source: docs/work/done/${galley}/review.md"
      echo
    } > "$out"

    local tmp="${out}.tmp"
    extract_sections_py "$review" "$tmp"
    if [ -s "$tmp" ]; then
      cat "$tmp" >> "$out"
      rm -f "$tmp"
      ok "Bundled: review/$since/${galley}-review-learnings.md"
    else
      rm -f "$tmp"
      warn "No extracted sections in $galley review.md"
    fi
  done
  shopt -u nullglob

  ok "Review bundle ready: ${out_dir#"$ROOT_DIR/"}"
}

cmd_bundle_snapshot() {
  ensure_dirs
  ensure_learning_templates

  local app="linotype" area="core"
  while [ $# -gt 0 ]; do
    case "${1:-}" in
      --app) app="${2:-linotype}"; shift 2 ;;
      --area) area="${2:-core}"; shift 2 ;;
      *) break ;;
    esac
  done

  local out; out="$(learning_daily_snapshot_file "$app" "$area")"
  mkdir -p "$(dirname "$out")"

  local sig_file; sig_file="$(learning_daily_signals_file "$app" "$area")"

  # Latest weekly review file (if any).
  local latest_weekly=""
  if [ -d "$REVIEW_DIR/weekly" ]; then
    latest_weekly="$(ls -1 "$REVIEW_DIR/weekly"/*.md 2>/dev/null | sort | tail -n1 || true)"
  fi

  {
    echo "# Daily snapshot"
    echo
    echo "Generated: $(date +%Y-%m-%dT%H:%M:%S)"
    echo "App: ${app}"
    echo "Area: ${area}"
    echo
    echo "## Galley stages"
    echo
    # Reuse existing listing logic (printed, but not as commands).
    cmd_galley_list
    echo
    echo "## Signals (today)"
    echo
    if [ -f "$sig_file" ]; then
      cat "$sig_file"
    else
      echo "_No daily signals file found yet:_"
      echo
      echo "Expected: ${sig_file#"$ROOT_DIR/"}"
      echo "Tip: cli/linotype signal add \"<description>\" --app $app --area $area"
    fi
    echo
    echo "## Recent review learnings (latest weekly, if present)"
    echo
    if [ -n "$latest_weekly" ] && [ -f "$latest_weekly" ]; then
      echo "Source: ${latest_weekly#"$ROOT_DIR/"}"
      echo
      cat "$latest_weekly"
    else
      echo "_No weekly review file found yet._"
      echo
      echo "Tip: cli/linotype bundle review --weekly"
    fi
  } > "$out"

  ok "Snapshot written: ${out#"$ROOT_DIR/"}"
}

cmd_signal_add() {
  ensure_dirs
  ensure_learning_templates

  local desc=""
  local app="linotype" area="core" type="general" status="new" pointer="none"

  # First positional is description (quoted).
  if [ $# -gt 0 ]; then
    desc="${1:-}"; shift || true
  fi
  if [ -z "$desc" ]; then
    fail "Usage: cli/linotype signal add \"<description>\" [--app <app>] [--area <area>] [--type <type>] [--status <status>] [--pointer <pointer>]"
    exit 1
  fi

  while [ $# -gt 0 ]; do
    case "${1:-}" in
      --app) app="${2:-linotype}"; shift 2 ;;
      --area) area="${2:-core}"; shift 2 ;;
      --type) type="${2:-general}"; shift 2 ;;
      --status) status="${2:-new}"; shift 2 ;;
      --pointer) pointer="${2:-none}"; shift 2 ;;
      *) break ;;
    esac
  done

  local out; out="$(learning_daily_signals_file "$app" "$area")"
  mkdir -p "$(dirname "$out")"

  if [ ! -f "$out" ]; then
    # Seed with template header.
    cat > "$out" <<EOF
# Signals (daily)

Date: $(today_iso)
App: ${app}
Area: ${area}

Format:
- S-### [status] [type] [app/area] -> pointer | description

Statuses:
new | planned | done | failed | deferred | noise | reopened

## Items

EOF
  fi

  local sid; sid="$(signal_next_id)"
  printf -- "- %s [%s] [%s] [%s/%s] -> %s | %s\n" "$sid" "$status" "$type" "$app" "$area" "$pointer" "$desc" >> "$out"
  ok "Added signal: $sid → ${out#"$ROOT_DIR/"}"
}

cmd_signal_normalise() {
  # Minimal normaliser (non-AI): takes raw inbox notes and extracts bullet-ish lines.
  # Intended to be replaced or augmented by an AI/agent later.
  ensure_dirs
  ensure_learning_templates

  local app="linotype" area="core"
  while [ $# -gt 0 ]; do
    case "${1:-}" in
      --app) app="${2:-linotype}"; shift 2 ;;
      --area) area="${2:-core}"; shift 2 ;;
      *) break ;;
    esac
  done

  local out; out="$(learning_daily_signals_file "$app" "$area")"
  mkdir -p "$(dirname "$out")"

  if [ ! -f "$out" ]; then
    cat > "$out" <<EOF
# Signals (daily)

Date: $(today_iso)
App: ${app}
Area: ${area}

## Items

EOF
  fi

  local d; d="$(today_iso)"
  local f
  local added=0
  shopt -s nullglob
  for f in "$LEARNING_INBOX_DIR"/*"$d"*.md "$LEARNING_INBOX_DIR"/*"$d"*.txt "$LEARNING_INBOX_DIR"/*"$d"*.markdown; do
    [ -f "$f" ] || continue
    # Take lines that look like bullets or short statements, ignore headers.
    while IFS= read -r line; do
      line="${line%$'\r'}"
      # skip empty and markdown headings
      [ -z "${line// /}" ] && continue
      echo "$line" | grep -qE '^\s*#' && continue
      if echo "$line" | grep -qE '^\s*[-*]\s+'; then
        # strip bullet prefix
        local text; text="$(echo "$line" | sed -E 's/^\s*[-*]\s+//')"
        [ -z "${text// /}" ] && continue
        local sid; sid="$(signal_next_id)"
        printf -- "- %s [new] [inbox] [%s/%s] -> %s | %s\n" "$sid" "$app" "$area" "inbox:${f##*/}" "$text" >> "$out"
        added=$((added + 1))
      fi
    done < "$f"
  done
  shopt -u nullglob

  ok "Normalised inbox → signals: ${out#"$ROOT_DIR/"} (added: $added)"
}

main() {
  ensure_dirs
  local cmd="${1:-}"; shift || true
  case "$cmd" in
    init) cmd_init "$@" ;;
    galley)
      local sub="${1:-}"; shift || true
      case "$sub" in
        new) cmd_galley_new "$@" ;;
        move) cmd_galley_move "$@" ;;
        list) cmd_galley_list "$@" ;;
        auto) cmd_galley_auto "$@" ;;
        *) fail "Unknown: galley $sub"; usage; exit 1 ;;
      esac
      ;;
    slug)
      local sub="${1:-}"; shift || true
      case "$sub" in
        new) cmd_slug_new "$@" ;;
        *) fail "Unknown: slug $sub"; usage; exit 1 ;;
      esac
      ;;
    bundle)
      local sub="${1:-}"; shift || true
      case "$sub" in
        ai) cmd_bundle_ai "$@" ;;
        snapshot) cmd_bundle_snapshot "$@" ;;
        review) cmd_bundle_review "$@" ;;
        project) cmd_bundle_project "$@" ;;
        *) fail "Unknown: bundle $sub"; usage; exit 1 ;;
      esac
      ;;
    exec)
      local sub="${1:-}"; shift || true
      case "$sub" in
        opencode) cmd_exec_opencode "$@" ;;
        *) fail "Unknown: exec $sub"; usage; exit 1 ;;
      esac
      ;;
    signal)
      local sub="${1:-}"; shift || true
      case "$sub" in
        add) cmd_signal_add "$@" ;;
        normalise|normalize) cmd_signal_normalise "$@" ;;
        *) fail "Unknown: signal $sub"; usage; exit 1 ;;
      esac
      ;;
    -h|--help|"") usage ;;
    *) fail "Unknown command: $cmd"; usage; exit 1 ;;
  esac
}

main "$@"
