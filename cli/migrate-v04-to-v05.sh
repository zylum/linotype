#!/usr/bin/env bash
set -euo pipefail

# Linotype migration helper: v0.4 -> v0.5 (conservative)
# Default is dry-run; use --apply to execute.

MODE="dry-run"
DISABLE_WORKFLOWS=0
SEED_FROM_REVIEWS=1
APP="linotype"
AREA="core"
MAX_DONE_GALLEYS=20

while [ $# -gt 0 ]; do
  case "${1:-}" in
    --dry-run) MODE="dry-run"; shift ;;
    --apply) MODE="apply"; shift ;;
    --disable-workflows) DISABLE_WORKFLOWS=1; shift ;;
    --no-seed) SEED_FROM_REVIEWS=0; shift ;;
    --app) APP="${2:-linotype}"; shift 2 ;;
    --area) AREA="${2:-core}"; shift 2 ;;
    --max-done) MAX_DONE_GALLEYS="${2:-20}"; shift 2 ;;
    *) shift ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$ROOT_DIR/docs"

WORK_DIR="$DOCS_DIR/work"
PLANNING_DIR="$WORK_DIR/planning"
QUEUE_DIR="$WORK_DIR/queue"
DOING_DIR="$WORK_DIR/doing"
REVIEW_DIR="$WORK_DIR/review"
DONE_DIR="$WORK_DIR/done"

LEARNING_DIR="$DOCS_DIR/learning"
LEARNING_INBOX="$LEARNING_DIR/inbox"
LEARNING_SIGNALS="$LEARNING_DIR/signals"
LEARNING_PROPOSALS="$LEARNING_DIR/proposals"
LEARNING_SNAPSHOTS="$LEARNING_DIR/snapshots"
LEARNING_TEMPLATES="$LEARNING_DIR/_templates"
LEARNING_MIGRATION="$LEARNING_DIR/migration"

today_iso() { date +%Y-%m-%d; }
ts_id() { date +"%Y%m%d-%H%M%S"; }

log_lines=()
note() { log_lines+=("$1"); echo "$1"; }

