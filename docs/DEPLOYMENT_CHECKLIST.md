# LessonLens Deployment Checklist

Print this page and check off each step as you complete it. Fill in your values in the blanks.

---

## Your District Configuration

| Field | Value |
|-------|-------|
| GCP Project ID | ______________________________ |
| GCP Region | ______________________________ |
| Google Workspace Domain | ______________________________ |
| Bundle ID | ______________________________ |
| Gemini API Key | ______________________________ |
| Google OAuth Client ID | ______________________________ |
| Cloud Run URL | ______________________________ |
| Apple Developer Team ID | ______________________________ |
| MDM Solution | ______________________________ |

---

## Phase 1: Google Cloud Setup

- [ ] Created GCP project: `________________________`
- [ ] Linked billing account
- [ ] Enabled Cloud Run Admin API
- [ ] Enabled Secret Manager API
- [ ] Enabled Artifact Registry API
- [ ] Enabled Cloud Build API
- [ ] Created Gemini API key at ai.google.dev
- [ ] Created OAuth Client ID (type: **iOS**, bundle ID matches above)

## Phase 2: Backend Deployment

**Option A — Script** (recommended):
- [ ] Ran `bash scripts/setup.sh`
- [ ] Verified health check passed

**Option B — Manual:**
- [ ] Set project: `gcloud config set project PROJECT_ID`
- [ ] Generated JWT secret: `openssl rand -base64 48`
- [ ] Stored `jwt-secret` in Secret Manager
- [ ] Stored `gemini-api-key` in Secret Manager
- [ ] Stored `google-client-id` in Secret Manager
- [ ] Deployed to Cloud Run: `gcloud run deploy lessonlens-api ...`
- [ ] Verified health check: `curl CLOUD_RUN_URL` → returns `"healthy"`

Cloud Run URL: `________________________________________`

## Phase 3: App Configuration

**Option A — Script** (recommended):
- [ ] Ran `bash scripts/configure-app.sh`
- [ ] Validation passed (no old references remaining)

**Option B — Manual:**
- [ ] Updated `ServiceContainer.swift` — backendURL, googleClientID, allowedDomain
- [ ] Updated bundle ID in `project.pbxproj` (2 occurrences)
- [ ] Updated bundle ID in `AppState.swift` (keychain keys)
- [ ] Updated bundle ID in `KeychainService.swift`
- [ ] Updated bundle ID in `Recording.swift`
- [ ] Updated bundle ID in `RecordingService.swift`
- [ ] Updated bundle ID in `AudioImportService.swift`
- [ ] Updated bundle ID in `VideoImportService.swift`
- [ ] Updated bundle ID in `AudioExtractionService.swift`
- [ ] Updated bundle ID in `SettingsView.swift`
- [ ] Updated district name in `LoginView.swift`
- [ ] Updated domain text in `LoginView.swift`
- [ ] Verified: `grep -r "com.peninsula.lessonlens"` returns zero results

## Phase 4: Build, Sign & Distribute

- [ ] Opened `LessonLens.xcodeproj` in Xcode
- [ ] Selected Apple Developer team in Signing & Capabilities
- [ ] Verified bundle ID matches: `________________________`
- [ ] Built successfully (Product → Build)
- [ ] Archived (Product → Archive)
- [ ] Submitted for notarization (Distribute App → Developer ID → Upload)
- [ ] Notarization succeeded
- [ ] Exported notarized `.app`
- [ ] Packaged as `.pkg`: `pkgbuild --component ... --install-location /Applications LessonLens.pkg`
- [ ] Uploaded `.pkg` to MDM
- [ ] Assigned to teacher devices/groups
- [ ] Deployed via MDM

## Phase 5: Verification

- [ ] App launches on a teacher's Mac
- [ ] Google Sign-In screen appears
- [ ] Login with `@________________________` account succeeds
- [ ] App connects to backend (no connection errors)
- [ ] Test recording works (record 5+ minutes)
- [ ] Analysis completes successfully
- [ ] Chat follow-up works

## Optional: Branding

- [ ] Updated district name on login screen
- [ ] Updated domain display text
- [ ] Replaced app icon (if desired)
- [ ] Updated accent colors (if desired)

---

**Deployment completed by:** ______________________________ **Date:** ______________

**Notes:**

______________________________________________________________________

______________________________________________________________________

______________________________________________________________________
