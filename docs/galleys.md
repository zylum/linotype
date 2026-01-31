# Galleys

A Galley is a temporary grouping of execution slugs that together realise one product change.

## What is a Galley?

**Galley = Intent + Decomposition, not Delivery**

A Galley is:
- A planning artefact owned by PDA
- A folder containing a brief and supporting research
- A way to group related slugs without forcing hierarchy
- A coordination point for parallel module work

A Galley is NOT:
- A unit of work (slugs are)
- A container for implementation
- A replacement for module autonomy
- Required for every slug

## When to use a Galley

Use a Galley when:
- Multiple modules need to coordinate on a single product change
- You want to preserve the "why" across multiple slugs
- You're planning parallel work that needs sequencing
- You want to track integration and learnings

Skip a Galley when:
- The change is small and fits in one slug
- It's a standalone fix in a single module
- You're still exploring (use a Directional slug instead)

## Galley structure

A Galley lives as a folder in `docs/work/planning/`:

```
docs/work/planning/GALLEY-YYYYMMDD-name/
├── README.md              (the Galley brief)
├── research-notes.md      (optional)
├── architecture.md        (optional)
├── ux-sketches.md         (optional)
└── assumptions.md         (optional)
```

### GALLEY-YYYYMMDD-name format

- `GALLEY` - Prefix (like SLUG)
- `YYYYMMDD` - Date created
- `name` - Descriptive name (kebab-case)

Example: `GALLEY-20250201-user-auth-redesign`

## What goes in a Galley README

The README is the Galley brief. It answers:

### User outcome
What will users be able to do that they can't today?

### Impacted modules
Which modules will change? List each with one line of impact.

### Execution slugs
Explicit list of slugs to be created:
- SLUG-XXX: Description (primary module)
- SLUG-YYY: Description (primary module)

### Constraints
What must be true? What can't change?

### Non-goals
What are we explicitly NOT doing?

### Sequencing
Do any slugs depend on others? What's the order?

### Integration criteria
How do we know this Galley is complete?
- All slugs in done
- Integration tested
- Top-level docs updated
- PDA sign-off

## Execution slugs reference their Galley

Each slug created from a Galley includes:

```markdown
## Parent Galley
GALLEY-20250201-user-auth-redesign
```

This gives traceability: you can always see why a slug exists.

## Galley lifecycle

### 1. Planning
PDA creates the Galley folder and README.
Includes research, assumptions, non-goals.
No implementation yet.

### 2. Slug creation
PDA creates execution slugs (as files, not in the Galley folder).
Each slug references the parent Galley.
Module Owners review and start work.

### 3. Parallel execution
Each slug moves through planning → doing → review → done independently.
Module Owners own their slugs.
PDA monitors progress.

### 4. Integration review
When all slugs are in review/done:
- PDA verifies combined system realises original intent
- Top-level docs (app-context, registry) are updated
- Learnings are captured
- Follow-on Galleys created if scope changed

### 5. Completion
Galley is "complete" when:
- All child slugs are in done
- Integration is tested
- PDA signs off on intent vs reality

## PDA responsibilities in a Galley

Define the user outcome
- What problem does this solve?
- What's the measurable change?

Identify impacted modules
- Which modules will change?
- What's the scope of each?

Explicitly list execution slugs
- What work needs to happen?
- In what order?
- Who owns each?

Define constraints and non-goals
- What must stay true?
- What are we NOT doing?

Decide sequencing and readiness
- Can work be parallel?
- Are there dependencies?
- When is it safe to integrate?

## Module Owner responsibilities

Execute assigned slugs
- Own the implementation
- Update module docs
- Provide proof

Respect Galley boundaries
- Don't expand scope beyond the Galley
- Don't create new slugs outside the Galley
- Flag scope changes to PDA

Communicate progress
- Update slug status
- Flag blockers early
- Suggest follow-on work

## Example: User authentication redesign

```
GALLEY-20250201-user-auth-redesign/
├── README.md
├── research-notes.md
└── architecture.md
```

### README content

**User outcome**
Users can now log in with passkeys, reducing friction and improving security.

**Impacted modules**
- auth: Implement passkey support
- ui: Update login form
- api: Add passkey endpoints

**Execution slugs**
- SLUG-042: Implement passkey backend (auth)
- SLUG-043: Update login UI (ui)
- SLUG-044: Add passkey API endpoints (api)

**Constraints**
- Must maintain backward compatibility with password login
- Must work on iOS and Android
- Must not break existing sessions

**Non-goals**
- Deprecating passwords (future Galley)
- Biometric integration (future Galley)
- Admin passkey management (future Galley)

**Sequencing**
1. SLUG-042 (backend) - can start immediately
2. SLUG-043 (UI) - depends on SLUG-042 API
3. SLUG-044 (API) - can start with SLUG-042

**Integration criteria**
- All three slugs in done
- E2E tests pass on both platforms
- app-context.md updated with new auth flow
- No regressions in existing auth tests

## Galley vs Directional slug

Both are planning artefacts. When to use each?

**Use Directional slug when:**
- Exploring options for a single module
- Making a decision that affects one module
- Output is a decision, not a product change

**Use Galley when:**
- Coordinating multiple modules
- Realising a product change
- Output is integrated, working software

Example:
- Directional slug: "Should we use passkeys or WebAuthn?"
- Galley: "Implement passkey support across auth, ui, and api"

## Galley and agents

Agents (Claude, Kiro) respect Galley boundaries:

Agents may:
- Operate as PDA assistants within a Galley (help write the brief)
- Operate as Module Owners within a single execution slug
- Suggest follow-on Galleys based on learnings

Agents never:
- Invent new Galleys
- Change Galley intent
- Span multiple execution slugs at once
- Create slugs outside a Galley's scope

This keeps agents predictable and trustworthy.

## Keeping track of what we've built

Execution slugs are responsible for:
- Updating module specs
- Updating features
- Updating decisions when boundaries change

Galley responsibility:
- Ensure the overall product narrative still makes sense
- Capture learnings or follow-on Galleys if scope changed
- Update app-context.md if user-facing behaviour changed

This reinforces Linotype as system memory for humans and agents.
