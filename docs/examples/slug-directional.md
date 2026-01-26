# Example Directional Slug

This example shows a typical directional slug for exploration and decision-making.

## SLUG-038: Decide authentication approach for API

### Slug type
Directional

### Context
We need to secure the new public API. Multiple approaches exist, each with trade-offs.

### Options explored

#### Option 1: JWT tokens
Pros:
- Stateless
- Standard, well-understood
- Easy to validate

Cons:
- Cannot revoke before expiry
- Larger payload size
- Requires key rotation strategy

#### Option 2: Opaque tokens with Redis
Pros:
- Can revoke instantly
- Smaller token size
- Fine-grained control

Cons:
- Requires Redis infrastructure
- Adds latency for validation
- More complex to operate

#### Option 3: API keys (long-lived)
Pros:
- Simple for users
- No expiry management
- Easy to implement

Cons:
- Security risk if leaked
- No automatic rotation
- Harder to scope permissions

### Analysis

For our use case:
- API will be used by trusted partners (not public)
- Need ability to revoke access quickly
- Already running Redis for sessions
- Latency not critical (< 100ms acceptable)

### Decision

Use opaque tokens with Redis (Option 2).

Rationale:
- Instant revocation is critical for partner API
- Redis already in infrastructure
- Can add rate limiting easily
- Token size matters for mobile clients

Logged in: `docs/capabilities/modules/api/decisions.md`

### Follow-on slugs created

- SLUG-039 (Build): Implement token generation endpoint
- SLUG-040 (Build): Implement token validation middleware
- SLUG-041 (Build): Add token management UI for admins

### Proof

- Decision entry: `docs/capabilities/modules/api/decisions.md` (commit def456)
- Follow-on slugs: created in `docs/work/planning/`
