#!/usr/bin/env bash
set -euo pipefail

echo "Bootstrapping Linotype... v3.0.0"

mkfile () {
  local path="$1"
  local content="$2"
  mkdir -p "$(dirname "$path")"
  if [ ! -f "$path" ]; then
    cat > "$path" <<EOF
$content
EOF
    echo "Created $path"
  else
    echo "Skipped $path (already exists)"
  fi
}

# README
mkfile README.md "# Linotype

Linotype is an operating model that keeps products coherent over time.

- Method: BMAD (how we plan and build within a Slug)
- Operating model: Linotype (how we stay coherent across Slugs)
- Unit of work: Slug (smallest delegable change)

Start by completing exactly one:
- docs/work/planning/SLUG-001.bootstrap-linotype.md (new product)
- docs/work/planning/SLUG-001.index-linotype.md (existing product)

Then do:
- docs/work/planning/SLUG-002.first-vertical-slice.md

Workflow is managed by ./linotype.sh (planning -> doing -> review -> done).
Tools are interchangeable. Artefacts are not.
"

# Core docs (mark as intentionally minimal)
mkfile docs/context/app-context.md "# App Context (thin snapshot)

## What this product is
- One paragraph description

## Primary users
-

## Key journeys
-

## Domains/modules (one line each)
-

## Constraints
- Tech:
- Risk/compliance:
- Scale/ops:

## What is in flight
-
"

mkfile docs/overview.md "> Status: intentionally minimal. Expand when it adds clarity.

# Overview
How to navigate this repo at a high level.
"
mkfile docs/architecture.md "> Status: intentionally minimal. Expand when it adds clarity.

# Architecture
Thin, stable overview. Avoid implementation detail.
"
mkfile docs/glossary.md "> Status: intentionally minimal. Expand when it adds clarity.

# Glossary
Shared terms and definitions.
"
mkfile docs/shared-standards.md "> Status: intentionally minimal. Expand when it adds clarity.

# Shared Standards
Conventions that apply across modules.
"

# Capabilities
mkfile docs/capabilities/registry.yml "version: 1
capabilities: []
"

mkfile docs/capabilities/modules/example/spec.md "# Module: Example

## Purpose
What this module owns and why it exists.

## Boundaries
- Owns:
- Does not own:

## Data ownership
- Source of truth:

## Key flows
-

## Non-functionals
- Performance:
- Reliability:
- Observability:
"

mkfile docs/capabilities/modules/example/features.md "# Features

| Feature | Status | Slug | Notes |
|--------|--------|------|-------|
| Example feature | Planned | SLUG-000 | |
"

mkfile docs/capabilities/modules/example/decisions.md "# Decisions

Use this when boundaries, contracts, or ownership change.

- YYYY-MM-DD: Decision summary (Slug: SLUG-000)
"

# Work (includes review)
mkdir -p docs/work/{planning,doing,review,done}
mkfile docs/work/doing/small-fixes.md "# Small fixes (no slug)

- YYYY-MM-DD: description
"

# SLUG-001 templates
mkfile docs/work/planning/SLUG-001.bootstrap-linotype.md "# SLUG-001.bootstrap-linotype

## Purpose
Establish the initial shape of the product and how Linotype will be used.
This slug defines intent and structure, not features.

## Outcome
By the end of this slug:
- docs/context/app-context.md describes the product we are about to build
- An initial set of modules/domains is defined (rough is fine)
- We agree how Slugs will be sized and delegated
- Everyone can answer what are we building, at a high level

## In scope
- Problem framing and user definition
- Key journeys (end-to-end, narrative level)
- Initial module list (3 to 6 max)
- High-level constraints (tech, risk, scale)

## Out of scope (explicit)
- Detailed capabilities
- Architecture diagrams
- API design
- Backlog building

## Acceptance checks
- [ ] app-context.md is filled and readable in under 5 minutes
- [ ] Modules are listed with one-line purposes
- [ ] No detailed capability or feature specs created
- [ ] One sentence definition of what a Slug means for this product

## Notes
This slug should feel light. If it turns into design, stop.
"

mkfile docs/work/planning/SLUG-001.index-linotype.md "# SLUG-001.index-linotype

## Purpose
Make the current system legible. Document reality; do not change it.

## Outcome
By the end of this slug:
- docs/context/app-context.md reflects how the product works today
- Modules/domains are identified from existing code and behaviour
- A first-pass capability registry exists (high level)
- Someone can navigate the system without asking Slack

## In scope
- Reading existing code, APIs, UI, infra
- Identifying natural module boundaries
- Naming capabilities at a coarse level
- Writing thin, factual docs

## Out of scope (explicit)
- Refactoring or renaming
- Fixing architecture
- Improving structure
- Designing future features

