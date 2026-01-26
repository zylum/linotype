# Example Build Slug

This example shows a typical build slug for implementing a concrete feature.

## SLUG-042: Add user profile avatar upload

### Slug type
Build

### Boundaries
- Module: user-profile
- Files: `components/ProfileAvatar.tsx`, `api/upload.ts`, `docs/capabilities/modules/user-profile/decisions.md`
- Out of scope: image processing pipeline (separate slug)

### Map
Current state:
- Profile page shows default avatar only
- No upload mechanism exists

Target state:
- Users can upload custom avatars
- Avatars display on profile page
- File size limited to 2MB

### Analysis
Options considered:
1. Direct S3 upload (chosen - simpler, less server load)
2. Server proxy upload (rejected - unnecessary complexity)

Decision: Use presigned S3 URLs for direct browser upload.
Logged in: `docs/capabilities/modules/user-profile/decisions.md`

### Design
Components:
- `ProfileAvatar`: display + upload button
- `useAvatarUpload`: hook for upload logic
- `POST /api/avatar/presign`: generate upload URL

### Build
Implemented:
- Avatar upload component with preview
- Presigned URL generation endpoint
- S3 bucket configuration
- Error handling for size/type validation

### Validate
- Manual test: uploaded 1.5MB jpg → success
- Manual test: attempted 3MB file → rejected with clear error
- Manual test: uploaded png → success
- Code review: security checks in place

### Proof
- Screenshot: [avatar-upload-working.png](proof/avatar-upload-working.png)
- Commit: abc123f
- Preview URL: https://staging.example.com/profile

### Document
Updated:
- `docs/capabilities/modules/user-profile/spec.md` - added avatar upload section
- `docs/capabilities/modules/user-profile/decisions.md` - logged S3 direct upload decision
