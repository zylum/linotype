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

## What's a Galley?
A Galley is a temporary grouping of execution slugs that together realise one product change. It's owned by PDA and lives as a folder in `docs/work/planning/`. See [Galleys](galleys.md) for details.

## Do I need to use Galleys?
No. Galleys are optional. Use them when:
- Multiple modules need to coordinate on a single product change
- You want to preserve the "why" across multiple slugs
- You're planning parallel work that needs sequencing

Skip Galleys for small, single-module changes.

## Can a slug exist without a Galley?
Yes. Slugs can exist independently. Use a Galley only when you need to coordinate multiple slugs.

## Who creates Galleys?
PDA (Product Design Authority) creates and owns Galleys. Module Owners execute the slugs within a Galley but don't edit the Galley itself.

## What's the difference between a Galley and a Directional slug?
Both are planning artefacts:
- **Directional slug**: Explores options for a single module, outputs a decision
- **Galley**: Coordinates multiple modules, outputs a product change

Use Directional slugs for decisions. Use Galleys for coordinated work.
