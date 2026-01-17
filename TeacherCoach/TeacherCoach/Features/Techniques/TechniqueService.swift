import Foundation
import SwiftData

/// Service for managing teaching techniques
final class TechniqueService {
    private var cachedTechniques: [Technique]?

    init() {}

    // MARK: - Public Methods

    /// Returns all built-in techniques
    func getBuiltInTechniques() -> [Technique] {
        if let cached = cachedTechniques {
            return cached
        }

        let techniques = Technique.createBuiltInTechniques()
        cachedTechniques = techniques
        return techniques
    }

    /// Returns techniques filtered by enabled IDs
    func getEnabledTechniques(enabledIds: [String]) -> [Technique] {
        getBuiltInTechniques().filter { enabledIds.contains($0.id) }
    }

    /// Returns techniques grouped by category
    func getTechniquesByCategory() -> [(category: TechniqueCategory, techniques: [Technique])] {
        let techniques = getBuiltInTechniques()
        var grouped: [TechniqueCategory: [Technique]] = [:]

        for technique in techniques {
            grouped[technique.category, default: []].append(technique)
        }

        return TechniqueCategory.allCases.compactMap { category in
            guard let techs = grouped[category], !techs.isEmpty else { return nil }
            return (category: category, techniques: techs.sorted { $0.sortOrder < $1.sortOrder })
        }
    }

    /// Returns a technique by ID
    func getTechnique(byId id: String) -> Technique? {
        getBuiltInTechniques().first { $0.id == id }
    }

    /// Initializes techniques in SwiftData if not already present
    @MainActor
    func initializeTechniquesInDatabase(context: ModelContext) {
        // Check if techniques already exist
        let descriptor = FetchDescriptor<Technique>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )

        do {
            let existingCount = try context.fetchCount(descriptor)
            if existingCount > 0 {
                return  // Already initialized
            }

            // Insert built-in techniques
            for technique in Technique.createBuiltInTechniques() {
                context.insert(technique)
            }

            try context.save()
        } catch {
            print("Failed to initialize techniques: \(error)")
        }
    }

    /// Updates enabled techniques in the database
    @MainActor
    func updateEnabledTechniques(
        enabledIds: Set<String>,
        context: ModelContext
    ) throws {
        let descriptor = FetchDescriptor<Technique>()

        let techniques = try context.fetch(descriptor)
        for technique in techniques {
            technique.isEnabled = enabledIds.contains(technique.id)
        }

        try context.save()
    }

    /// Fetches enabled techniques from the database
    @MainActor
    func fetchEnabledTechniques(context: ModelContext) throws -> [Technique] {
        let descriptor = FetchDescriptor<Technique>(
            predicate: #Predicate { $0.isEnabled == true },
            sortBy: [SortDescriptor(\.sortOrder)]
        )

        return try context.fetch(descriptor)
    }
}

// MARK: - Technique Validation

extension TechniqueService {
    /// Validates that at least one technique is enabled
    func validateTechniqueSelection(enabledIds: [String]) -> Bool {
        !enabledIds.isEmpty
    }

    /// Returns default enabled technique IDs (all)
    func getDefaultEnabledIds() -> [String] {
        getBuiltInTechniques().map { $0.id }
    }
}
