# Contributing to Linotype

Thanks for your interest in improving Linotype.

## How to contribute

### Reporting issues
- Check existing issues first to avoid duplicates
- Provide clear description of the problem
- Include examples if relevant

### Suggesting improvements
- Open an issue describing the improvement
- Explain the use case and why it matters
- Consider how it fits with Linotype's principles

### Submitting changes
1. Fork the repository
2. Create a branch for your change
3. Make your changes following the guidelines below
4. Test your changes
5. Submit a pull request

## Guidelines

### Documentation changes
- Keep language clear and concise
- Use examples to illustrate concepts
- Maintain consistency with existing docs
- Update relevant examples if changing core concepts

### Script changes
- Test on both macOS and Linux
- Maintain backward compatibility when possible
- Document breaking changes clearly
- Update VERSION and CHANGELOG.md

### Principles to preserve
- Coherence over time
- Minimal process overhead
- Clear boundaries and delegation
- Proof-backed completion
- Reality-driven documentation

## Development workflow

Linotype uses itself for development:
1. Create a slug for your change in `docs/work/planning/`
2. Start it: `./linotype.sh start SLUG-XXX.your-change`
3. Do the work and update build notes with proof
4. Move to review: `./linotype.sh review SLUG-XXX.your-change`
5. Submit PR when slug is in review
6. Complete after merge: `./linotype.sh done SLUG-XXX.your-change`

## Questions?

Open an issue or discussion. We're happy to help.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