## Acceptance checks
- [ ] app-context.md describes reality, not aspiration
- [ ] Each key module has a spec.md with purpose and boundaries
- [ ] Capability registry has a small, sensible set of entries
- [ ] Docs answer where does X live for common questions

## Notes
This is a catalogue, not a redesign. Capture improvements as future slugs.
"

# SLUG-002 template (adds size check)
mkfile docs/work/planning/SLUG-002.first-vertical-slice.md "# SLUG-002.first-vertical-slice

## Purpose
Deliver the smallest end-to-end slice of real value. Prove the shape, not completeness.

## User outcome
When a real user does X, they can now Y.

## Size check (sanity)
- Touches <= 3 files OR one vertical path
- Buildable in <= half a day
- If not, split the slug

## In scope (must be end-to-end)
- One user journey, start to finish
- One happy path
- Minimal UI, minimal backend, minimal data
- Touch at least one real boundary (even if crude)

## Explicitly out of scope
- Edge cases
- Full permissions
- Scalability and optimisation
- Comprehensive error handling
- Nice UI

## Modules involved
- Primary module:
- Supporting modules (keep to 1 to 2 if possible):

## Capabilities touched
-

## Acceptance checks
- [ ] User can complete the journey end to end
- [ ] We touched at least one real boundary
- [ ] Capability docs reflect what now exists
- [ ] app-context.md updated if behaviour changed
- [ ] Follow-on slugs captured for gaps

## What we expect to learn
- Where boundaries feel wrong
- What surprised us
- Which assumptions broke
"

# Templates (build notes include Proof; plan includes size check + doc update rules)
mkfile docs/templates/slug-plan.md "# SLUG: SLUG-XXX <name>

## Outcome
Why this change exists.

## Owning module
example

## Scope
- Changes:
- Not in scope:

## Impacted capabilities
-

## Dependencies
-

## Acceptance checks
- [ ]

## Size check (sanity)
- Touches <= 3 files OR one vertical path
- Buildable in <= half a day
- If not, split the slug

## Docs to update
- [ ] Capability registry (only if capability model changed)
- [ ] Module spec/features
- [ ] App context (if user-facing behaviour changed)
- [ ] Decisions (if boundaries/contracts change)
"

mkfile docs/templates/slug-build-notes.md "# Build Notes: SLUG-XXX <name>

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
"

# Kiro steering
mkfile .kiro/steering/product.md "--- 
inclusion: always
---
Linotype rules:

- PDA decides intent and sequencing
- Modules deliver via slugs
- Docs must stay in sync with reality
- Prefer small, delegable slugs over big plans
- Use Proof in build notes before moving to review
"

mkfile .kiro/steering/structure.md "--- 
inclusion: always
---
Primary artefacts:

- docs/context/app-context.md
- docs/capabilities/registry.yml
- docs/capabilities/modules/
- docs/work/
- docs/templates/

Work rules:
- For non-trivial work, create a slug plan in docs/work/planning
- Use ./linotype.sh to move slugs: start, review, done
- After build, write build notes (including Proof) before review
- Update module docs and app-context when behaviour changes
"

mkfile .kiro/steering/workflow.md "--- 
inclusion: always
---
Workflow is managed by ./linotype.sh

Commands:
- ./linotype.sh init
- ./linotype.sh start <SLUG-XXX.name>
- ./linotype.sh review <SLUG-XXX.name>
- ./linotype.sh done <SLUG-XXX.name>

Kiro should not move files manually. Use the script.
Before review, ensure build notes include Proof (URL, screenshot, test output, or commit/diff).
"

# Optional extras
mkfile .cursor/rules.md "# Cursor rules (optional)

Before coding:
- Read app context
- Read capability registry
- Read module spec(s)

After coding:
- Update module docs
- Update registry if capability model changed
- Update app context if behaviour changed
- Ensure build notes include Proof before review
"

mkfile CLAUDE.md "# Claude Code (optional)

Always read:
- docs/context/app-context.md
- docs/capabilities/registry.yml
- relevant module docs
- the slug plan you are executing

Do not expand scope beyond the slug.
Ensure build notes include Proof before review.
"

mkfile .gitignore "# dependencies
node_modules
.next
dist

# env
.env
.env.local
"

# linotype.sh (created by bootstrap)
mkfile linotype.sh "$(cat <<'EOF'
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
EOF
)"
chmod +x linotype.sh 2>/dev/null || true

echo "Linotype bootstrap complete."
echo "Next:"
echo "1) ./linotype.sh init"
echo "2) Complete exactly one SLUG-001 in docs/work/planning"
echo "3) ./linotype.sh start SLUG-002.first-vertical-slice"
echo "4) Build, then ./linotype.sh review SLUG-002.first-vertical-slice"
