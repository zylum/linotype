#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="docs/work"
PLANNING="$WORK_DIR/planning"
DOING="$WORK_DIR/doing"
REVIEW="$WORK_DIR/review"
DONE="$WORK_DIR/done"

usage () {
  cat <<'USAGE'
Linotype workflow

Usage:
  ./linotype.sh init
  ./linotype.sh start SLUG-002.first-vertical-slice
  ./linotype.sh check SLUG-002.first-vertical-slice
  ./linotype.sh review SLUG-002.first-vertical-slice
  ./linotype.sh done SLUG-002.first-vertical-slice
USAGE
}

ensure_dirs () {
  mkdir -p "$PLANNING" "$DOING" "$REVIEW" "$DONE"
}

slug_file () {
  local slug="$1"
  echo "${slug}.md"
}

find_slug_path () {
  local slug="$1"
  local f
  f="$(slug_file "$slug")"
  for d in "$PLANNING" "$DOING" "$REVIEW" "$DONE"; do
    if [ -f "$d/$f" ]; then
      echo "$d/$f"
      return 0
    fi
  done
  return 1
}

require_file () {
  local path="$1"
  if [ ! -f "$path" ]; then
    echo "Missing required file: $path" >&2
    return 1
  fi
}

proof_present () {
  local path="$1"
  grep -q "^## Proof" "$path" || return 1
  grep -Eq "^- (URL|Screenshot|Commit / diff|Test output):[[:space:]]*[^[:space:]].+" "$path" && return 0
  return 1
}

check_slug_basics () {
  local slug="$1"
  local slug_path
  slug_path="$(find_slug_path "$slug" 2>/dev/null || true)"
  if [ -z "${slug_path:-}" ]; then
    echo "Slug not found in planning/doing/review/done: $slug" >&2
    return 1
  fi

  require_file "docs/context/app-context.md"
  require_file "docs/capabilities/registry.yml"
  require_file "$slug_path"

  local build_notes_doing="$DOING/${slug}.build-notes.md"
  local build_notes_review="$REVIEW/${slug}.build-notes.md"
  local build_notes_done="$DONE/${slug}.build-notes.md"

  if [[ "$slug_path" == "$PLANNING/"* ]]; then
    echo "OK: slug is still in planning. Build notes not required yet."
    return 0
  fi

  if [ -f "$build_notes_doing" ] || [ -f "$build_notes_review" ] || [ -f "$build_notes_done" ]; then
    echo "OK: build notes found."
  else
    echo "Missing build notes (expected one of):" >&2
    echo "  $build_notes_doing" >&2
    echo "  $build_notes_review" >&2
    echo "  $build_notes_done" >&2
    return 1
  fi

  return 0
}

cmd_init () {
  ensure_dirs
  echo "OK: ensured docs/work/{planning,doing,review,done} exist."
}

cmd_start () {
  ensure_dirs
  local slug="${1:-}"
  if [ -z "$slug" ]; then usage; exit 1; fi

  local f
  f="$(slug_file "$slug")"

  if [ ! -f "$PLANNING/$f" ]; then
    echo "Cannot start. Missing plan in planning/: $PLANNING/$f" >&2
    exit 1
  fi

  mv "$PLANNING/$f" "$DOING/$f"
  echo "Moved to doing: $DOING/$f"

  local bn="$DOING/${slug}.build-notes.md"
  if [ ! -f "$bn" ]; then
    cat > "$bn" <<EOF
# Build Notes: ${slug}

## What shipped
-

## What changed
-

## Known gaps/follow-ups
-

## Risks/rollout notes
-

## Proof
- URL:
- Screenshot:
- Commit / diff:
- Test output:

## Links
- Code:
- Docs:
- Tests:
EOF
    echo "Created build notes: $bn"
  else
    echo "Build notes already exist: $bn"
  fi
}

cmd_check () {
  local slug="${1:-}"
  if [ -z "$slug" ]; then usage; exit 1; fi
  check_slug_basics "$slug"
  echo "OK: checks passed for $slug"
}

cmd_review () {
  ensure_dirs
  local slug="${1:-}"
  if [ -z "$slug" ]; then usage; exit 1; fi

  cmd_check "$slug"

  local f
  f="$(slug_file "$slug")"

  if [ -f "$DOING/$f" ]; then
    local bn_doing="$DOING/${slug}.build-notes.md"
    require_file "$bn_doing"

    if ! proof_present "$bn_doing"; then
      echo "Cannot move to review. Build notes must include Proof with at least one filled item:" >&2
      echo "  $bn_doing" >&2
      exit 1
    fi

    mv "$DOING/$f" "$REVIEW/$f"
    echo "Moved slug to review: $REVIEW/$f"

    mv "$bn_doing" "$REVIEW/${slug}.build-notes.md"
    echo "Moved build notes to review."
  elif [ -f "$PLANNING/$f" ]; then
    echo "Slug is still in planning. Run start first." >&2
    exit 1
  else
    echo "Slug is not in doing. Nothing to move." >&2
    exit 1
  fi
}

cmd_done () {
  ensure_dirs
  local slug="${1:-}"
  if [ -z "$slug" ]; then usage; exit 1; fi

  local f
  f="$(slug_file "$slug")"

  if [ -f "$REVIEW/$f" ]; then
    mv "$REVIEW/$f" "$DONE/$f"
    echo "Moved slug to done: $DONE/$f"
  else
    echo "Slug must be in review to complete: $REVIEW/$f" >&2
    exit 1
  fi

  local bn_review="$REVIEW/${slug}.build-notes.md"
  if [ -f "$bn_review" ]; then
    mv "$bn_review" "$DONE/${slug}.build-notes.md"
    echo "Moved build notes to done."
  fi
}

main () {
  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    init) cmd_init ;;
    start) cmd_start "$@" ;;
    check) cmd_check "$@" ;;
    review) cmd_review "$@" ;;
    done) cmd_done "$@" ;;
    -h|--help|"") usage ;;
    *) echo "Unknown command: $cmd" >&2; usage; exit 1 ;;
  esac
}

main "$@"