in_git_repo() {
  command -v git >/dev/null 2>&1 || return 1
  git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

do_mkdir() {
  local p="$1"
  if [ -d "$p" ]; then
    note "⊘ mkdir ${p#"$ROOT_DIR/"} (exists)"
    return 0
  fi
  if [ "$MODE" = "dry-run" ]; then
    note "→ mkdir -p ${p#"$ROOT_DIR/"}"
    return 0
  fi
  mkdir -p "$p"
  note "✓ mkdir -p ${p#"$ROOT_DIR/"}"
}

do_write_if_missing() {
  local path="$1"
  shift
  if [ -f "$path" ]; then
    note "⊘ write ${path#"$ROOT_DIR/"} (exists)"
    return 0
  fi
  if [ "$MODE" = "dry-run" ]; then
    note "→ write ${path#"$ROOT_DIR/"}"
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  # shellcheck disable=SC2129
  cat > "$path" <<EOF
$*
EOF
  note "✓ wrote ${path#"$ROOT_DIR/"}"
}

do_move_file() {
  local src="$1" dest="$2"
  if [ ! -f "$src" ]; then
    note "⊘ move ${src#"$ROOT_DIR/"} (missing)"
    return 0
  fi
  if [ -e "$dest" ]; then
    note "⚠ skip move ${src#"$ROOT_DIR/"} -> ${dest#"$ROOT_DIR/"} (dest exists)"
    return 0
  fi
  if [ "$MODE" = "dry-run" ]; then
    note "→ move ${src#"$ROOT_DIR/"} -> ${dest#"$ROOT_DIR/"}"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  if in_git_repo; then
    git -C "$ROOT_DIR" mv "$src" "$dest"
  else
    mv "$src" "$dest"
  fi
  note "✓ moved ${src#"$ROOT_DIR/"} -> ${dest#"$ROOT_DIR/"}"
}

ensure_stage_dirs() {
  local ok=1
  for d in "$PLANNING_DIR" "$QUEUE_DIR" "$DOING_DIR" "$REVIEW_DIR" "$DONE_DIR"; do
    if [ ! -d "$d" ]; then ok=0; fi
  done
  if [ "$ok" -eq 0 ]; then
    note "⚠ expected stage dirs missing under docs/work/. Continuing, but scan may be partial."
  fi
}

ensure_learning_dirs() {
  do_mkdir "$LEARNING_INBOX"
  do_mkdir "$LEARNING_SIGNALS"
  do_mkdir "$LEARNING_PROPOSALS"
  do_mkdir "$LEARNING_SNAPSHOTS"
  do_mkdir "$LEARNING_TEMPLATES"
  do_mkdir "$LEARNING_MIGRATION"

  do_write_if_missing "$LEARNING_TEMPLATES/reflection.md" "# Reflection

Date:
App:
Area:
Source:

## What happened
- 

## What hurt (friction, failures, confusion)
- 

## What worked (wins, smooth paths)
- 

## Surprises
- 

## Follow-ups / hypotheses
- 
"

  do_write_if_missing "$LEARNING_TEMPLATES/signals-daily.md" "# Signals (daily)

Date:
App:
Area:

Format:
- S-### [status] [type] [app/area] -> pointer | description

Statuses:
new | planned | done | failed | deferred | noise | reopened

## Items
- 
"

  do_write_if_missing "$LEARNING_TEMPLATES/reconcile-weekly.md" "# Signals reconcile (weekly)

Week:
App:
Area:

## Carried forward (still open)
- 

## Closed this week (with evidence)
- 

## Failed attempts (needs rethink)
- 

## Deferred (intentional, with reason)
- 

## Noise (explicitly ignored, with reason)
- 
"
}

disable_workflows_if_requested() {
  [ "$DISABLE_WORKFLOWS" -eq 1 ] || return 0
  local src_dir="$ROOT_DIR/.github/workflows"
  local dest_dir="$ROOT_DIR/.github-disabled/workflows"
  if [ ! -d "$src_dir" ]; then
    note "⊘ workflows: .github/workflows/ not present"
    return 0
  fi
  do_mkdir "$dest_dir"
  shopt -s nullglob
  local f
  for f in "$src_dir"/*; do
    [ -f "$f" ] || continue
    do_move_file "$f" "$dest_dir/$(basename "$f")"
  done
  shopt -u nullglob
}

is_galley_dir_name_ignored() {
  local name="$1"
  case "$name" in
    _templates|weekly|"<galley-name>") return 0 ;;
  esac
  return 1
}

ensure_galley_stubs() {
  local gdir="$1"
  do_mkdir "$gdir/slugs"

  local gname; gname="$(basename "$gdir")"
  do_write_if_missing "$gdir/README.md" "# ${gname}

Status: migrated stub (created by v0.5 migration helper)
"
  do_write_if_missing "$gdir/run-sheet.md" "# Run Sheet

Status: migrated stub (created by v0.5 migration helper)

- Slug order:
  - (add slugs under slugs/)

- Acceptance checks:
  - (add checks)
"
  do_write_if_missing "$gdir/review.md" "# Review

Status: migrated stub (created by v0.5 migration helper)

## Learnings
- 

## Reflection
- 

## Surprises
- 

## Follow-ups
- 
"
  do_write_if_missing "$gdir/context.md" "# Context

Status: migrated stub (created by v0.5 migration helper)
"
}

scan_stage() {
  local stage="$1" dir="$2"
  local count=0 created=0
  if [ ! -d "$dir" ]; then
    note "⊘ scan ${stage} (missing dir)"
    echo "0"
    return 0
  fi
  shopt -s nullglob
  local g
  for g in "$dir"/*; do
    [ -d "$g" ] || continue
    local name; name="$(basename "$g")"
    is_galley_dir_name_ignored "$name" && continue
    count=$((count + 1))
    ensure_galley_stubs "$g"
  done
  shopt -u nullglob
  note "✓ scanned ${stage}: ${count} galleys"
  echo "$count"
}

extract_review_sections() {
  # Extract short sections from review.md if headings exist.
  # Keep bounded and safe; if headings missing, return empty.
  local file="$1"
  python3 - "$file" <<'PY'
import re, sys, pathlib
path = pathlib.Path(sys.argv[1])
txt = path.read_text(encoding="utf-8", errors="ignore").splitlines()
wanted = {"Learnings","Reflection","Surprises","Follow-ups"}
out=[]
i=0
while i < len(txt):
  m = re.match(r"^##\s+(.*)\s*$", txt[i])
  if m and m.group(1).strip() in wanted:
    title=m.group(1).strip()
    out.append(f"## {title}")
    i += 1
    while i < len(txt) and not re.match(r"^##\s+", txt[i]):
      out.append(txt[i])
      i += 1
    out.append("")
    continue
  i += 1
print("\n".join(out).strip())
PY
}

seed_inbox_from_done_reviews() {
  [ "$SEED_FROM_REVIEWS" -eq 1 ] || return 0
  local d; d="$(today_iso)"
  local out="$LEARNING_INBOX/${d}__${APP}__${AREA}__reflection__seed-from-reviews.md"
  if [ -f "$out" ]; then
    note "⊘ seed inbox ${out#"$ROOT_DIR/"} (exists)"
    return 0
  fi

  # list done galleys newest-first by folder mtime (best-effort).
  if [ ! -d "$DONE_DIR" ]; then
    note "⊘ seed inbox (docs/work/done missing)"
    return 0
  fi

  shopt -s nullglob
  local galleys=()
  local g
  for g in "$DONE_DIR"/*; do
    [ -d "$g" ] || continue
    local name; name="$(basename "$g")"
    is_galley_dir_name_ignored "$name" && continue
    galleys+=("$g")
  done
  shopt -u nullglob

  if [ "${#galleys[@]}" -eq 0 ]; then
    note "⊘ seed inbox (no done galleys found)"
    return 0
  fi

  # sort by mtime descending
  IFS=$'\n' galleys=($(ls -dt "${galleys[@]}" 2>/dev/null || printf "%s\n" "${galleys[@]}"))
  unset IFS

  if [ "$MODE" = "dry-run" ]; then
    note "→ write seed inbox ${out#"$ROOT_DIR/"} (from up to ${MAX_DONE_GALLEYS} done galleys)"
    return 0
  fi

  mkdir -p "$(dirname "$out")"
  {
    echo "# Seed reflection (from done galley reviews)"
    echo
    echo "Generated: $(date +%Y-%m-%dT%H:%M:%S)"
    echo "App: ${APP}"
    echo "Area: ${AREA}"
    echo
    echo "Source: docs/work/done/*/review.md (best-effort extraction)"
    echo
  } > "$out"

  local n=0
  for g in "${galleys[@]}"; do
    [ "$n" -ge "$MAX_DONE_GALLEYS" ] && break
    local name; name="$(basename "$g")"
    local review="$g/review.md"
    [ -f "$review" ] || continue
    echo "## ${name}" >> "$out"
    echo "Path: ${review#"$ROOT_DIR/"}" >> "$out"
    echo >> "$out"
    local extracted; extracted="$(extract_review_sections "$review" || true)"
    if [ -n "${extracted// /}" ]; then
      echo "$extracted" >> "$out"
    else
      echo "_No extractable sections found. Review manually._" >> "$out"
    fi
    echo >> "$out"
    n=$((n + 1))
  done

  note "✓ seeded inbox ${out#"$ROOT_DIR/"} (count: $n)"
}

