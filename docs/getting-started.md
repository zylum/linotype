# Getting started

Your first steps with Linotype.

## In 10 minutes

1. **Bootstrap** — Use the [Linotype skeleton](https://github.com/zylum/linotype/tree/main/linotype-skeleton): copy `linotype-skeleton/` into your repo or run `cli/linotype-bootstrap.sh`. Ensure `docs/ai/_agent-rules.md` and root `AGENTS.md` exist.
2. **Create a galley** — `cli/linotype galley new <name>` (e.g. `20260209-first-slice`). Add slugs under the galley.
3. **Move to doing** — `cli/linotype galley move <name> doing`. Do the work; update slug files; commit with `slug:<slug-name> done - <summary> #galley:<galley-name>`.
4. **Move to review** — When all slugs are done, `cli/linotype galley move <name> review`. Fill galley `review.md`; commit `galley:<name> ready for review - <summary>`.

## New product

- Create a galley (e.g. bootstrap or index). In the galley README, define: what is the product, who are the users, key journeys, initial modules, constraints.
- Complete one slug that establishes `docs/domain/index.md` (or `docs/context/app-context.md`) and optional capability registry.
- Then create a “first vertical slice” galley and execute its slugs.

## Existing product

- Create a galley (e.g. index). Document current state: existing modules, capabilities, where things live.
- Add slugs that capture the as-is; then use galleys for all new work.

## What’s next?

- [How to use](how-to-use.html) — Workflow and CLI in detail  
- [Quick reference](quick-reference.html) — Commands and structure  
- [Galleys](galleys.html) — Lifecycle, queue, parallel work  
- [FAQ](faq.html) — Common questions  

## Principles

1. Use `cli/linotype galley move` to change stages (don’t move folders manually).
2. One active Executor per galley; record proof and decisions in slug/review artefacts.
3. Keep docs in sync with reality; prefer small, delegable slugs.
