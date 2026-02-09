#!/usr/bin/env bash
# Linotype quick-start bootstrap: run in an empty folder to install the skeleton.
# Usage: curl -fsSL https://raw.githubusercontent.com/zylum/linotype/main/linotype-bootstrap.sh | bash
set -euo pipefail

REPO_URL="https://github.com/zylum/linotype"
BRANCH="${LINOTYPE_BRANCH:-main}"
TMP_DIR=""
SCRIPT_NAME="linotype-bootstrap.sh"

cleanup() {
  [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Linotype bootstrap (branch: $BRANCH)"
TMP_DIR="$(mktemp -d)"
echo "→ Fetching Linotype..."
if command -v git &>/dev/null; then
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR/repo"
  SRC="$TMP_DIR/repo"
else
  (cd "$TMP_DIR" && curl -fsSL "${REPO_URL}/archive/refs/heads/${BRANCH}.tar.gz" -o repo.tar.gz && tar xzf repo.tar.gz)
  # GitHub tarball expands to linotype-<branch> (e.g. linotype-main)
  SRC="$TMP_DIR/linotype-${BRANCH}"
  [[ -d "$SRC" ]] || SRC="$TMP_DIR/$(ls -1 "$TMP_DIR" 2>/dev/null | grep -E '^linotype-' | head -n1)"
  [[ -d "$SRC" ]] || { echo "✗ Could not find extracted repo."; exit 1; }
fi

if [[ ! -d "${SRC}/linotype-skeleton" ]]; then
  echo "✗ Skeleton not found in repo (expected linotype-skeleton/)."
  exit 1
fi

echo "→ Installing skeleton..."
cp -r "${SRC}/linotype-skeleton/." .

# Root wrapper so ./linotype.sh works after bootstrap
cat > linotype.sh <<'WRAPPER'
#!/usr/bin/env bash
exec "$(dirname "$0")/cli/linotype.sh" "$@"
WRAPPER
chmod +x linotype.sh

echo "✓ Bootstrap complete."
echo "  Run: ./linotype.sh init"
echo "  Then: ./linotype.sh galley list"
