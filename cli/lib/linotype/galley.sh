# shellcheck shell=bash

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
