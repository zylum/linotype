# Slug templates

Starter slugs and how to use them. The skeleton provides galley and slug templates under `docs/work/planning/_templates/` (or equivalent).

## Bootstrap or index (first galley)

**New product** — Create a galley whose README defines:
- What is the product?
- Who are the primary users?
- Key journeys and initial modules
- Constraints

**Existing product** — Create a galley whose README documents current state: modules, capabilities, where things live.

Outcome: `docs/domain/index.md` (or `docs/context/app-context.md`) reflects reality; team aligned on what exists.

## First vertical slice

Create a galley with one or more slugs that deliver the smallest end-to-end slice of real value. Outcome: one key journey works; module docs updated; proof in slug/review.

## Creating slugs

Use `cli/linotype slug new <galley-name> <slug-name>` when your CLI supports it. Slug names: kebab-case (e.g. `auth-backend`, `ui-login`). Each slug file lives inside the galley (e.g. `slugs/<slug-name>.md`).

## More

- [Galleys](galleys.html) — README structure, lifecycle, parallel workflow  
- [Quick reference](quick-reference.html) — Commands  
- Skeleton: `linotype-skeleton/docs/work/planning/` for example galley layout and templates  
