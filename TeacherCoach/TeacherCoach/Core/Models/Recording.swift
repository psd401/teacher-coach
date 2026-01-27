import Foundation
import SwiftData

// MARK: - Media Type

enum MediaType: String, Codable {
    case audio
    case video
}

/// Represents a teaching session recording
@Model
final class Recording {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var duration: TimeInterval
    var audioFilePath: String  // Relative path within app's Documents
    var videoFilePath: String?  // Relative path for video files
    var mediaType: MediaType = MediaType.audio
    var status: RecordingStatus
    var isImported: Bool = false

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \Transcript.recording)
    var transcript: Transcript?

    @Relationship(deleteRule: .cascade, inverse: \Analysis.recording)
    var analysis: Analysis?

    // MARK: - Computed Properties
    var absoluteAudioPath: URL? {
        guard let documentsURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return nil }

        return documentsURL
            .appendingPathComponent("com.peninsula.teachercoach")
            .appendingPathComponent("Recordings")
            .appendingPathComponent(audioFilePath)
    }

    var absoluteVideoPath: URL? {
        guard let videoFilePath = videoFilePath,
              let documentsURL = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
              ).first else { return nil }

        return documentsURL
            .appendingPathComponent("com.peninsula.teachercoach")
            .appendingPathComponent("Recordings")
            .appendingPathComponent(videoFilePath)
    }

    var isVideo: Bool {
        mediaType == .video
    }

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    var isComplete: Bool {
        status == .complete
    }

    var canBeAnalyzed: Bool {
        status == .transcribed && transcript != nil
    }

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        duration: TimeInterval = 0,
        audioFilePath: String,
        videoFilePath: String? = nil,
        mediaType: MediaType = .audio,
        status: RecordingStatus = .recording,
        isImported: Bool = false
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.duration = duration
        self.audioFilePath = audioFilePath
        self.videoFilePath = videoFilePath
        self.mediaType = mediaType
        self.status = status
        self.isImported = isImported
    }
}

// MARK: - Recording Status

enum RecordingStatus: String, Codable {
    case recording
    case recorded
    case uploading  // Video upload to cloud for analysis
    case transcribing
    case transcribed
    case analyzing
    case complete
    case failed

    var displayText: String {
        switch self {
        case .recording: return "Recording"
        case .recorded: return "Recorded"
        case .uploading: return "Uploading..."
        case .transcribing: return "Transcribing..."
        case .transcribed: return "Ready for Analysis"
        case .analyzing: return "Analyzing..."
        case .complete: return "Complete"
        case .failed: return "Failed"
        }
    }

    var isProcessing: Bool {
        self == .uploading || self == .transcribing || self == .analyzing
    }
}
