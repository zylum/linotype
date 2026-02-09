# Agent rules (Linotype)

<!-- Linotype focus: loose | standard | strict
  loose:   broad slugs, cross-domain OK, 1 retry, faster iteration (greenfield)
  standard: single-domain default, cross-domain if declared, 2 retries
  strict:  narrow slugs, single-domain enforced, 2 retries, careful review (production)
-->
focus: loose

<!-- Linotype optimise: speed | cost | quality (optional; independent of focus)
  focus    = scope discipline (how broad/narrow the change may be)
  optimise = what to favour when making trade-offs (default: balanced)
-->
optimise: speed

These rules apply to any agent performing work in this repository.
Treat them as non-negotiable constraints unless the user explicitly overrides them.

## Primary objective
Deliver the requested change safely and minimally, within the active galley scope, while keeping documentation aligned with behaviour.

## Minimum context for agents
Before starting work, an agent must read:
1. This file
2. `docs/domain/index.md` (lookup only, minimise token bloat)
3. The active galley README and its slugs

Everything else is reference unless the active galley asks for it.

## Agent roles

### Orchestrator
Responsible for coordination and hygiene:
- Shape and sequence work (create and refine galleys/slugs)
- Move galley lifecycle state
- Keep scope explicit
- Apply small fixes and polish where appropriate
- Review outcomes and record decisions

### Executor
Responsible for delivery:
- Execute slugs (docs/code changes)
- Run checks/tests where available
- Commit using the required formats
- Record decisions and follow-ups in review artefacts

A single person or tool may perform both roles.
At any moment, a galley must have exactly one active Executor.

## Work discipline

### Galley lifecycle
A galley folder must match its real state.
Move galleys using: `cli/linotype galley move <galley-name> <stage>`

Stages: `planning` | `queue` | `doing` | `review` | `done`

1. (Optional) Move to `queue/` when ready for pickup  
   Use `queue` as the handoff point for execution.

2. Move to `doing/` when work starts  
   As soon as the first slug is in progress, move the galley to `doing/`.

3. Move to `review/` when all slugs are done  
   When every slug is complete, move to `review/` and commit the outcome.

4. Keep README aligned  
   Update the galley README if lifecycle, scope, or intent changes.

### Planning hygiene (docs/work/planning)
- Recommended order and overlap boundaries live in `docs/work/planning/README.md`
- Galley naming:
  - Single galley: `yyyymmdd-<name>`
  - Group: `yyyymmdd-<group>-<name>`
- Create and move via `cli/linotype` to keep tooling in sync

### Concept placement
- Why (rationale, allowed/blocked) goes in planning or policy docs
- How did it go (performance) goes in learning artefacts (Runs/Steps)
- What is this (the commitment) goes in the Work galley

Do not mix these categories.

## Scope and file placement
Agents may only modify or create files in:
- `docs/work/**`
- `docs/**`
- `cli/**`
- `.kiro/**`, `.cursor/**`, `CLAUDE.md`

Do not create documentation in the repository root beyond the allowed files.

## Change scope defaults
Scope behaviour depends on `focus`:

- loose: slugs may span domains; broader scope OK
- standard: single-domain by default; cross-domain only if declared in slug header
- strict: single-domain enforced; no opportunistic refactors

When scope is expanded (standard/loose), the agent must:
- list allowed domains or file paths in the slug header
- avoid opportunistic refactors outside declared scope

## Decisions and ambiguity
- If a design decision changes intended behaviour, record it in the galley `review.md`
- If ambiguous, do not guess: record an open question in the relevant slug and proceed with the safest minimal assumption

## Retry rule
Depends on `focus`:
- loose: 1 retry
- standard/strict: 2 retries

If exceeded, the slug is wrong. Stop and rewrite the slug.

## Output expectations

### Slug completion
For each slug, update the slug file with:
- what changed (files, behaviours)
- checks run (or why not)
- decisions/trade-offs (or "none")

Commit after each slug:
`git commit -m "slug:<slug-name> done - <summary> #galley:<galley-name>"`

### Galley completion
When all slugs are complete:
1. Move galley to `review/`
2. Commit:
`git commit -m "galley:<galley-name> ready for review - <summary>"`

Do not leave a finished galley in `doing/`.

## Queue and parallel workflow

### Claiming work
Only move galleys from `queue` to `doing`.
The first successful move claims the galley.

If your move fails because it is no longer in `queue`, pick another galley.

### Branch and isolation
- One branch per galley
- One worktree per active galley in parallel mode

Suggested branch: `slug/<galley-id>-<galley-name>`

### Conflict avoidance
- One active galley per worktree
- No two Executors work the same galley
- If conflicts occur: stop further work on that galley and record the conflict plus open questions in the galley `review.md`

### Working tree strategy
- Default: work in the main repository working tree
- Parallel mode: one git worktree per active galley; each worktree checks out its galley branch
