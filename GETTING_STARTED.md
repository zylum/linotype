# Getting Started with Linotype

Welcome! This guide will get you up and running with Linotype in 10 minutes.

## What you'll do

1. Bootstrap the structure
2. Complete SLUG-001 (define or index your product)
3. Start SLUG-002 (first vertical slice)
4. Move a slug through the workflow

## Step 1: Bootstrap

In an empty folder:

```bash
curl -fsSL https://raw.githubusercontent.com/zylum/linotype/main/linotype-bootstrap.sh | bash
./linotype.sh init
```

This creates:
- Documentation structure
- Workflow scripts (`linotype.sh`, `cli/linotype.sh`)
- Templates
- Starter galleys: slug-001-bootstrap-linotype, slug-001-index-linotype, slug-002-first-vertical-slice

## Step 2: Complete SLUG-001

Choose one galley based on your situation:

### For a new product
Edit `docs/work/planning/slug-001-bootstrap-linotype/` (README.md, context.md) and fill in:
- What is this product?
- Who are the primary users?
- What are the key journeys?
- What modules/domains exist?
- What constraints apply?

### For an existing product
Edit `docs/work/planning/slug-001-index-linotype/` and document:
- Current product state
- Existing modules/domains
- Key capabilities
- Where things live

You can ignore or remove the SLUG-001 galley you didn't use.

## Step 3: Start SLUG-002

```bash
./linotype.sh galley move slug-002-first-vertical-slice queue
./linotype.sh galley move slug-002-first-vertical-slice doing
```

This moves the galley to `docs/work/doing/`. Edit the galley (e.g. `docs/work/doing/slug-002-first-vertical-slice/README.md`, `run-sheet.md`) and add slugs under `slugs/`:
- Define the smallest end-to-end slice
- Identify which modules are involved
- Set clear acceptance checks

## Step 4: Build and prove

Do the work, then update the galley's `review.md` and slug files:
- What shipped
- What changed
- Proof (URL, screenshot, commit, or test output)

## Step 5: Move to review

```bash
./linotype.sh galley move slug-002-first-vertical-slice review
```

## Step 6: Complete

After review:

```bash
./linotype.sh galley move slug-002-first-vertical-slice done
```

The galley moves to `docs/work/done/`.

## What's next?

- Create more galleys: `./linotype.sh galley new <galley-name>`
- Add slugs to a galley: `./linotype.sh slug new <galley-name> <slug-name>`
- Update module specs in `docs/` as needed
- Log small fixes in `docs/work/doing/small-fixes.md`

## Need help?

- [Quick Reference](docs/quick-reference.md) - Command cheat sheet
- [How to use](docs/how-to-use.md) - Detailed workflow guide
- [FAQ](docs/faq.md) - Common questions
- [Structure](docs/structure.md) - Understanding the folders

## Key principles

1. Use `./linotype.sh galley move` to move galleys (don't move files manually)
2. Build notes must include proof before review
3. Keep docs in sync with reality
4. Prefer small, delegable slugs over big plans
