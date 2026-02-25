# shellcheck shell=bash

if [ -n "${LINOTYPE_COMMON_LOADED:-}" ]; then
  return 0
fi
LINOTYPE_COMMON_LOADED=1

LINOTYPE_BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LINOTYPE_BIN_DIR/../.." && pwd)"
DOCS_DIR="$ROOT_DIR/docs"
LEARNING_DIR="$DOCS_DIR/learning"
WORK_DIR="$DOCS_DIR/work"
PLANNING_DIR="$WORK_DIR/planning"
QUEUE_DIR="$WORK_DIR/queue"
DOING_DIR="$WORK_DIR/doing"
REVIEW_DIR="$WORK_DIR/review"
DONE_DIR="$WORK_DIR/done"
RELEASES_DIR="$WORK_DIR/releases"
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
  cli/linoloop <galley-name|release-id>   # run an execution loop (wrapper over linotype exec)
  cli/linotype init
  cli/linotype galley new <galley-name>
  cli/linotype galley move <galley-name> planning|queue|doing|review|done
  cli/linotype galley list
  cli/linotype galley auto
  cli/linotype slug new <galley-name> <slug-name>
  cli/linotype exec brief <galley-name> [--copy]
  cli/linotype bundle ai <galley-name>
  cli/linotype bundle project
  cli/linotype bundle review [--since 30d|7d|YYYY-WW|all] [--weekly]
  cli/linotype bundle snapshot [--app <app>] [--area <area>] [--domains]
  cli/linotype signal add "<description>" [--app <app>] [--area <area>] [--type <type>] [--status <status>] [--pointer <pointer>]
  cli/linotype signal normalise [--app <app>] [--area <area>]
  cli/linotype release init <version> <movie>
  cli/linotype release note <version> "<summary>" [--section highlights|galley|domain|verification]

Notes:
- galley-name: kebab-case, prefer YYYYMMDD-topic (e.g. 20260206-model-compare)
- slug-name: kebab-case, e.g. auth-login
- Release notes: one file per version under docs/work/releases/. Use iconic movie names once.
- Learning layer: signals live under docs/learning/signals/, snapshots under docs/learning/snapshots/.
USAGE
}

ok() { printf "\xe2\x9c\x93 %s\n" "$1"; }
warn() { printf "\xe2\x9a\xa0 %s\n" "$1"; }
fail() { printf "\xe2\x9c\x97 %s\n" "$1" >&2; }

ensure_dirs() {
  mkdir -p "$PLANNING_DIR" "$QUEUE_DIR" "$DOING_DIR" "$REVIEW_DIR" "$DONE_DIR" "$BUNDLES_DIR"
  mkdir -p "$LEARNING_INBOX_DIR" "$LEARNING_SIGNALS_DIR" "$LEARNING_PROPOSALS_DIR" "$LEARNING_SNAPSHOTS_DIR" "$LEARNING_TEMPLATES_DIR"
  mkdir -p "$RELEASES_DIR"
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
    sed -e "s/{{GALLEY_NAME}}/${galley}/g" \
        -e "s/{{SLUG_ID}}/${slug_id}/g" \
        -e "s/{{SLUG_NAME}}/${slug_name}/g" \
        "$src" > "$dest"
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
  local max="0"
  local f
  shopt -s nullglob
  for f in "$LEARNING_SIGNALS_DIR"/*.md "$LEARNING_SIGNALS_DIR"/*.markdown "$LEARNING_SIGNALS_DIR"/*.txt; do
    [ -f "$f" ] || continue
    local m
    m="$(grep -Eo 'S-[0-9]{3,}' "$f" 2>/dev/null | sed -E 's/^S-//' | sort -n | tail -n1 || true)"
    [ -n "$m" ] || continue
    if [ "$m" -gt "$max" ] 2>/dev/null; then max="$m"; fi
  done
  shopt -u nullglob
  printf "S-%03d" $((max + 1))
}

ensure_learning_templates() {
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
  awk -v k="$key" '
    NR>60 { exit }
    {
      gsub(/\r$/, "")
      if (tolower($0) ~ "^" tolower(k) ":[[:space:]]*") {
        sub("^[^:]+:[[:space:]]*", "", $0)
        print $0
        exit
      }
    }
  ' "$file" 2>/dev/null || true
}
