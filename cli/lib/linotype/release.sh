# shellcheck shell=bash

release_codename_used() {
  local movie="$1"
  [ -f "$ROOT_DIR/CHANGELOG.md" ] || return 1
  python3 - "$ROOT_DIR/CHANGELOG.md" "$movie" <<'PY'
import pathlib, sys
path, movie = sys.argv[1:]
text = pathlib.Path(path).read_text(encoding="utf-8", errors="ignore").lower()
needle = f"({movie.lower()})"
sys.exit(0 if needle in text else 1)
PY
}

cmd_release_init() {
  ensure_dirs
  local version="${1:-}" movie="${2:-}"
  if [ -z "$version" ] || [ -z "$movie" ]; then
    fail "Usage: cli/linotype release init <version> <movie>"
    exit 1
  fi

  if release_codename_used "$movie"; then
    fail "Movie codename already used in CHANGELOG: $movie"
    exit 1
  fi

  local release_file="$RELEASES_DIR/${version}.md"
  if [ -f "$release_file" ]; then
    fail "Release file exists: ${release_file#"$ROOT_DIR/"}"
    exit 1
  fi

  mkdir -p "$(dirname "$release_file")"
  cat > "$release_file" <<EOF
# Release ${version} — ${movie}

## Summary
- Codename locked: **${movie}**
- Why this release matters:

## Highlights
- 

## Galley / CLI changes
- 

## Domain updates
- 

## Verification
- 
EOF

  ok "Release file created: ${release_file#"$ROOT_DIR/"}"
  warn "Remember to add an entry to CHANGELOG.md referencing the release file."
}

release_heading_for_section() {
  local key="${1:-highlights}"
  case "$key" in
    highlights) printf "Highlights" ;;
    galley|cli|changes) printf "Galley / CLI changes" ;;
    domain|domains) printf "Domain updates" ;;
    verification|verify) printf "Verification" ;;
    summary) printf "Summary" ;;
    *) return 1 ;;
  esac
}

cmd_release_note() {
  ensure_dirs
  local version="${1:-}" text="${2:-}" section_key="highlights"
  shift 2 || true
  if [ -z "$version" ] || [ -z "$text" ]; then
    fail "Usage: cli/linotype release note <version> \"<summary>\" [--section highlights|galley|domain|verification|summary]"
    exit 1
  fi

  while [ $# -gt 0 ]; do
    case "${1:-}" in
      --section) section_key="${2:-highlights}"; shift 2 ;;
      *) break ;;
    esac
  done

  local heading; heading="$(release_heading_for_section "$section_key" || true)"
  if [ -z "$heading" ]; then
    fail "Unknown section: $section_key"
    exit 1
  fi

  local release_file="$RELEASES_DIR/${version}.md"
  if [ ! -f "$release_file" ]; then
    fail "Release file not found: docs/work/releases/${version}.md (run release init first)"
    exit 1
  fi

  python3 - "$release_file" "$heading" "$text" <<'PY'
import sys, pathlib
path, heading, note = sys.argv[1:]
lines = pathlib.Path(path).read_text(encoding="utf-8", errors="ignore").splitlines()
target = f"## {heading}"
target_idx = None
for idx, line in enumerate(lines):
    if line.strip().lower() == target.lower():
        target_idx = idx
        break
if target_idx is None:
    lines.append(target)
    lines.append("")
    target_idx = len(lines) - 2

insert_idx = target_idx + 1
if insert_idx >= len(lines):
    lines.append("")
    insert_idx = len(lines) - 1
if lines[insert_idx].strip() != "":
    lines.insert(insert_idx, "")
    insert_idx += 1

end_idx = insert_idx
while end_idx < len(lines) and not lines[end_idx].startswith("## "):
    end_idx += 1
lines.insert(end_idx, f"- {note}")
pathlib.Path(path).write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
PY

  ok "Added release note under ${heading}: ${release_file#"$ROOT_DIR/"}"
}
