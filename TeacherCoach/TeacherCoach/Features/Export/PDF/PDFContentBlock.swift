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
    case nextSteps([String])

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
        case .nextSteps:
            return "next-steps"
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
