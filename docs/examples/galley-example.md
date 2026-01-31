# Example Galley: User Authentication Redesign

This example shows how a Galley coordinates multiple module-level slugs into a coherent product change.

## Galley structure

```
docs/work/planning/GALLEY-20250201-user-auth-redesign/
├── README.md
├── research-notes.md
└── architecture.md
```

## GALLEY-20250201-user-auth-redesign/README.md

### User outcome
Users can now log in with passkeys, reducing friction and improving security. Password login remains available for backward compatibility.

### Impacted modules
- **auth**: Implement passkey support in backend
- **ui**: Update login form to support passkey entry
- **api**: Add passkey endpoints and validation

### Execution slugs
- SLUG-042: Implement passkey backend (auth)
- SLUG-043: Update login UI (ui)
- SLUG-044: Add passkey API endpoints (api)

### Constraints
- Must maintain backward compatibility with password login
- Must work on iOS and Android
- Must not break existing sessions
- Must pass security audit before launch

### Non-goals
- Deprecating passwords (future Galley)
- Biometric integration (future Galley)
- Admin passkey management (future Galley)
- Passwordless-only mode (future Galley)

### Sequencing
1. **SLUG-042** (backend) - Start immediately, no dependencies
2. **SLUG-043** (UI) - Can start after SLUG-042 API is ready
3. **SLUG-044** (API) - Can start with SLUG-042, depends on SLUG-042 backend

Parallel execution: SLUG-042 and SLUG-044 can run in parallel. SLUG-043 waits for SLUG-042.

### Integration criteria
- All three slugs in done
- E2E tests pass on iOS and Android
- Security audit completed
- app-context.md updated with new auth flow
- No regressions in existing auth tests
- PDA sign-off on intent vs reality

---

## Execution slugs created from this Galley

### SLUG-042: Implement passkey backend

```markdown
# SLUG: SLUG-042 Implement passkey backend

## Parent Galley
GALLEY-20250201-user-auth-redesign

## Outcome
Backend can generate, store, and validate passkeys for user authentication.

## Owning module
auth

## Scope
- Changes:
  - Add passkey generation endpoint
  - Add passkey storage in database
  - Add passkey validation logic
  - Update session creation to support passkey auth
- Not in scope:
  - UI changes (SLUG-043)
  - Public API endpoints (SLUG-044)

## Impacted capabilities
- User authentication

## Dependencies
- None (can start immediately)

## Acceptance checks
- [ ] Passkey generation works end-to-end
- [ ] Passkeys stored securely in database
- [ ] Validation rejects invalid passkeys
- [ ] Sessions created correctly from passkey auth
- [ ] Backward compatibility with password login maintained

## Size check
- Touches: auth module backend (3-4 files)
- Buildable in: 1 day

## Docs to update
- [ ] Module spec/features (auth module)
- [ ] Decisions (if auth boundaries changed)
```

### SLUG-043: Update login UI

```markdown
# SLUG: SLUG-043 Update login UI

## Parent Galley
GALLEY-20250201-user-auth-redesign

## Outcome
Users see passkey option on login form and can authenticate with passkey.

## Owning module
ui

## Scope
- Changes:
  - Add passkey button to login form
  - Add passkey entry flow
  - Update form validation
- Not in scope:
  - Backend implementation (SLUG-042)
  - API endpoints (SLUG-044)

## Impacted capabilities
- User authentication UI

## Dependencies
- SLUG-042 (backend must be ready)

## Acceptance checks
- [ ] Passkey button visible on login form
- [ ] Passkey entry flow works on iOS and Android
- [ ] Form validation prevents invalid input
- [ ] Error messages are clear
- [ ] Fallback to password login works

## Size check
- Touches: ui module (2-3 files)
- Buildable in: 1 day

## Docs to update
- [ ] Module spec/features (ui module)
```

### SLUG-044: Add passkey API endpoints

```markdown
# SLUG: SLUG-044 Add passkey API endpoints

## Parent Galley
GALLEY-20250201-user-auth-redesign

## Outcome
Public API clients can authenticate using passkeys via new endpoints.

## Owning module
api

## Scope
- Changes:
  - Add POST /auth/passkey/register endpoint
  - Add POST /auth/passkey/authenticate endpoint
  - Add request/response validation
- Not in scope:
  - Backend implementation (SLUG-042)
  - UI changes (SLUG-043)

## Impacted capabilities
- Public API authentication

## Dependencies
- SLUG-042 (backend must be ready)

## Acceptance checks
- [ ] Endpoints accept valid passkey requests
- [ ] Endpoints reject invalid requests
- [ ] Rate limiting works
- [ ] API docs updated
- [ ] Backward compatibility maintained

## Size check
- Touches: api module (2-3 files)
- Buildable in: 1 day

## Docs to update
- [ ] Module spec/features (api module)
- [ ] API documentation
```

---

## Galley lifecycle in this example

### 1. Planning (PDA)
PDA creates the Galley folder and README.
Includes research on passkey standards and architecture decisions.
Identifies the three modules that need to change.
Lists execution slugs and sequencing.

### 2. Slug creation (PDA)
PDA creates SLUG-042, SLUG-043, SLUG-044 as files in `docs/work/planning/`.
Each slug references the parent Galley.
Module Owners review their assigned slugs.

### 3. Parallel execution (Module Owners)
- Auth team starts SLUG-042 immediately
- API team starts SLUG-044 (can run in parallel with SLUG-042)
- UI team waits for SLUG-042 to be ready, then starts SLUG-043

Each slug moves through planning → doing → review → done independently.

### 4. Integration review (PDA)
When all three slugs are in done:
- PDA verifies combined system works end-to-end
- E2E tests pass on both platforms
- Security audit completed
- app-context.md updated with new auth flow
- No regressions in existing tests

### 5. Completion
Galley is marked complete.
Learnings captured (e.g., "passkey adoption was higher than expected").
Follow-on Galley created if needed (e.g., "Deprecate password login").

---

## Key insights from this example

1. **Galley is planning, not implementation** - The README defines intent and decomposition, not code.

2. **Slugs are independent** - Each slug can be worked on separately, with clear ownership.

3. **Parallel execution is explicit** - The Galley shows which slugs can run in parallel and which have dependencies.

4. **Traceability is preserved** - Each slug references its parent Galley, so you can always see why it exists.

5. **Integration is a separate concern** - PDA validates that the combined system realises the original intent.

6. **Scope is bounded** - Non-goals are explicit, preventing scope creep.
