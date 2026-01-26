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
- Workflow scripts
- Templates
- Two starter slugs

## Step 2: Complete SLUG-001

Choose one based on your situation:

### For a new product
Edit `docs/work/planning/SLUG-001.bootstrap-linotype.md` and fill in:
- What is this product?
- Who are the primary users?
- What are the key journeys?
- What modules/domains exist?
- What constraints apply?

### For an existing product
Edit `docs/work/planning/SLUG-001.index-linotype.md` and document:
- Current product state
- Existing modules/domains
- Key capabilities
- Where things live

Delete the SLUG-001 file you didn't use.

## Step 3: Start SLUG-002

```bash
./linotype.sh start SLUG-002.first-vertical-slice
```

This moves the slug to `docs/work/doing/` and creates build notes.

Edit `docs/work/doing/SLUG-002.first-vertical-slice.md`:
- Define the smallest end-to-end slice
- Identify which modules are involved
- Set clear acceptance checks

## Step 4: Build and prove

Do the work, then update `docs/work/doing/SLUG-002.first-vertical-slice.build-notes.md`:
- What shipped
- What changed
- Proof (URL, screenshot, commit, or test output)

## Step 5: Move to review

```bash
./linotype.sh review SLUG-002.first-vertical-slice
```

The script checks that proof exists before allowing the move.

## Step 6: Complete

After review:

```bash
./linotype.sh done SLUG-002.first-vertical-slice
```

The slug moves to `docs/work/done/`.

## What's next?

- Create more slugs in `docs/work/planning/`
- Update module specs in `docs/capabilities/modules/`
- Keep `docs/context/app-context.md` in sync with reality
- Log small fixes in `docs/work/doing/small-fixes.md`

## Need help?

- [Quick Reference](docs/quick-reference.md) - Command cheat sheet
- [How to use](docs/how-to-use.md) - Detailed workflow guide
- [FAQ](docs/faq.md) - Common questions
- [Structure](docs/structure.md) - Understanding the folders

## Key principles

1. Use `./linotype.sh` to move slugs (don't move files manually)
2. Build notes must include proof before review
3. Keep docs in sync with reality
4. Prefer small, delegable slugs over big plans
