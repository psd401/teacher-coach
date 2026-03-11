import Foundation
import SwiftData

/// Represents a teaching technique that can be evaluated
@Model
final class Technique {
    // MARK: - Properties
    @Attribute(.unique) var id: String  // Stable identifier like "wait-time"
    var name: String
    var category: TechniqueCategory
    var descriptionText: String  // 'description' is reserved
    var frameworkId: String = "tlac"  // e.g., "tlac" or "danielson" - default for migration
    var isBuiltIn: Bool
    var isEnabled: Bool
    var sortOrder: Int

    // MARK: - JSON-stored arrays
    var lookForsData: Data?
    var exemplarPhrasesData: Data?

    // MARK: - Computed Properties
    var lookFors: [String] {
        get {
            guard let data = lookForsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            lookForsData = try? JSONEncoder().encode(newValue)
        }
    }

    var exemplarPhrases: [String] {
        get {
            guard let data = exemplarPhrasesData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            exemplarPhrasesData = try? JSONEncoder().encode(newValue)
        }
    }

    // MARK: - Initialization
    init(
        id: String,
        name: String,
        category: TechniqueCategory,
        description: String,
        frameworkId: String = TeachingFramework.tlac.rawValue,
        isBuiltIn: Bool = true,
        isEnabled: Bool = true,
        sortOrder: Int = 0,
        lookFors: [String] = [],
        exemplarPhrases: [String] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.descriptionText = description
        self.frameworkId = frameworkId
        self.isBuiltIn = isBuiltIn
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
        self.lookForsData = try? JSONEncoder().encode(lookFors)
        self.exemplarPhrasesData = try? JSONEncoder().encode(exemplarPhrases)
    }

    // MARK: - Computed Properties for Framework

    /// Returns the framework this technique belongs to
    var framework: TeachingFramework? {
        TeachingFramework(rawValue: frameworkId)
    }
}

// MARK: - Technique Category

enum TechniqueCategory: String, Codable, CaseIterable {
    case questioning = "Questioning"
    case engagement = "Engagement"
    case feedback = "Feedback"
    case management = "Management"
    case instruction = "Instruction"
    case differentiation = "Differentiation"

    var icon: String {
        switch self {
        case .questioning: return "questionmark.bubble"
        case .engagement: return "person.3"
        case .feedback: return "text.bubble"
        case .management: return "rectangle.3.group"
        case .instruction: return "book"
        case .differentiation: return "slider.horizontal.3"
        }
    }
}

// MARK: - Built-in Techniques

extension Technique {
    /// Creates all built-in teaching techniques from all frameworks
    /// This is a convenience method for backwards compatibility
    static func createBuiltInTechniques() -> [Technique] {
        FrameworkRegistry.allTechniques()
    }

    /// Creates techniques for a specific framework
    static func createTechniques(for framework: TeachingFramework) -> [Technique] {
        FrameworkRegistry.techniques(for: framework)
    }
}
