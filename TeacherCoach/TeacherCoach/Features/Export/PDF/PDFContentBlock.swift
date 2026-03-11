import Foundation
import SwiftData

/// Represents a discrete content block for PDF pagination
/// Each block is measured and placed as an atomic unit (never split mid-block)
enum PDFContentBlock: Identifiable {
    case documentHeader(title: String, duration: String, date: Date)
    case summary(text: String)
    case strengthsAndGrowth(strengths: [String], growthAreas: [String], stacked: Bool)
    case ratingLegend
    case techniqueCard(TechniqueCardData)
    case techniqueSuggestionsContinued(techniqueName: String, suggestions: [String])
    case reflection(ReflectionExportData)
    case nextSteps([String])
    case transcript(TranscriptExportData)

    var id: String {
        switch self {
        case .documentHeader:
            return "header"
        case .summary:
            return "summary"
        case .strengthsAndGrowth:
            return "strengths-growth"
        case .ratingLegend:
            return "rating-legend"
        case .techniqueCard(let data):
            return "technique-\(data.id)"
        case .techniqueSuggestionsContinued(let name, _):
            return "technique-continued-\(name)"
        case .reflection:
            return "reflection"
        case .nextSteps:
            return "next-steps"
        case .transcript(let data):
            return "transcript-\(data.chunkIndex)"
        }
    }
}

/// Data for a technique card block (decoupled from SwiftData model for rendering)
struct TechniqueCardData: Identifiable {
    let id: UUID
    let techniqueName: String
    let rating: Int?
    let ratingsIncluded: Bool
    let wasObserved: Bool
    let feedback: String
    let evidence: [String]
    let suggestions: [String]

    init(from technique: TechniqueEvaluation, ratingsIncluded: Bool) {
        self.id = technique.id
        self.techniqueName = technique.techniqueName
        self.rating = technique.rating
        self.ratingsIncluded = ratingsIncluded
        self.wasObserved = technique.wasObserved
        self.feedback = technique.feedback
        self.evidence = technique.evidence
        self.suggestions = technique.suggestions
    }

    /// Create a version without suggestions (for splitting across pages)
    func withoutSuggestions() -> TechniqueCardData {
        TechniqueCardData(
            id: id,
            techniqueName: techniqueName,
            rating: rating,
            ratingsIncluded: ratingsIncluded,
            wasObserved: wasObserved,
            feedback: feedback,
            evidence: evidence,
            suggestions: []
        )
    }

    private init(
        id: UUID,
        techniqueName: String,
        rating: Int?,
        ratingsIncluded: Bool,
        wasObserved: Bool,
        feedback: String,
        evidence: [String],
        suggestions: [String]
    ) {
        self.id = id
        self.techniqueName = techniqueName
        self.rating = rating
        self.ratingsIncluded = ratingsIncluded
        self.wasObserved = wasObserved
        self.feedback = feedback
        self.evidence = evidence
        self.suggestions = suggestions
    }
}

/// Data for a transcript export block (decoupled from SwiftData model for rendering)
struct TranscriptExportData {
    let segments: [(timestamp: String, text: String)]
    let wordCount: Int
    let chunkIndex: Int

    /// Create chunked transcript blocks from a Transcript model (~20 segments per chunk)
    static func chunks(from transcript: Transcript) -> [TranscriptExportData] {
        let sortedSegments = transcript.segments.sorted { $0.startTime < $1.startTime }
        let chunkSize = 20
        var chunks: [TranscriptExportData] = []

        for (index, chunk) in stride(from: 0, to: sortedSegments.count, by: chunkSize).enumerated() {
            let end = min(chunk + chunkSize, sortedSegments.count)
            let segmentSlice = sortedSegments[chunk..<end]
            let segments = segmentSlice.map { (timestamp: $0.formattedTimeRange, text: $0.text) }
            let wordCount = segmentSlice.reduce(0) { $0 + $1.text.split(separator: " ").count }
            chunks.append(TranscriptExportData(segments: segments, wordCount: wordCount, chunkIndex: index))
        }

        // Fallback: if no segments, create a single block from fullText
        if chunks.isEmpty {
            let wordCount = transcript.fullText.split(separator: " ").count
            chunks.append(TranscriptExportData(
                segments: [(timestamp: "", text: transcript.fullText)],
                wordCount: wordCount,
                chunkIndex: 0
            ))
        }

        return chunks
    }
}

/// Data for a reflection export block (decoupled from SwiftData model for rendering)
struct ReflectionExportData {
    let whatWentWell: String
    let whatToChange: String
    let selfRatings: [TechniqueSelfRating]
    let focusTechniqueIds: [String]

    init(from reflection: Reflection) {
        self.whatWentWell = reflection.whatWentWell
        self.whatToChange = reflection.whatToChange
        self.selfRatings = reflection.selfRatings
        self.focusTechniqueIds = reflection.focusTechniqueIds
    }
}
