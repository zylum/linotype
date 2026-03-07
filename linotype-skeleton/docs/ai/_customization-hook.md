# Customization hook (for consuming apps)

Linotype provides galleys, slugs, and workflow structure. Consuming apps can extend or override with their own rules.

## Where to add app-specific rules

- **Cursor rules**: `.cursor/rules/` (e.g. BT-*, build-tasks, capabilities)
- **Project instructions**: `docs/ai/_project-instructions.md` (ChatGPT, etc.)
- **This file**: Drop references to your custom rules here so agents know what applies.

## Common customizations

- **BT-* build tasks**: PLAN, BUILD-NOTES, `build-tasks/planning|doing|done`, branch naming `feat/BT-014-*`
- **Capability specs**: `docs/capabilities/`, `features/index.md`
- **Component library**: `components/common/`, EntityCard/List/Editor patterns

## Mapping to Linotype

If you use both Linotype and BT-*:

- One galley can correspond to one BT-id (or vice versa)
- Commit format: `slug:<slug> done - <summary> #galley:<galley>` or `BT-014: <summary>`
- Plan travels with feature: galley README + run-sheet = PLAN; review.md = BUILD-NOTES source

## After bootstrap

1. Copy or adapt this file for your app
2. Add your rules to `.cursor/rules/` or `docs/ai/`
3. Ensure `_agent-rules.md` is read first; customization extends or overrides where needed
