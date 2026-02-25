# shellcheck shell=bash

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

  local app="linotype" area="core" include_domains=0
  while [ $# -gt 0 ]; do
    case "${1:-}" in
      --app) app="${2:-linotype}"; shift 2 ;;
      --area) area="${2:-core}"; shift 2 ;;
      --domains) include_domains=1; shift ;;
      *) break ;;
    esac
  done

  local out; out="$(learning_daily_snapshot_file "$app" "$area")"
  mkdir -p "$(dirname "$out")"

  local sig_file; sig_file="$(learning_daily_signals_file "$app" "$area")"
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

    if [ "$include_domains" -eq 1 ]; then
      echo
      echo "## Domain memory"
      echo
      if [ -d "$DOCS_DIR/domain" ]; then
        shopt -s nullglob
        local domain_files=("$DOCS_DIR/domain"/*.md)
        shopt -u nullglob
        if [ "${#domain_files[@]}" -eq 0 ]; then
          echo "- _docs/domain/ contains no .md files_"
        else
          local f
          for f in "${domain_files[@]}"; do
            [ -f "$f" ] || continue
            local rel="${f#"$ROOT_DIR/"}"
            local title
            title="$(head -n1 "$f" | sed -E 's/^#\s*//')"
            [ -n "$title" ] || title="$rel"
            echo "- ${title} (${rel})"
          done
        fi
      else
        echo "- _docs/domain/ is missing_"
      fi
    fi
  } > "$out"

  ok "Snapshot written: ${out#"$ROOT_DIR/"}"
}
