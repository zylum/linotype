#!/usr/bin/env bash
set -euo pipefail

MODE="init"
VERSION_FILE=".linotype-version"
CURRENT_VERSION="0.32"

# Parse flags
while [[ $# -gt 0 ]]; do
  case $1 in
    --check)
      MODE="check"
      shift
      ;;
    --upgrade)
      MODE="upgrade"
      shift
      ;;
    --reset)
      MODE="reset"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

echo "Linotype v$CURRENT_VERSION - Mode: $MODE"

# Helper: create or update file based on mode
mkfile () {
  local path="$1"
  local content="$2"
  local is_work="${3:-false}"  # true for work files (slugs, build notes)
  local is_rule="${4:-false}"  # true for rules/templates
  
  mkdir -p "$(dirname "$path")"
  
  if [ ! -f "$path" ]; then
    cat > "$path" <<EOF
$content
EOF
    echo "✓ Created $path"
  elif [ "$MODE" = "reset" ]; then
    cat > "$path" <<EOF
$content
EOF
    echo "⚠ Reset $path (--reset)"
  elif [ "$MODE" = "upgrade" ] && [ "$is_rule" = true ]; then
    cat > "$path" <<EOF
$content
EOF
    echo "✓ Updated $path (--upgrade)"
  elif [ "$MODE" = "check" ]; then
    echo "✓ Found $path"
  else
    echo "⊘ Skipped $path (exists)"
  fi
}

