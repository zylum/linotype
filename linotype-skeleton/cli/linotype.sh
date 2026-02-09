#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$ROOT_DIR/docs"
WORK_DIR="$DOCS_DIR/work"
PLANNING_DIR="$WORK_DIR/planning"
QUEUE_DIR="$WORK_DIR/queue"
DOING_DIR="$WORK_DIR/doing"
REVIEW_DIR="$WORK_DIR/review"
DONE_DIR="$WORK_DIR/done"
BUNDLES_DIR="$ROOT_DIR/dist/bundles"
TEMPLATES_DIR="$PLANNING_DIR/_templates"

usage() {
  cat <<'USAGE'
Linotype CLI

Usage:
  cli/linotype galley new <galley-name>
  cli/linotype galley move <galley-name> planning|queue|doing|review|done
  cli/linotype galley list
  cli/linotype galley auto
  cli/linotype slug new <galley-name> <slug-name>
  cli/linotype bundle ai <galley-name>
  cli/linotype bundle project
  cli/linotype bundle review [--since 30d|7d|YYYY-WW|all] [--weekly]
  cli/linotype bundle review --weekly   # writes docs/review/weekly/YYYY-WW.md (schedule weekly)

Notes:
- galley-name: kebab-case, prefer YYYYMMDD-topic (e.g. 20260206-model-compare)
- slug-name: kebab-case, e.g. auth-login

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

  ok "Created: docs/work/planning/$galley/"
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
      echo "Generated: $(date -I)"
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

main() {
  ensure_dirs
  local cmd="${1:-}"; shift || true
  case "$cmd" in
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
        review) cmd_bundle_review "$@" ;;
        *) fail "Unknown: bundle $sub"; usage; exit 1 ;;
      esac
      ;;
    -h|--help|"") usage ;;
    *) fail "Unknown command: $cmd"; usage; exit 1 ;;
  esac
}

main "$@"
