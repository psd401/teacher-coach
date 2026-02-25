# Teacher Coach

Native macOS app for Peninsula SD teachers to record teaching sessions, receive local transcription via WhisperKit, and get AI-powered feedback on specific teaching techniques.

## Features

- **Live Recording** - Record teaching sessions directly in the app
- **Audio Import** - Import voice memos and audio files (M4A, MP3, WAV, CAF)
- **Video Import** - Import classroom recordings (MP4, MOV, M4V, WebM)
- **Local Transcription** - On-device transcription using WhisperKit (Apple Silicon)
- **Wait Time Detection** - Automatic detection of pauses (3+ seconds) for wait time analysis
- **AI Analysis** - Gemini-powered feedback on teaching techniques
- **Video Analysis** - Gemini-powered visual+audio analysis for classroom dynamics
- **Multiple Frameworks** - Three research-based teaching evaluation frameworks
- **Star Ratings** - Optional 1-5 star ratings with visual legend
- **PDF & Markdown Export** - Export analysis reports with customizable content
- **Domain-Restricted Auth** - Google SSO limited to @psd401.net accounts

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    macOS App (SwiftUI)                      │
├─────────────────────────────────────────────────────────────┤
│  Recording → Transcription (WhisperKit) → Analysis Request  │
│  Video Import → Direct Upload to Gemini → Video Analysis    │
│                           ↓                                 │
│              Local Storage (SwiftData + Media Files)        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ↓ HTTPS
┌─────────────────────────────────────────────────────────────┐
│              Cloud Run Backend (Hono.js)                    │
├─────────────────────────────────────────────────────────────┤
│  /auth/validate    │ Google JWT → Domain check              │
│  /analyze          │ → Gemini API (text analysis)            │
│  /analyze/video    │ → Gemini API (video analysis)          │
│  /upload/initiate  │ → Gemini File Upload                   │
│  Rate Limiting     │ 20 text/hr, 5 video/hr per user        │
└─────────────────────────────────────────────────────────────┘
```

## Requirements

### macOS App
- macOS 14.0+ (Sonoma)
- Xcode 15.2+
- Apple Silicon Mac (for WhisperKit)

### Backend
- Google Cloud Run account
- Google AI API key (Gemini)

## Project Structure

```
teacher-coach/
├── TeacherCoach/                 # macOS App
│   ├── TeacherCoach/
│   │   ├── App/                  # Entry point, AppState, ServiceContainer
│   │   ├── Features/
│   │   │   ├── Authentication/   # Google SSO, session management
│   │   │   ├── Recording/        # Audio/video recording & import
│   │   │   ├── Transcription/    # WhisperKit integration
│   │   │   ├── Analysis/         # Gemini API integration
│   │   │   ├── Techniques/       # Teaching frameworks & technique library
│   │   │   ├── Export/           # PDF & Markdown export
│   │   │   └── Settings/         # User preferences
│   │   └── Core/
│   │       ├── Models/           # SwiftData models
│   │       ├── Views/            # Shared UI components
│   │       └── Services/         # Utility services
│   └── TeacherCoach.xcodeproj
├── CloudRunBackend/              # Primary backend (Google Cloud Run)
│   └── src/routes/               # API routes
└── CloudflareWorker/             # Alternative backend (Cloudflare Workers)
    └── src/routes/               # API routes
```

## Teaching Frameworks

The app supports three research-based frameworks for evaluating teaching:

### TLAC (Teach Like a Champion)

| Category | Techniques |
|----------|------------|
| Questioning | Wait Time, Higher-Order Questions |
| Engagement | Cold Calling, Think-Pair-Share |
| Feedback | Specific Praise, Check for Understanding |
| Management | Positive Framing |
| Instruction | Modeling/Think Aloud, Scaffolded Practice |
| Differentiation | Strategic Grouping |

### Danielson Framework for Teaching

| Domain | Components |
|--------|------------|
| Domain 2: Classroom Environment | 2a: Respect & Rapport, 2b: Culture for Learning, 2c: Managing Procedures, 2d: Managing Behavior |
| Domain 3: Instruction | 3a: Communicating with Students, 3b: Questioning & Discussion, 3c: Engaging Students, 3d: Using Assessment, 3e: Flexibility & Responsiveness |

### Rosenshine's Principles of Instruction

| Principle | Focus |
|-----------|-------|
| Daily Review | Begin lessons with review of previous learning |
| Small Steps | Present new material in small, manageable steps |
| Ask Questions | Frequent questioning to check understanding |
| Provide Models | Demonstrate and model procedures |
| Guide Practice | Supervised practice with feedback |
| Check Understanding | Verify comprehension before moving on |
| High Success Rate | Ensure students achieve mastery |
| Provide Scaffolds | Support complex tasks with frameworks |
| Independent Practice | Allow autonomous practice time |
| Weekly/Monthly Review | Regular review cycles |

Each technique includes:
- Description
- Look-fors (observable indicators)
- Exemplar phrases

## Analysis Methods

### Audio Analysis (Gemini)
- Records or imports audio
- Transcribes locally via WhisperKit
- Analyzes transcript for teaching techniques (Gemini 3 Pro)
- Detects wait time pauses (3+ seconds)
- Cost: ~$0.01-0.03 per analysis
- Rate limit: 20 analyses/hour

### Video Analysis (Gemini)
- Imports video recordings (5-50 minutes, max 2GB)
- Uploads directly to Google Gemini
- Analyzes visual + audio content (Gemini 3 Flash)
- Observes teacher positioning, student engagement, non-verbal cues
- Cost: ~$0.15-0.27 per analysis
- Rate limit: 5 analyses/hour

## Rating Scale

When star ratings are enabled, each technique receives a 1-5 star rating:

| Rating | Level | Description |
|--------|-------|-------------|
| 1 | Developing | Technique not observed or needs significant development |
| 2 | Emerging | Beginning to implement technique with inconsistent results |
| 3 | Proficient | Solid implementation with room for refinement |
| 4 | Accomplished | Effective and consistent use of technique |
| 5 | Exemplary | Masterful implementation that could serve as a model |

## Setup

### 1. Configure Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google Sign-In API
4. Create OAuth 2.0 credentials (macOS application)
5. Set authorized redirect URI: `com.peninsula.teachercoach:/oauth2callback`
6. Note the Client ID

### 2. Deploy Backend (Cloud Run)

```bash
cd CloudRunBackend
bun install

