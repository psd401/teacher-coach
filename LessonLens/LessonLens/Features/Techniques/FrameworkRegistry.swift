import Foundation

/// Central registry for accessing techniques by framework
struct FrameworkRegistry {
    /// Returns all techniques for a specific framework
    static func techniques(for framework: TeachingFramework) -> [Technique] {
        switch framework {
        case .tlac:
            return TLACTechniques.createTechniques()
        case .danielson:
            return DanielsonTechniques.createTechniques()
        case .rosenshine:
            return RosenshineTechniques.createTechniques()
        case .avid:
            return AVIDTechniques.createTechniques()
        case .nationalBoard:
            return NationalBoardTechniques.createTechniques()
        case .psdEssentials:
            return PSDEssentialsTechniques.createTechniques()
        }
    }

    /// Returns all techniques from all frameworks
    static func allTechniques() -> [Technique] {
        TeachingFramework.allCases.flatMap { techniques(for: $0) }
    }

    /// Returns the default enabled technique IDs for a specific framework
    static func defaultEnabledIds(for framework: TeachingFramework) -> [String] {
        techniques(for: framework).map { $0.id }
    }

    /// Returns techniques grouped by category for a specific framework
    static func techniquesByCategory(for framework: TeachingFramework) -> [(category: TechniqueCategory, techniques: [Technique])] {
        let techniques = self.techniques(for: framework)
        var grouped: [TechniqueCategory: [Technique]] = [:]

        for technique in techniques {
            grouped[technique.category, default: []].append(technique)
        }

        return TechniqueCategory.allCases.compactMap { category in
            guard let techs = grouped[category], !techs.isEmpty else { return nil }
            return (category: category, techniques: techs.sorted { $0.sortOrder < $1.sortOrder })
        }
    }

    /// Finds a technique by ID across all frameworks
    static func technique(byId id: String) -> Technique? {
        allTechniques().first { $0.id == id }
    }

    /// Finds a technique by ID within a specific framework
    static func technique(byId id: String, in framework: TeachingFramework) -> Technique? {
        techniques(for: framework).first { $0.id == id }
    }
}
