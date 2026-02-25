import Foundation
import SwiftData

/// Represents the AI-generated analysis of a teaching session
@Model
final class Analysis {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID
    var overallSummary: String
    var createdAt: Date
    var modelUsed: String  // e.g., "gemini-3-pro-preview"
    var ratingsIncluded: Bool = true  // Whether star ratings were included in this analysis

    // MARK: - JSON-stored arrays
    var strengthsData: Data?
    var growthAreasData: Data?
    var actionableNextStepsData: Data?

    // MARK: - Relationships
    var recording: Recording?

    @Relationship(deleteRule: .cascade, inverse: \TechniqueEvaluation.analysis)
    var techniqueEvaluations: [TechniqueEvaluation]?

    // MARK: - Computed Properties
    var strengths: [String] {
        get {
            guard let data = strengthsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            strengthsData = try? JSONEncoder().encode(newValue)
        }
    }

    var growthAreas: [String] {
        get {
            guard let data = growthAreasData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            growthAreasData = try? JSONEncoder().encode(newValue)
        }
    }

    var actionableNextSteps: [String] {
        get {
            guard let data = actionableNextStepsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            actionableNextStepsData = try? JSONEncoder().encode(newValue)
        }
    }

    var averageRating: Double? {
        guard let evaluations = techniqueEvaluations, !evaluations.isEmpty else { return nil }
        let sum = evaluations.compactMap { $0.rating }.reduce(0, +)
        let count = evaluations.filter { $0.rating != nil }.count
        return count > 0 ? Double(sum) / Double(count) : nil
    }

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        overallSummary: String,
        createdAt: Date = Date(),
        modelUsed: String,
        strengths: [String] = [],
        growthAreas: [String] = [],
        actionableNextSteps: [String] = [],
        ratingsIncluded: Bool = true
    ) {
        self.id = id
        self.overallSummary = overallSummary
        self.createdAt = createdAt
        self.modelUsed = modelUsed
        self.ratingsIncluded = ratingsIncluded
        self.strengthsData = try? JSONEncoder().encode(strengths)
        self.growthAreasData = try? JSONEncoder().encode(growthAreas)
        self.actionableNextStepsData = try? JSONEncoder().encode(actionableNextSteps)
        self.techniqueEvaluations = []
    }
}