# Set environment variables in Cloud Run console or via gcloud:
# - GEMINI_API_KEY
# - GOOGLE_CLIENT_ID
# - JWT_SECRET
# - ALLOWED_DOMAIN (e.g., psd401.net)

# Deploy
gcloud run deploy teacher-coach-api --source .
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

#### macOS App (Xcode Scheme)
```
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
DEV_BYPASS_AUTH=1  # Optional: bypass OAuth for local testing
```

#### Backend (Cloud Run)
- `GEMINI_API_KEY` - Google AI API key
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `JWT_SECRET` - Secret for signing session tokens
- `ALLOWED_DOMAIN` - Email domain restriction (e.g., `psd401.net`)
- `GEMINI_TEXT_MODEL` - Text analysis model (default: `gemini-3-pro-preview`)
- `GEMINI_VIDEO_MODEL` - Video analysis model (default: `gemini-3-flash-preview`)
- `RATE_LIMIT_PER_HOUR` - Text analysis rate limit (default: 20)
- `VIDEO_RATE_LIMIT_PER_HOUR` - Video analysis rate limit (default: 5)

## API Endpoints

### Authentication
| Endpoint | Description |
|----------|-------------|
| `POST /auth/validate` | Validate Google ID token, return session JWT |
| `POST /auth/refresh` | Refresh expired session token |

### Analysis
| Endpoint | Description |
|----------|-------------|
| `POST /analyze` | Analyze transcript for teaching techniques (Gemini) |
| `POST /analyze/video` | Analyze uploaded video (Gemini) |
| `GET /analyze/rate-limit` | Get current rate limit status |

### Video Upload
| Endpoint | Description |
|----------|-------------|
| `POST /upload/initiate` | Initiate Gemini video upload, get upload URL |

## Privacy & Security

- **Audio stays local** - Recordings stored only on user's device
- **Transcripts sent for analysis** - Audio transcribed locally, only text sent to Gemini
- **Videos uploaded to Gemini** - Deleted after analysis completion
- **Domain-restricted** - Only @psd401.net accounts can sign in
- **Secure storage** - Session tokens stored in macOS Keychain
- **Rate limiting** - Per-user hourly limits prevent abuse

## Development

### Local Development (No OAuth)

Set `DEV_BYPASS_AUTH=1` in your Xcode scheme environment variables to bypass Google authentication during development.

1. In Xcode, select Product → Scheme → Edit Scheme
2. Select Run → Arguments → Environment Variables
3. Add `DEV_BYPASS_AUTH` with value `1`

### Run Backend Locally
```bash
cd CloudRunBackend
bun run dev
```

### Run Tests
```bash
# Backend
cd CloudRunBackend
bun test

# macOS App (in Xcode)
⌘U
```

## Export Options

Analysis reports can be exported in two formats:

### PDF Export
- Multi-page layout with page numbers
- Configurable sections (summary, strengths, growth areas, techniques, next steps)
- Star rating visualization
- Evidence and suggestions for each technique

### Markdown Export
- Plain text format for easy sharing
- Same section configurability as PDF
- Compatible with note-taking apps and documentation systems

## Deployment

### Jamf MDM Distribution

1. Archive the app in Xcode (Product → Archive)
2. Export with Developer ID signing
3. Notarize the app
4. Create DMG or PKG installer
5. Upload to Jamf for distribution

## License

Copyright 2024-2025 Peninsula School District. Internal use only.
