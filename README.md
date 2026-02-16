# Linotype 

Linotype is an operating model for building complex products while keeping coherence over time.

**🌐 Website:** [GitHub Pages](https://zylum.github.io/linotype/) (docs in this repo). To enable: **Settings → Pages → Source:** Deploy from branch → **Branch:** main, **Folder:** /docs.

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
   - `docs/work/planning/slug-001-bootstrap-linotype/` (new product)
   - `docs/work/planning/slug-001-index-linotype/` (existing product)

2. Move a galley to queue and start work:
   ```bash
   ./linotype.sh galley move slug-002-first-vertical-slice queue
   ```

3. When ready, move to review and then done:
   ```bash
   ./linotype.sh galley move slug-002-first-vertical-slice review
   ./linotype.sh galley move slug-002-first-vertical-slice done
   ```

### Key commands

```bash
./linotype.sh galley new <galley-name>              # Create a galley
./linotype.sh galley move <galley-name> queue       # Move to queue (ready for work)
./linotype.sh galley move <galley-name> doing       # Move to doing (in progress)
./linotype.sh galley move <galley-name> review      # Move to review
./linotype.sh galley move <galley-name> done        # Complete the galley
./linotype.sh galley list                          # List all galleys
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
- `docs/learning/` - Learning layer (v0.5): signals, reflections, snapshots
- `linotype.sh` - Workflow automation script (wrapper for `cli/linotype.sh`)

## Learning layer (v0.5)

Capture signals and context across your product lifecycle:

```bash
./linotype.sh signal add "observation" --app myapp --area core
./linotype.sh bundle snapshot --app myapp --area core
```

- `docs/learning/inbox/` - Raw reflections
- `docs/learning/signals/` - Normalised signals (S-### IDs)
- `docs/learning/snapshots/` - Compiled context for agents

See [v0.5 changes](docs/v5.md) for migration guide.

## Documentation

- [Quick Reference](docs/quick-reference.md) ⚡
- [What is Linotype?](docs/what-is-linotype.md)
- [Structure](docs/structure.md)
- [How to use](docs/how-to-use.md)
- [Roles](docs/roles.md)
- [Slug types](docs/slug-types.md)
- [Galleys](docs/galleys.md) (v0.4 preview)
- [FAQ](docs/faq.md)
- [v0.3 changes](docs/v3.md)
- [v0.4 changes](docs/v4.md)
- [v0.5 changes](docs/v5.md) — Learning layer, signals, snapshots
- [v0.6 changes](docs/v6.md) — LinoLoop execution wrapper and releases

## License

MIT
