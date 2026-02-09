#!/usr/bin/env bash
set -euo pipefail

MODE="init"
SRC_DIR="./bootstrap-assets"
DEST_DIR="."
VERSION_FILE=".linotype-version"

while [[ $# -gt 0 ]]; do
  case $1 in
    --check) MODE="check"; shift ;;
    --upgrade) MODE="upgrade"; shift ;;
    --reset) MODE="reset"; shift ;;
    *) shift ;;
  esac
done

echo "Linotype bootstrap - mode: $MODE"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "✗ Missing $SRC_DIR"
  echo "→ Put Linotype assets in ./bootstrap-assets (tracked in git), then rerun."
  exit 1
fi

copy_one() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ "$MODE" = "reset" || "$MODE" = "upgrade" || ! -f "$dest" ]]; then
    cp "$src" "$dest"
    echo "✓ $dest"
  else
    echo "⊘ $dest (exists)"
  fi
}

should_copy() {
  # Never overwrite work-in-progress galleys and runs.
  # Allow Linotype templates under docs/work/planning/_templates/** to bootstrap.
  local rel="$1"
  if [[ "$rel" == docs/work/* ]]; then
    if [[ "$rel" == docs/work/planning/_templates/* ]]; then
      return 0
    fi
    return 1
  fi
  return 0
}

if [[ "$MODE" = "check" ]]; then
  [[ -f "$DEST_DIR/docs/ai/_agent-rules.md" ]] && echo "✓ Linotype present" || echo "✗ Linotype missing"
  exit 0
fi

# Copy everything except docs/work/** (never overwrite work),
# but allow docs/work/planning/_templates/** (safe bootstrap assets).
while IFS= read -r src; do
  rel="${src#"$SRC_DIR/"}"
  if ! should_copy "$rel"; then continue; fi
  copy_one "$src" "$DEST_DIR/$rel"
done < <(find "$SRC_DIR" -type f | sort)

echo "✓ Bootstrap complete"
