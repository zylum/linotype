# FAQ

## Is this just process?
It is a small set of artefacts and habits to prevent drift. If you do not need coherence over time, it may be unnecessary.

## Do I need to use BMAD?
Linotype assumes BMAD as the method inside a slug (Boundaries, Map, Analyse, Design, Build, Validate, Document), but stays lightweight and tool-agnostic.

## Will this slow me down?
It slows down unclear work. It speeds up returning to context and delegating safely.

## What's the difference between docs/context and docs/capabilities?
- `docs/context/app-context.md` - High-level product snapshot (what/who/why)
- `docs/capabilities/` - Detailed module specs and capability registry (how/where)

Think of context as the 5-minute overview, capabilities as the detailed map.

## Do I need all the optional docs?
No. Start with:
- `docs/context/app-context.md`
- `docs/capabilities/registry.yml`
- Module specs in `docs/capabilities/modules/`

Add `overview.md`, `architecture.md`, `glossary.md`, and `shared-standards.md` only when they add clarity.

## Can I use this with Kiro or Cursor?
Yes. The bootstrap script creates optional steering files in `.kiro/steering/` and a `CLAUDE.md` file. These help AI assistants understand your Linotype structure.

## What if I don't want the full bootstrap structure?
You can manually create just the parts you need:
- `docs/work/{planning,doing,review,done}/`
- `linotype.sh` script
- Templates

But the full bootstrap is recommended for consistency.
