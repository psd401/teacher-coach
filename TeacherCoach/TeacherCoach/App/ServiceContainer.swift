import SwiftUI
import Observation

/// Dependency injection container for all services
@MainActor
@Observable
final class ServiceContainer {
    static let shared = ServiceContainer()

    // MARK: - Services
    let authService: AuthService
    let recordingService: RecordingService
    let transcriptionService: TranscriptionService
    let analysisService: AnalysisService
    let techniqueService: TechniqueService

    // MARK: - Configuration
    let config: AppConfiguration

    private init() {
        self.config = AppConfiguration.load()

        // Initialize services
        self.authService = AuthService(config: config)
        self.recordingService = RecordingService(config: config)
        self.transcriptionService = TranscriptionService(config: config)
        self.analysisService = AnalysisService(config: config)
        self.techniqueService = TechniqueService()
    }
}

// MARK: - App Configuration

struct AppConfiguration: Codable {
    let backendURL: URL
    let googleClientID: String
    let allowedDomain: String
    let minRecordingDuration: TimeInterval
    let maxRecordingDuration: TimeInterval
    let whisperModel: String
    let rateLimitPerHour: Int

    static func load() -> AppConfiguration {
        // Default configuration - can be overridden by config file
        AppConfiguration(
            backendURL: URL(string: "https://teacher-coach-api.peninsula.workers.dev")!,
            googleClientID: ProcessInfo.processInfo.environment["GOOGLE_CLIENT_ID"] ?? "",
            allowedDomain: "peninsula.wednet.edu",
            minRecordingDuration: 5 * 60,  // 5 minutes
            maxRecordingDuration: 50 * 60, // 50 minutes
            whisperModel: "openai_whisper-large-v3",
            rateLimitPerHour: 20
        )
    }
}

// MARK: - Environment Key

extension EnvironmentValues {
    @Entry var serviceContainer: ServiceContainer = .shared
}

extension View {
    func environment(_ container: ServiceContainer) -> some View {
        environment(\.serviceContainer, container)
    }
}
