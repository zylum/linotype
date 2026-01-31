# Roles

## Product Design Authority (PDA)
Owns system coherence over time.

### Responsibilities
- Frames change and sequences work
- Creates Galleys to coordinate multi-module changes
- Breaks work into execution slugs
- Validates end-to-end coherence at review
- Ensures top-level docs stay in sync with reality

### In a Galley
- Defines user outcome
- Identifies impacted modules
- Explicitly lists execution slugs
- Defines constraints and non-goals
- Decides sequencing and readiness for integration
- Validates integration when all slugs are complete

## Module Architect
Owns a module's correctness and evolution.

### Responsibilities
- Designs and builds within module boundaries
- Validates locally
- Updates module docs and decisions
- Executes assigned slugs
- Respects Galley boundaries (doesn't expand scope)

### In a Galley
- Executes assigned execution slugs
- Updates module specs and features
- Flags scope changes to PDA
- Communicates progress

## Builder
Executes a build slug within boundaries.
Often the same person as Module Architect in small teams.

## Reviewer
Verifies proof and coherence before completion.
In solo use, this is often the PDA role.

### Slug-level review
- Does this slug meet its acceptance checks?
- Is Proof present?
- Are module docs updated?

### Galley-level integration review (PDA)
- Are all child slugs complete?
- Does the combined system realise the original intent?
- Do top-level docs still describe reality?
