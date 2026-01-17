import Foundation
import SwiftData

/// Evaluation of a specific teaching technique within an analysis
@Model
final class TechniqueEvaluation {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID
    var techniqueId: String  // References Technique.id
    var techniqueName: String  // Denormalized for display
    var rating: Int?  // 1-5 scale, nil if not observed
    var feedback: String
    var wasObserved: Bool

    // MARK: - JSON-stored arrays
    var evidenceData: Data?
    var suggestionsData: Data?

    // MARK: - Relationships
    var analysis: Analysis?

    // MARK: - Computed Properties
    var evidence: [String] {
        get {
            guard let data = evidenceData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            evidenceData = try? JSONEncoder().encode(newValue)
        }
    }

    var suggestions: [String] {
        get {
            guard let data = suggestionsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            suggestionsData = try? JSONEncoder().encode(newValue)
        }
    }

    var ratingLevel: RatingLevel? {
        guard let rating = rating else { return nil }
        return RatingLevel(rawValue: rating)
    }

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        techniqueId: String,
        techniqueName: String,
        rating: Int? = nil,
        feedback: String,
        wasObserved: Bool = true,
        evidence: [String] = [],
        suggestions: [String] = []
    ) {
        self.id = id
        self.techniqueId = techniqueId
        self.techniqueName = techniqueName
        self.rating = rating
        self.feedback = feedback
        self.wasObserved = wasObserved
        self.evidenceData = try? JSONEncoder().encode(evidence)
        self.suggestionsData = try? JSONEncoder().encode(suggestions)
    }
}

// MARK: - Rating Level

enum RatingLevel: Int, CaseIterable {
    case developing = 1
    case emerging = 2
    case proficient = 3
    case accomplished = 4
    case exemplary = 5

    var displayText: String {
        switch self {
        case .developing: return "Developing"
        case .emerging: return "Emerging"
        case .proficient: return "Proficient"
        case .accomplished: return "Accomplished"
        case .exemplary: return "Exemplary"
        }
    }

    var color: String {
        switch self {
        case .developing: return "red"
        case .emerging: return "orange"
        case .proficient: return "yellow"
        case .accomplished: return "green"
        case .exemplary: return "blue"
        }
    }

    var description: String {
        switch self {
        case .developing:
            return "Technique not observed or needs significant development"
        case .emerging:
            return "Beginning to implement technique with inconsistent results"
        case .proficient:
            return "Solid implementation of technique with room for refinement"
        case .accomplished:
            return "Effective and consistent use of technique"
        case .exemplary:
            return "Masterful implementation that could serve as a model"
        }
    }
}
