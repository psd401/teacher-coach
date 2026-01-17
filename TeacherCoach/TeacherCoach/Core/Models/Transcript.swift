import Foundation
import SwiftData

/// Represents the transcription of a recording
@Model
final class Transcript {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID
    var fullText: String
    var createdAt: Date
    var modelUsed: String
    var processingTime: TimeInterval  // How long transcription took

    // MARK: - Segments (stored as JSON)
    var segmentsData: Data?

    // MARK: - Relationships
    var recording: Recording?

    // MARK: - Computed Properties
    var segments: [TranscriptSegment] {
        get {
            guard let data = segmentsData else { return [] }
            return (try? JSONDecoder().decode([TranscriptSegment].self, from: data)) ?? []
        }
        set {
            segmentsData = try? JSONEncoder().encode(newValue)
        }
    }

    var wordCount: Int {
        fullText.split(separator: " ").count
    }

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        fullText: String,
        createdAt: Date = Date(),
        modelUsed: String,
        processingTime: TimeInterval = 0,
        segments: [TranscriptSegment] = []
    ) {
        self.id = id
        self.fullText = fullText
        self.createdAt = createdAt
        self.modelUsed = modelUsed
        self.processingTime = processingTime
        self.segmentsData = try? JSONEncoder().encode(segments)
    }
}

// MARK: - Transcript Segment

struct TranscriptSegment: Codable, Identifiable {
    let id: UUID
    let startTime: TimeInterval
    let endTime: TimeInterval
    let text: String
    let confidence: Float?

    init(
        id: UUID = UUID(),
        startTime: TimeInterval,
        endTime: TimeInterval,
        text: String,
        confidence: Float? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.text = text
        self.confidence = confidence
    }

    var formattedTimeRange: String {
        let startMin = Int(startTime) / 60
        let startSec = Int(startTime) % 60
        let endMin = Int(endTime) / 60
        let endSec = Int(endTime) % 60
        return String(format: "%d:%02d - %d:%02d", startMin, startSec, endMin, endSec)
    }
}
