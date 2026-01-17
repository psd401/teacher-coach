# Teacher Coach

Native macOS app for Peninsula SD teachers to record teaching sessions, receive local transcription via WhisperKit, and get AI-powered feedback on specific teaching techniques via Claude Opus 4.5.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    macOS App (SwiftUI)                      │
├─────────────────────────────────────────────────────────────┤
│  Recording → Transcription (WhisperKit) → Analysis Request  │
│                           ↓                                 │
│              Local Storage (SwiftData + Audio Files)        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ↓ HTTPS
┌─────────────────────────────────────────────────────────────┐
│              Cloudflare Workers Backend                      │
├─────────────────────────────────────────────────────────────┤
│  /auth/validate  │  /analyze (proxy)  │  Rate Limiting      │
│  Google JWT →    │  → Claude API      │  (20 req/hr/user)   │
│  Domain check    │  (API key secured) │                     │
└─────────────────────────────────────────────────────────────┘
```

## Requirements

### macOS App
- macOS 14.0+ (Sonoma)
- Xcode 15.2+
- Apple Silicon Mac (for WhisperKit)

### Backend
- Node.js 18+
- Cloudflare Workers account
- Anthropic API key

## Project Structure

```
TeacherCoach/
├── TeacherCoach/              # macOS App
│   ├── App/                   # App entry point, state, DI
│   ├── Features/              # Feature modules
│   │   ├── Authentication/    # Google SSO
│   │   ├── Recording/         # Audio recording
│   │   ├── Transcription/     # WhisperKit integration
│   │   ├── Analysis/          # Claude API integration
│   │   ├── Techniques/        # Teaching technique library
│   │   └── Settings/          # User preferences
│   ├── Core/                  # Shared code
│   │   ├── Models/            # SwiftData models
│   │   ├── Views/             # Shared UI components
│   │   └── Services/          # Utility services
│   └── Resources/             # Info.plist, entitlements
└── CloudflareWorker/          # Backend API
    └── src/routes/            # API routes
```

## Setup

### 1. Configure Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google Sign-In API
4. Create OAuth 2.0 credentials (macOS application)
5. Set authorized redirect URI: `com.peninsula.teachercoach:/oauth2callback`
6. Note the Client ID

### 2. Deploy Backend

```bash
cd CloudflareWorker
npm install

# Set secrets
wrangler secret put CLAUDE_API_KEY
wrangler secret put GOOGLE_CLIENT_ID
wrangler secret put JWT_SECRET

# Create KV namespace for rate limiting
wrangler kv:namespace create RATE_LIMIT
# Update wrangler.toml with the namespace ID

# Deploy
npm run deploy
```

### 3. Build macOS App

```bash
cd TeacherCoach

# Open in Xcode
open TeacherCoach.xcodeproj

# In Xcode:
# 1. Set your Development Team in Signing & Capabilities
# 2. Update GOOGLE_CLIENT_ID in environment or config
# 3. Build and run (⌘R)
```

### 4. Environment Variables

Create a `.env` file or set in Xcode scheme:

```
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
```

## Teaching Techniques

The app evaluates 10 research-based teaching techniques:

| Category | Techniques |
|----------|------------|
| Questioning | Wait Time, Higher-Order Questions |
| Engagement | Cold Calling, Think-Pair-Share |
| Feedback | Specific Praise, Check for Understanding |
| Management | Positive Framing |
| Instruction | Modeling/Think Aloud, Scaffolded Practice |
| Differentiation | Strategic Grouping |

Each technique includes:
- Description
- Look-fors (observable indicators)
- Exemplar phrases

## Privacy

- **Audio stays local**: Recordings are stored only on the user's device
- **Only transcripts sent**: Audio is transcribed locally, only text is sent for analysis
- **Domain-restricted**: Only @peninsula.wednet.edu accounts can sign in
- **Secure storage**: Session tokens stored in macOS Keychain

## API Endpoints

### `POST /auth/validate`
Validates Google ID token and returns session token.

### `POST /auth/refresh`
Refreshes expired session token.

### `POST /analyze`
Analyzes transcript for teaching techniques.

### `GET /analyze/rate-limit`
Returns current rate limit status.

## Development

### Run Backend Locally
```bash
cd CloudflareWorker
npm run dev
```

### Run Tests
```bash
# Backend
cd CloudflareWorker
npm test

# macOS App (in Xcode)
⌘U
```

## Deployment

### Jamf MDM Distribution

1. Archive the app in Xcode (Product → Archive)
2. Export with Developer ID signing
3. Notarize the app
4. Create DMG or PKG installer
5. Upload to Jamf for distribution

## License

Copyright © 2024 Peninsula School District. Internal use only.
