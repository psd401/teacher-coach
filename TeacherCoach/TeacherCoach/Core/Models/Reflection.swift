import Foundation
import SwiftData

/// Represents a teacher's self-reflection on a teaching session
@Model
final class Reflection {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID
    var whatWentWell: String
    var whatToChange: String
    var isComplete: Bool
    var wasSkipped: Bool
    var createdAt: Date

    // MARK: - JSON-stored arrays
    var selfRatingsData: Data?
    var focusTechniqueIdsData: Data?

    // MARK: - Relationships
    var recording: Recording?

    // MARK: - Computed Properties
    var selfRatings: [TechniqueSelfRating] {
        get {
            guard let data = selfRatingsData else { return [] }
            return (try? JSONDecoder().decode([TechniqueSelfRating].self, from: data)) ?? []
        }
        set {
            selfRatingsData = try? JSONEncoder().encode(newValue)
        }
    }

    var focusTechniqueIds: [String] {
        get {
            guard let data = focusTechniqueIdsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            focusTechniqueIdsData = try? JSONEncoder().encode(newValue)
        }
    }

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        whatWentWell: String = "",
        whatToChange: String = "",
        isComplete: Bool = false,
        wasSkipped: Bool = false,
        createdAt: Date = Date(),
        selfRatings: [TechniqueSelfRating] = [],
        focusTechniqueIds: [String] = []
    ) {
        self.id = id
        self.whatWentWell = whatWentWell
        self.whatToChange = whatToChange
        self.isComplete = isComplete
        self.wasSkipped = wasSkipped
        self.createdAt = createdAt
        self.selfRatingsData = try? JSONEncoder().encode(selfRatings)
        self.focusTechniqueIdsData = try? JSONEncoder().encode(focusTechniqueIds)
    }
}

// MARK: - Supporting Types

/// A teacher's self-rating for a specific technique
struct TechniqueSelfRating: Codable, Identifiable {
    let techniqueId: String
    let techniqueName: String
    var rating: Int  // 1-5, same scale as RatingLevel

    var id: String { techniqueId }

    var ratingLevel: RatingLevel? {
        RatingLevel(rawValue: rating)
    }
}