# Helper: check if file exists
check_file () {
  local path="$1"
  if [ -f "$path" ]; then
    echo "✓ $path"
    return 0
  else
    echo "✗ $path (missing)"
    return 1
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
" false false

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
" false false

mkfile docs/overview.md "> Status: intentionally minimal. Expand when it adds clarity.

# Overview
How to navigate this repo at a high level.
" false false

mkfile docs/architecture.md "> Status: intentionally minimal. Expand when it adds clarity.

# Architecture
Thin, stable overview. Avoid implementation detail.
" false false

mkfile docs/glossary.md "> Status: intentionally minimal. Expand when it adds clarity.

# Glossary
Shared terms and definitions.
" false false

mkfile docs/shared-standards.md "> Status: intentionally minimal. Expand when it adds clarity.

# Shared Standards
Conventions that apply across modules.
" false false

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
mkfile docs/work/planning/SLUG-001.bootstrap-linotype.md "# SLUG-20250131-0900-bootstrap-linotype

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

mkfile docs/work/planning/SLUG-001.index-linotype.md "# SLUG-20250131-0900-index-linotype

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
mkfile docs/work/planning/SLUG-002.first-vertical-slice.md "# SLUG-20250131-1000-first-vertical-slice

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

# Templates (safe to upgrade)
mkfile docs/templates/slug-plan.md "# SLUG: SLUG-YYYYMMDD-HHMM-purpose

Example: SLUG-20250131-1430-auth-login

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
" false true

mkfile docs/templates/slug-build-notes.md "# Build Notes: SLUG-YYYYMMDD-HHMM-purpose

Example: SLUG-20250131-1430-auth-login

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
" false true

# Kiro steering (rules - safe to upgrade)
mkfile .kiro/steering/product.md "--- 
inclusion: always
---
Linotype Operating Model

Three roles, three phases:

1. PDA (Product Decision Authority) - Define intent
   - Decide what changes and why
   - Create slug plans with clear scope
   - Review and sequence work

2. Module Owners - Build the change
   - Implement using module expertise
   - Update module docs and capabilities
   - Provide Proof before review

3. PDA - Review & sequence
   - Verify change matches plan
   - Update product docs
   - Plan next slugs

Rules:
- PDA decides intent and sequencing (not implementation)
- Module owners own their boundaries and docs
- Docs must stay in sync with reality
- Prefer small, delegable slugs over big plans
- Use Proof in build notes before moving to review

See .kiro/steering/roles.md for detailed workflow.
" false true

mkfile .kiro/steering/structure.md "--- 
inclusion: always
---
Primary artefacts:

- docs/context/app-context.md
- docs/capabilities/registry.yml
- docs/capabilities/modules/
- docs/work/
- docs/templates/

File organization rules:
- All work slugs: docs/work/{planning,doing,review,done}/
- All documentation: docs/ (never root)
- No .md files in project root except README.md
- No docs scattered in random locations
- Use docs/work/doing/small-fixes.md for non-slug work only

Work rules:
- For non-trivial work, create a slug plan in docs/work/planning
- Use ./linotype.sh to move slugs: start, review, done
- After build, write build notes (including Proof) before review
- Update module docs and app-context when behaviour changes
" false true

mkfile .kiro/steering/workflow.md "--- 
inclusion: always
---
Workflow is managed by ./linotype.sh

Commands:
- ./linotype.sh init
- ./linotype.sh start <SLUG-YYYYMMDD-HHMM-purpose>
- ./linotype.sh review <SLUG-YYYYMMDD-HHMM-purpose>
- ./linotype.sh done <SLUG-YYYYMMDD-HHMM-purpose>

Slug naming:
- Format: SLUG-YYYYMMDD-HHMM-purpose (e.g., SLUG-20250131-1430-auth-login)
- Date/time prevents collisions and makes history clear
- Purpose is kebab-case, 2-3 words max

File organization:
- All work goes in docs/work/ (planning, doing, review, done)
- All docs go in docs/ (context, capabilities, templates)
- No .md files in project root except README.md
- No random docs in other locations

Kiro should not move files manually. Use the script.
Before review, ensure build notes include Proof (URL, screenshot, test output, or commit/diff).
" false true

mkfile .kiro/steering/roles.md "--- 
inclusion: always
---
# Roles in Linotype

Work happens in three phases, with different roles leading each:

## Phase 1: PDA (Product Decision Authority) - Define Intent

Role: Decide what changes, why, and in what order.

- Read: docs/context/app-context.md, docs/capabilities/registry.yml
- Decide: What problem are we solving? What's the user outcome?
- Output: Slug plan in docs/work/planning/ with clear scope and acceptance checks
- Do NOT: Design implementation details or module internals

Example: \"We need users to reset their password. This touches auth and email modules.\"

## Phase 2: Module Owners - Build the Change

Role: Implement the slug using your module expertise and docs.

- Read: Your module spec (docs/capabilities/modules/*/spec.md)
- Read: The slug plan you're executing
- Read: Capability registry to understand dependencies
- Build: End-to-end, following the slug scope
- Update: Module docs, features, decisions if boundaries change
- Output: Build notes with Proof before moving to review

Example: Auth owner implements password reset flow, updates auth/spec.md and features.md

## Phase 3: PDA - Review & Sequence

Role: Verify the change, update product docs, plan next slugs.

- Read: Build notes and Proof
- Verify: Does it match the slug plan? Any surprises?
- Update: docs/context/app-context.md if user-facing behavior changed
- Sequence: What's next? Create follow-on slugs in planning
- Move: ./linotype.sh done SLUG-XXX

## Key Rules

- PDA decides intent and sequencing (not implementation)
- Module owners own their boundaries and docs
- Docs must stay in sync with reality
- Prefer small, delegable slugs over big plans
- Use Proof in build notes before moving to review
" false true

# Optional extras (rules - safe to upgrade)
mkfile .cursor/rules.md "# Cursor rules (optional)

## Your Role

You are a Module Owner. You implement slugs using your module expertise.

Before coding:
- Read the slug plan (docs/work/doing/SLUG-*.md)
- Read your module spec (docs/capabilities/modules/*/spec.md)
- Read capability registry to understand dependencies
- Understand the scope and acceptance checks

While coding:
- Stay within the slug scope
- Follow module boundaries
- Update module docs as you go

After coding:
- Update module spec.md with any boundary changes
- Update module features.md if capabilities changed
- Update decisions.md if contracts changed
- Write build notes with Proof before review

Slug naming:
- Format: SLUG-YYYYMMDD-HHMM-purpose (e.g., SLUG-20250131-1430-auth-login)
- Date/time prevents collisions
- Purpose is kebab-case, 2-3 words max

File organization:
- All work in docs/work/ (planning, doing, review, done)
- All docs in docs/ (never root)
- No random .md files scattered around
" false true

mkfile CLAUDE.md "# Claude Code (optional)

## Your Role

You are a Module Owner. You implement slugs using your module expertise.

Before coding:
- Read the slug plan (docs/work/doing/SLUG-*.md)
- Read your module spec (docs/capabilities/modules/*/spec.md)
- Read capability registry to understand dependencies
- Understand the scope and acceptance checks

While coding:
- Stay within the slug scope
- Follow module boundaries
- Update module docs as you go

After coding:
- Update module spec.md with any boundary changes
- Update module features.md if capabilities changed
- Update decisions.md if contracts changed
- Write build notes with Proof before review

Slug naming:
- Format: SLUG-YYYYMMDD-HHMM-purpose (e.g., SLUG-20250131-1430-auth-login)
- Date/time prevents collisions
- Purpose is kebab-case, 2-3 words max

File organization:
- All work in docs/work/ (planning, doing, review, done)
- All docs in docs/ (never root)
- No random .md files scattered around
" false true

mkfile .gitignore "# dependencies
node_modules
.next
dist

# env
.env
.env.local
"

# Version tracking
mkfile "$VERSION_FILE" "$CURRENT_VERSION" false true

# linotype.sh (created by bootstrap - safe to upgrade)
mkfile linotype.sh "$(cat <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="docs/work"
PLANNING="$WORK_DIR/planning"
DOING="$WORK_DIR/doing"
REVIEW="$WORK_DIR/review"
DONE="$WORK_DIR/done"

# Friendly message helpers
msg_ok() { echo "✓ $1"; }
msg_info() { echo "ℹ $1"; }
msg_error() { echo "✗ $1" >&2; }
msg_hint() { echo "  → $1" >&2; }

usage() {
  cat <<'USAGE'
Linotype workflow

Usage:
  ./linotype.sh init                              Initialize work directories
  ./linotype.sh list [planning|doing|review|done] List slugs in a stage
  ./linotype.sh status                            Show workflow overview
  ./linotype.sh start SLUG-XXX.name               Move slug from planning to doing
  ./linotype.sh check SLUG-XXX.name               Validate slug readiness
  ./linotype.sh review SLUG-XXX.name              Move slug from doing to review
  ./linotype.sh done SLUG-XXX.name                Move slug from review to done

Examples:
  ./linotype.sh start SLUG-002.first-vertical-slice
  ./linotype.sh list doing
  ./linotype.sh status
USAGE
}

ensure_dirs() {
  mkdir -p "$PLANNING" "$DOING" "$REVIEW" "$DONE"
}

slug_file() {
  local slug="$1"
  echo "${slug}.md"
}

find_slug_path() {
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

require_file() {
  local path="$1"
  local desc="${2:-file}"
  if [ ! -f "$path" ]; then
    msg_error "Missing $desc: $path"
    return 1
  fi
}

proof_present() {
  local path="$1"
  if ! grep -q "^## Proof" "$path"; then
    return 1
  fi
  # Use grep -E with fallback for older macOS
  if grep -E "^- (URL|Screenshot|Commit / diff|Test output):[[:space:]]*[^[:space:]]" "$path" >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

check_slug_basics() {
  local slug="$1"
  local slug_path
  slug_path="$(find_slug_path "$slug" 2>/dev/null || true)"
  
  if [ -z "${slug_path:-}" ]; then
    msg_error "Slug not found: $slug"
    msg_hint "Check docs/work/{planning,doing,review,done}/"
    return 1
  fi

  require_file "docs/context/app-context.md" "app context" || return 1
  require_file "docs/capabilities/registry.yml" "capability registry" || return 1
  require_file "$slug_path" "slug plan" || return 1

  local build_notes_doing="$DOING/${slug}.build-notes.md"
  local build_notes_review="$REVIEW/${slug}.build-notes.md"
  local build_notes_done="$DONE/${slug}.build-notes.md"

  if [[ "$slug_path" == "$PLANNING/"* ]]; then
    msg_info "Slug is in planning. Build notes not required yet."
    return 0
  fi

  if [ -f "$build_notes_doing" ] || [ -f "$build_notes_review" ] || [ -f "$build_notes_done" ]; then
    msg_info "Build notes found."
  else
    msg_error "Build notes missing for $slug"
    msg_hint "Expected one of:"
    msg_hint "  $build_notes_doing"
    msg_hint "  $build_notes_review"
    msg_hint "  $build_notes_done"
    return 1
  fi

  return 0
}

cmd_init() {
  ensure_dirs
  msg_ok "Work directories ready: docs/work/{planning,doing,review,done}"
}

cmd_list() {
  ensure_dirs
  local stage="${1:-}"
  
  if [ -z "$stage" ]; then
    msg_info "Slugs by stage:"
    for s in planning doing review done; do
      local count
      count=$(find "$WORK_DIR/$s" -maxdepth 1 -name "SLUG-*.md" 2>/dev/null | wc -l)
      echo "  $s: $count"
    done
    return 0
  fi

  case "$stage" in
    planning|doing|review|done)
      local dir="$WORK_DIR/$stage"
      if [ ! -d "$dir" ]; then
        msg_error "Stage directory not found: $dir"
        return 1
      fi
      local count=0
      while IFS= read -r file; do
        basename "$file" .md
        ((count++))
      done < <(find "$dir" -maxdepth 1 -name "SLUG-*.md" 2>/dev/null | sort)
      if [ "$count" -eq 0 ]; then
        msg_info "No slugs in $stage"
      fi
      ;;
    *)
      msg_error "Unknown stage: $stage"
      msg_hint "Use: planning, doing, review, or done"
      return 1
      ;;
  esac
}

cmd_status() {
  ensure_dirs
  msg_info "Workflow status:"
  for stage in planning doing review done; do
    local count
    count=$(find "$WORK_DIR/$stage" -maxdepth 1 -name "SLUG-*.md" 2>/dev/null | wc -l)
    printf "  %-10s %d\n" "$stage:" "$count"
  done
}

cmd_start() {
  ensure_dirs
  local slug="${1:-}"
  if [ -z "$slug" ]; then
    msg_error "Slug name required"
    msg_hint "Usage: ./linotype.sh start SLUG-XXX.name"
    return 1
  fi

  local f
  f="$(slug_file "$slug")"

  if [ ! -f "$PLANNING/$f" ]; then
    msg_error "Plan not found: $PLANNING/$f"
    msg_hint "Create the slug plan first in docs/work/planning/"
    return 1
  fi

  mv "$PLANNING/$f" "$DOING/$f"
  msg_ok "Moved to doing: $slug"

  local bn="$DOING/${slug}.build-notes.md"
  if [ ! -f "$bn" ]; then
    cat > "$bn" <<'BNOTES'
# Build Notes: SLUG-XXX

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
BNOTES
    msg_ok "Created build notes: $bn"
  else
    msg_info "Build notes already exist"
  fi
}

cmd_check() {
  local slug="${1:-}"
  if [ -z "$slug" ]; then
    msg_error "Slug name required"
    msg_hint "Usage: ./linotype.sh check SLUG-XXX.name"
    return 1
  fi
  check_slug_basics "$slug" || return 1
  msg_ok "All checks passed for $slug"
}

cmd_review() {
  ensure_dirs
  local slug="${1:-}"
  if [ -z "$slug" ]; then
    msg_error "Slug name required"
    msg_hint "Usage: ./linotype.sh review SLUG-XXX.name"
    return 1
  fi

  cmd_check "$slug" || return 1

  local f
  f="$(slug_file "$slug")"

  if [ -f "$DOING/$f" ]; then
    local bn_doing="$DOING/${slug}.build-notes.md"
    require_file "$bn_doing" "build notes" || return 1

    if ! proof_present "$bn_doing"; then
      msg_error "Build notes incomplete: $bn_doing"
      msg_hint "Fill in at least one item under ## Proof:"
      msg_hint "  - URL: ..."
      msg_hint "  - Screenshot: ..."
      msg_hint "  - Commit / diff: ..."
      msg_hint "  - Test output: ..."
      return 1
    fi

    mv "$DOING/$f" "$REVIEW/$f"
    msg_ok "Moved to review: $slug"

    mv "$bn_doing" "$REVIEW/${slug}.build-notes.md"
    msg_ok "Build notes moved to review"
  elif [ -f "$PLANNING/$f" ]; then
    msg_error "Slug is still in planning"
    msg_hint "Run: ./linotype.sh start $slug"
    return 1
  else
    msg_error "Slug not found in doing"
    msg_hint "Check: ./linotype.sh list doing"
    return 1
  fi
}

cmd_done() {
  ensure_dirs
  local slug="${1:-}"
  if [ -z "$slug" ]; then
    msg_error "Slug name required"
    msg_hint "Usage: ./linotype.sh done SLUG-XXX.name"
    return 1
  fi

  local f
  f="$(slug_file "$slug")"

  if [ -f "$REVIEW/$f" ]; then
    mv "$REVIEW/$f" "$DONE/$f"
    msg_ok "Moved to done: $slug"
  else
    msg_error "Slug must be in review to complete"
    msg_hint "Check: ./linotype.sh list review"
    return 1
  fi

  local bn_review="$REVIEW/${slug}.build-notes.md"
  if [ -f "$bn_review" ]; then
    mv "$bn_review" "$DONE/${slug}.build-notes.md"
    msg_ok "Build notes archived"
  fi
}

main() {
  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    init) cmd_init ;;
    list) cmd_list "$@" ;;
    status) cmd_status ;;
    start) cmd_start "$@" ;;
    check) cmd_check "$@" ;;
    review) cmd_review "$@" ;;
    done) cmd_done "$@" ;;
    -h|--help|"") usage ;;
    *)
      msg_error "Unknown command: $cmd"
      usage
      return 1
      ;;
  esac
}

main "$@"
EOF
)"
chmod +x linotype.sh 2>/dev/null || true

# Check mode: validate setup
if [ "$MODE" = "check" ]; then
  echo ""
  echo "Checking Linotype setup..."
  local errors=0
  
  check_file "docs/context/app-context.md" || ((errors++))
  check_file "docs/capabilities/registry.yml" || ((errors++))
  check_file "docs/work/planning" || ((errors++))
  check_file "docs/work/doing" || ((errors++))
  check_file "docs/work/review" || ((errors++))
  check_file "docs/work/done" || ((errors++))
  check_file ".kiro/steering/workflow.md" || ((errors++))
  check_file "linotype.sh" || ((errors++))
  
  if [ $errors -eq 0 ]; then
    echo ""
    echo "✓ All checks passed"
    exit 0
  else
    echo ""
    echo "✗ $errors issue(s) found"
    exit 1
  fi
fi

echo ""
if [ "$MODE" = "reset" ]; then
  echo "⚠ Linotype v$CURRENT_VERSION reset complete"
  echo "WARNING: All docs have been reset to templates"
elif [ "$MODE" = "upgrade" ]; then
  echo "✓ Linotype v$CURRENT_VERSION upgraded"
  echo "Updated: rules, templates, linotype.sh"
  echo "Preserved: all work and docs"
else
  echo "✓ Linotype v$CURRENT_VERSION bootstrap complete"
fi

echo ""
echo "Next steps:"
echo "  1. ./linotype.sh init"
echo "  2. Complete one SLUG-001 in docs/work/planning/"
echo "  3. ./linotype.sh start SLUG-20250131-0900-bootstrap-linotype"
echo "  4. Build, then ./linotype.sh review SLUG-20250131-0900-bootstrap-linotype"
echo ""
echo "Commands:"
echo "  ./linotype.sh list [stage]  - See all slugs"
echo "  ./linotype.sh status        - Quick overview"
echo ""
echo "Bootstrap modes:"
echo "  ./linotype-bootstrap.sh --check    - Validate setup"
echo "  ./linotype-bootstrap.sh --upgrade  - Update rules/templates only"
echo "  ./linotype-bootstrap.sh --reset    - Reset everything (dangerous!)"
