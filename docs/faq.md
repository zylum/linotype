# FAQ

## Is this just process?
It’s a small set of artefacts and habits to prevent drift. If you don’t need coherence over time, it may be unnecessary.

## What are focus and optimise?
In `docs/ai/_agent-rules.md`: **focus** (loose | standard | strict) controls scope discipline; **optimise** (speed | cost | quality) controls trade-off bias. Independent; both optional with defaults.

## What’s AGENTS.md?
Repo-root adapter for Linotype: minimum reading order, repo commands, conventions. If it conflicts with `docs/ai/_agent-rules.md`, the latter wins. See the skeleton’s `AGENTS.md` template.

## Do I need to use BMAD?
Linotype can assume BMAD inside a slug (Boundaries, Map, Analyse, Design, Build, Validate, Document). The operating model is method-agnostic.

## Will this slow me down?
It slows down unclear work; it speeds up returning to context and delegating (including to agents).

## What’s the difference between docs/context and docs/capabilities?
Context/domain = high-level product snapshot (what/who/why). Capabilities = detailed module specs and registry (how/where). Agents use domain/index for minimal lookup.

## Do I need all the optional docs?
No. Start with work structure, `_agent-rules.md`, and `AGENTS.md`. Add overview, architecture, glossary, shared-standards only when they add clarity.

## Can I use this with Kiro or Cursor?
Yes. The skeleton includes `.kiro/`, `.cursor/`, and `CLAUDE.md`; they reference `docs/ai/_agent-rules.md` as authoritative.

## What’s a Galley?
A temporary grouping of slugs that realise one product change. Folder moves through planning → (queue) → doing → review → done. See [Galleys](galleys.md).

## Do I need to use Galleys?
Use galleys when coordinating multiple modules or slugs. Skip for small, single-slug changes.

## What’s the difference between a Galley and a Directional slug?
Directional slug: explore/decide (single module). Galley: coordinate and deliver (multiple modules). See [slug-types](slug-types.md).