write_report() {
  local id; id="$(ts_id)"
  local out="$LEARNING_MIGRATION/${id}__v04-to-v05__report.md"
  if [ "$MODE" = "dry-run" ]; then
    note "→ write report ${out#"$ROOT_DIR/"}"
    return 0
  fi
  mkdir -p "$(dirname "$out")"
  {
    echo "# Migration report (v0.4 -> v0.5)"
    echo
    echo "Generated: $(date +%Y-%m-%dT%H:%M:%S)"
    echo "Mode: ${MODE}"
    echo "App: ${APP}"
    echo "Area: ${AREA}"
    echo "Disable workflows: ${DISABLE_WORKFLOWS}"
    echo "Seed from reviews: ${SEED_FROM_REVIEWS}"
    echo
    echo "## Actions"
    printf -- "- %s\n" "${log_lines[@]}"
  } > "$out"
  note "✓ wrote report ${out#"$ROOT_DIR/"}"
}

main() {
  note "Linotype migration helper v0.4 -> v0.5"
  note "Repo: ${ROOT_DIR}"
  note "Mode: ${MODE}"
  ensure_stage_dirs
  ensure_learning_dirs
  disable_workflows_if_requested

  scan_stage "planning" "$PLANNING_DIR" >/dev/null
  scan_stage "queue" "$QUEUE_DIR" >/dev/null
  scan_stage "doing" "$DOING_DIR" >/dev/null
  scan_stage "review" "$REVIEW_DIR" >/dev/null
  scan_stage "done" "$DONE_DIR" >/dev/null

  seed_inbox_from_done_reviews
  write_report

  note "Done."
}

main
