# Agent rules (Linotype)

<!-- Linotype focus: loose | standard | strict
  loose:   broad slugs, cross-domain OK, 1 retry, faster iteration (greenfield)
  standard: single-domain default, cross-domain if declared, 2 retries (balanced)
  strict:  narrow slugs, single-domain enforced, 2 retries, slower but safer (core)
-->

These rules apply to any agent performing work in this repository.
Treat them as non-negotiable constraints unless the user explicitly overrides them.

## Primary objective
Deliver requested change safely and minimally, within the active galley scope, while keeping documentation aligned with behaviour.

## Execution phases (behavioural / structural slugs)
For any slug that changes behaviour, contracts, or introduces multi-file structure:
1. **Phase A – Contract freeze**: lock the API/tool names, schemas, error model, user journeys, and worked examples inside the slug + galley docs.
2. **Phase B – Implementation**: execute only against the frozen contract. No schema/contract changes are allowed in this phase.
3. **Phase C – Verify**: run checks/tests, capture outputs, and record evidence in the slug and galley review.

If Phase B reveals missing requirements, return to Phase A, update the slug/galley docs, and only then continue. Do not “discover” scope mid-build without revisiting the contract.

## Learning layer (v0.5)
Linotype supports a portable learning layer under:
- `docs/learning/inbox/` raw reflections (human/system drops)
- `docs/learning/signals/` normalised signals (daily/weekly)
- `docs/learning/proposals/` advisory clustering and suggested work
- `docs/learning/snapshots/` compiled context for planning tools (ChatGPT/agents)

If you are planning work or responding to a request that depends on repo state, prefer a snapshot:
- Generate: `cli/linotype bundle snapshot --app <app> --area <area>`
- Use the snapshot as the primary planning context to avoid drift.

Signals discipline:
- Create signals as small, independent bullets (avoid Jira-style hierarchies).
- Prefer evidence pointers (commit hash, galley/slug reference) when marking done.

**Domain memory:** Consult `docs/domain/index.md` (and linked module files) before prompting with large context, open-ended code, or external tools. Look up concepts here first to cut token bloat.

Snapshot discipline:
- Generate targeted snapshots with `cli/linotype bundle snapshot --app <app> --area <area> --domains` (if available) so prompts stay lean.
- If the domain docs lack the needed detail, update them inside the active galley before escalating.

## Minimum reading order
Before starting work, an agent must read:
1. This file
2. `docs/domain/index.md` (lookup only, minimise token bloat)
3. The active galley README and its slugs (and `run-sheet.md` if present)
4. If present and relevant: latest `docs/learning/snapshots/*snapshot*` for the target app/area

## Slug context pack (preferred for agent execution)
When running via OpenCode/Cursor (or any agent runner), generate a fresh context pack per slug:
- slug purpose, acceptance criteria, and autonomy
- explicitly allowed files/paths
- galley-level constraints (branch, stop conditions, domain updates)
- links to the relevant `docs/domain/*.md` entries instead of copying entire files

Keep the pack minimal; this keeps prompts lean and reduces drift.

Everything else is reference unless the active galley asks for it.

## Scope and safety
- Work only within the active galley directory (e.g., `docs/work/doing/<galley>/`).
- Do not refactor or restructure code outside the galley scope unless the galley explicitly includes "cleanup" or "refactor" slugs.
- Keep changes minimal and focused on the slug's acceptance checks.
- If you discover a necessary cross-cutting change, stop and record it in the galley `review.md` with a proposed plan. Do not execute it unilaterally.

## Autonomy and stop conditions
- Prefer continuous execution: run all slugs to completion unless blocked.
- Treat a galley handoff as a contract: finish every slug and move the galley to the requested stage before checking back unless a gated decision stops you.
- Stop and ask only when:
  - You are blocked by ambiguity that changes behaviour.
  - Acceptance checks fail and cannot be fixed safely.
  - A decision marked "gated" is reached.
  - Implementation would require changing a frozen contract/schema, adding new endpoints, or expanding the declared scope.
- If not blocked: make the safest minimal assumption and record an open question in `review.md` or the slug.

## Handoff and commits
- One branch per galley; prefer a dedicated worktree.
- Commit after each slug with the format: `slug:<slug-name> done - <summary> #galley:<galley-name>`
  - Optional suffix: `#phase:contract|build|verify` to show where the slug finished.
- When the galley is complete, move it to `review/` and commit: `galley:<galley-name> ready for review - <summary>`

## Code and doc alignment
- Update slugs with what changed, checks run, and decisions made.
- No slug may be marked **done** without:
  - commands/tests run
  - evidence pointers (file paths, outputs, or commit hashes) captured in the slug and galley review
- If behaviour changes, update the relevant capability description, glossary entry, and `docs/domain/<module>.md` file.
- Prefer links over duplication: reference files rather than copying long passages.

## Release notes & movie naming
- Each major release uses an unused iconic movie codename (v0.6 = “Casablanca”). If one is already claimed in `CHANGELOG.md`, pick a different movie.
- Record user-facing changes in `docs/work/releases/<version>.md` (single file per version). Use `cli/linotype release init` / `release note` helpers when available.
- Galley run sheets include a **Domain updates** block; update it and mention any release-note bullets generated by that galley.

## Meta-rules
- Do not add speculative future work to the active galley; record it in the galley `review.md` or `docs/learning/signals/` for later triage.
- If rules conflict, prefer safety and documentation over speed.
- When in doubt, record the question in `review.md` and continue with the safest assumption.

---

## Artefacts you may encounter

### Slug file (template-driven)
Location:
- `docs/work/<stage>/<galley>/slugs/<slug-id>-<slug-name>.md`

Key fields:
- `purpose`: one-line intent
- `acceptance`: checklist of observable outcomes
- `autonomy`: continuous | confirm | stop
- `state`: open | in-progress | blocked | done

### Galley files
Location (preferred):
- `docs/work/<stage>/<galley>/README.md`
- `docs/work/<stage>/<galley>/context.md`
- `docs/work/<stage>/<galley>/review.md`
- `docs/work/<stage>/<galley>/run-sheet.md`

Purpose:
- Define slug order, acceptance checks, and stop conditions.
- Keep it short. Prefer bullet lists and file references over prose.

Learning outputs:
- When a galley finishes, record learnings in its `review.md`.
- Where learnings imply future work, capture signals in `docs/learning/signals/` (or seed via `docs/learning/inbox/`).
- Avoid duplicating long narrative in multiple places: link to sources.

### Executor brief (generated)
Generated by:
- `cli/linotype exec brief <galley>`

Compatibility alias:
- `cli/linotype exec opencode <galley>`

Used by:
- Executor agents to run slugs without repeated coordination.

Constraints:
- Execute slugs in order.
- Stop only when blocked by ambiguity, failing checks, or a gated decision.
- Record assumptions and open questions in the galley `review.md`.

## LinoLoop (execution wrapper)
LinoLoop is a thin wrapper that:
- Generates the executor brief using `cli/linotype exec brief <galley>`
- Runs a loop runner (for example `ralph`) to iterate until completion or a configured stop limit

Invocations:
- `cli/linoloop <galley-name>`
- `cli/linoloop <release-id>` (release references galleys; it does not contain them)

Release format (minimal):
- `docs/work/releases/<release-id>/galleys.txt` with one galley name per line.

Agent expectations when run via LinoLoop:
- Treat the current galley as the active scope.
- Commit after each slug, update slug state and evidence, and maintain `review.md`.
