# Linotype

Linotype is an operating model for building complex products while keeping coherence over time.

- Method: BMAD (how you plan and build inside a Slug)
- Operating model: Linotype (how the system stays coherent across Slugs)
- Unit of work: Slug (smallest delegable change)

## Quick start

**New to Linotype?** → [Getting Started Guide](GETTING_STARTED.md)

From an empty folder:

```bash
curl -fsSL https://raw.githubusercontent.com/zylum/linotype/main/linotype-bootstrap.sh | bash
./linotype.sh init
```

This creates:
- Core documentation structure
- Workflow scripts
- Templates for slugs
- Starter slugs (SLUG-001 and SLUG-002)

### Next steps

1. Complete SLUG-001 (choose one):
   - `docs/work/planning/SLUG-001.bootstrap-linotype.md` (new product)
   - `docs/work/planning/SLUG-001.index-linotype.md` (existing product)

2. Start your first slug:
   ```bash
   ./linotype.sh start SLUG-002.first-vertical-slice
   ```

3. Do the work, add proof to build notes, then:
   ```bash
   ./linotype.sh review SLUG-002.first-vertical-slice
   ./linotype.sh done SLUG-002.first-vertical-slice
   ```

### Key commands

```bash
./linotype.sh start <slug-name>   # Move from planning to doing
./linotype.sh check <slug-name>   # Verify ready for review
./linotype.sh review <slug-name>  # Move to review (requires proof)
./linotype.sh done <slug-name>    # Complete the slug
```

See [Quick Reference](docs/quick-reference.md) for more.

### Or explore this repo

```bash
git clone https://github.com/zylum/linotype.git
cd linotype
```

## Core structure

After bootstrapping, you'll have:
- `docs/context/app-context.md` - High-level product snapshot
- `docs/capabilities/` - Module specs and capability registry
- `docs/work/` - Slug workflow (planning/doing/review/done)
- `docs/templates/` - Templates for slugs and build notes
- `linotype.sh` - Workflow automation script

## Documentation

- [Quick Reference](docs/quick-reference.md) ⚡
- [What is Linotype?](docs/what-is-linotype.md)
- [Structure](docs/structure.md)
- [How to use](docs/how-to-use.md)
- [Roles](docs/roles.md)
- [Slug types](docs/slug-types.md)
- [FAQ](docs/faq.md)
- [v3 changes](docs/v3.md)

## License

MIT
