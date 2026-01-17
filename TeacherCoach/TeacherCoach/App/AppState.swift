import SwiftUI
import Combine

/// Global application state management
@MainActor
final class AppState: ObservableObject {
    // MARK: - Authentication State
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var authError: AuthError?

    // MARK: - Recording State
    @Published var isRecording: Bool = false
    @Published var currentRecordingDuration: TimeInterval = 0
    @Published var audioLevel: Float = 0

    // MARK: - Processing State
    @Published var isTranscribing: Bool = false
    @Published var transcriptionProgress: Double = 0
    @Published var isAnalyzing: Bool = false
    @Published var analysisProgress: Double = 0

    // MARK: - Navigation State
    @Published var selectedRecordingID: Recording.ID?
    @Published var showingSettings: Bool = false

    // MARK: - Error State
    @Published var currentError: AppError?
    @Published var showingError: Bool = false

    // MARK: - Initialization
    init() {
        loadAuthState()
    }

    private func loadAuthState() {
        // Check for existing session in Keychain
        if let sessionData = KeychainService.shared.retrieve(key: KeychainKeys.sessionToken),
           let session = try? JSONDecoder().decode(SessionToken.self, from: sessionData) {
            if session.isValid {
                isAuthenticated = true
                currentUser = session.user
            } else {
                // Token expired, clear it
                KeychainService.shared.delete(key: KeychainKeys.sessionToken)
            }
        }
    }

    func signOut() {
        KeychainService.shared.delete(key: KeychainKeys.sessionToken)
        isAuthenticated = false
        currentUser = nil
    }

    func handleError(_ error: AppError) {
        currentError = error
        showingError = true
    }
}

// MARK: - Supporting Types

struct User: Codable, Equatable {
    let id: String
    let email: String
    let displayName: String
    let photoURL: URL?
}

struct SessionToken: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date
    let user: User

    var isValid: Bool {
        expiresAt > Date()
    }
}

enum AuthError: Error, LocalizedError {
    case invalidDomain
    case networkError(Error)
    case tokenExpired
    case cancelled
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidDomain:
            return "Only @peninsula.wednet.edu accounts are allowed"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .tokenExpired:
            return "Session expired. Please sign in again."
        case .cancelled:
            return "Sign in was cancelled"
        case .unknown(let error):
            return "Authentication error: \(error.localizedDescription)"
        }
    }
}

enum AppError: Error, LocalizedError {
    case recording(RecordingError)
    case transcription(TranscriptionError)
    case analysis(AnalysisError)
    case network(NetworkError)
    case storage(StorageError)

    var errorDescription: String? {
        switch self {
        case .recording(let error): return error.localizedDescription
        case .transcription(let error): return error.localizedDescription
        case .analysis(let error): return error.localizedDescription
        case .network(let error): return error.localizedDescription
        case .storage(let error): return error.localizedDescription
        }
    }
}

enum RecordingError: Error, LocalizedError {
    case microphoneAccessDenied
    case audioSessionFailed(Error)
    case encodingFailed
    case saveFailed(Error)
    case durationTooShort
    case durationTooLong

    var errorDescription: String? {
        switch self {
        case .microphoneAccessDenied:
            return "Microphone access is required. Please enable in System Settings."
        case .audioSessionFailed(let error):
            return "Audio session error: \(error.localizedDescription)"
        case .encodingFailed:
            return "Failed to encode audio"
        case .saveFailed(let error):
            return "Failed to save recording: \(error.localizedDescription)"
        case .durationTooShort:
            return "Recording must be at least 5 minutes"
        case .durationTooLong:
            return "Recording cannot exceed 50 minutes"
        }
    }
}

enum TranscriptionError: Error, LocalizedError {
    case modelLoadFailed(Error)
    case processingFailed(Error)
    case cancelled
    case insufficientMemory

    var errorDescription: String? {
        switch self {
        case .modelLoadFailed(let error):
            return "Failed to load transcription model: \(error.localizedDescription)"
        case .processingFailed(let error):
            return "Transcription failed: \(error.localizedDescription)"
        case .cancelled:
            return "Transcription was cancelled"
        case .insufficientMemory:
            return "Insufficient memory for transcription. Please close other apps."
        }
    }
}

enum AnalysisError: Error, LocalizedError {
    case apiError(Int, String)
    case rateLimited
    case invalidResponse
    case networkUnavailable
    case cancelled

    var errorDescription: String? {
        switch self {
        case .apiError(let code, let message):
            return "API error (\(code)): \(message)"
        case .rateLimited:
            return "Rate limit reached. Please wait before analyzing another session."
        case .invalidResponse:
            return "Received invalid response from analysis service"
        case .networkUnavailable:
            return "Network unavailable. Please check your connection."
        case .cancelled:
            return "Analysis was cancelled"
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case noConnection
    case timeout
    case serverError(Int)
    case invalidURL
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .serverError(let code):
            return "Server error (\(code))"
        case .invalidURL:
            return "Invalid URL"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

enum StorageError: Error, LocalizedError {
    case insufficientSpace
    case fileNotFound
    case accessDenied
    case corruptedData

    var errorDescription: String? {
        switch self {
        case .insufficientSpace:
            return "Insufficient storage space"
        case .fileNotFound:
            return "File not found"
        case .accessDenied:
            return "Access denied to storage location"
        case .corruptedData:
            return "Data is corrupted"
        }
    }
}

// MARK: - Keychain Keys

enum KeychainKeys {
    static let sessionToken = "com.peninsula.teachercoach.session"
    static let refreshToken = "com.peninsula.teachercoach.refresh"
}
