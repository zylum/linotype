# shellcheck shell=bash

cmd_signal_add() {
  ensure_dirs
  ensure_learning_templates

  local desc=""
  local app="linotype" area="core" type="general" status="new" pointer="none"

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
    while IFS= read -r line; do
      line="${line%$'\r'}"
      [ -z "${line// /}" ] && continue
      echo "$line" | grep -qE '^\s*#' && continue
      if echo "$line" | grep -qE '^\s*[-*]\s+'; then
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
