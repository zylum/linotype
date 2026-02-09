# What is Linotype?

Linotype is an operating model for building complex products while preserving coherence over time.

## The problem

As products grow, teams face:
- Context loss when returning to old work
- Drift between docs and reality
- Unclear boundaries for delegation
- Difficulty tracking decisions over time

## The solution

Linotype provides:
- **Galleys**: temporary groupings of slugs that realise one product change; move through planning → (queue) → doing → review → done
- **Slugs**: smallest delegable units of work inside a galley, with clear boundaries
- **Explicit stages**: galley lifecycle plus optional queue for parallel handoff
- **Proof requirement**: build slugs show working evidence before review
- **Agent contract**: `docs/ai/_agent-rules.md` (authoritative) plus repo `AGENTS.md` (adapter). Focus (loose/standard/strict) and optimise (speed/cost/quality) tune scope and trade-offs
- **Role clarity**: Orchestrator (coordination, moves) and Executor (slug delivery); PDA/Module Architect for human ownership

## Core principles

1. **Coherence over time** — The system stays understandable as it evolves
2. **Delegable work** — Slugs have clear boundaries; galleys coordinate them
3. **Reality-driven docs** — Documentation reflects what actually exists
4. **Proof-backed completion** — No galley moves to review without slug evidence

## When to use Linotype

Use Linotype when:
- Your product will evolve over months/years
- Multiple people (or agents) need to understand and execute work
- You need to delegate or parallelise work safely
- Context loss is expensive

Skip Linotype for throwaway prototypes, solo projects with no handoff, or work that doesn’t need coherence tracking.
