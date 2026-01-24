import Foundation
import SwiftData

/// Service for managing teaching techniques
final class TechniqueService {
    private var cachedTechniques: [TeachingFramework: [Technique]] = [:]

    init() {}

    // MARK: - Framework-Aware Methods

    /// Returns all techniques for a specific framework
    func getTechniques(for framework: TeachingFramework) -> [Technique] {
        if let cached = cachedTechniques[framework] {
            return cached
        }

        let techniques = FrameworkRegistry.techniques(for: framework)
        cachedTechniques[framework] = techniques
        return techniques
    }

    /// Returns techniques filtered by enabled IDs for a specific framework
    func getEnabledTechniques(for framework: TeachingFramework, enabledIds: [String]) -> [Technique] {
        getTechniques(for: framework).filter { enabledIds.contains($0.id) }
    }

    /// Returns techniques grouped by category for a specific framework
    func getTechniquesByCategory(for framework: TeachingFramework) -> [(category: TechniqueCategory, techniques: [Technique])] {
        FrameworkRegistry.techniquesByCategory(for: framework)
    }

    /// Returns a technique by ID within a specific framework
    func getTechnique(byId id: String, in framework: TeachingFramework) -> Technique? {
        getTechniques(for: framework).first { $0.id == id }
    }

    /// Returns default enabled IDs for a framework
    func getDefaultEnabledIds(for framework: TeachingFramework) -> [String] {
        FrameworkRegistry.defaultEnabledIds(for: framework)
    }

    // MARK: - Legacy Methods (backwards compatibility)

    /// Returns all built-in techniques from all frameworks
    func getBuiltInTechniques() -> [Technique] {
        FrameworkRegistry.allTechniques()
    }

    /// Returns techniques filtered by enabled IDs (searches all frameworks)
    func getEnabledTechniques(enabledIds: [String]) -> [Technique] {
        getBuiltInTechniques().filter { enabledIds.contains($0.id) }
    }

    /// Returns techniques grouped by category (from all frameworks)
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

    /// Returns a technique by ID (searches all frameworks)
    func getTechnique(byId id: String) -> Technique? {
        FrameworkRegistry.technique(byId: id)
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

// MARK: - Data Migration

extension TechniqueService {
    private static let techniqueNameMigrationKey = "techniqueNameMigrationComplete_v1"

    /// Migrates technique evaluations to use full technique names
    /// This fixes evaluations where only the code (e.g., "3b") was stored instead of the full name
    @MainActor
    func migrateIncompleteTeechniqueNames(context: ModelContext) {
        // Check if migration has already run
        if UserDefaults.standard.bool(forKey: Self.techniqueNameMigrationKey) {
            return
        }

        do {
            let descriptor = FetchDescriptor<TechniqueEvaluation>()
            let evaluations = try context.fetch(descriptor)

            var updatedCount = 0
            for evaluation in evaluations {
                if let fullName = findFullTechniqueName(for: evaluation.techniqueId, currentName: evaluation.techniqueName) {
                    if evaluation.techniqueName != fullName {
                        evaluation.techniqueName = fullName
                        updatedCount += 1
                    }
                }
            }

            if updatedCount > 0 {
                try context.save()
                print("Migration: Updated \(updatedCount) technique evaluation names")
            }

            // Mark migration as complete
            UserDefaults.standard.set(true, forKey: Self.techniqueNameMigrationKey)
        } catch {
            print("Failed to migrate technique names: \(error)")
        }
    }

    /// Finds the full technique name given a technique ID or partial name
    /// Handles cases where Claude returned incorrect IDs like "3b" instead of "danielson-3b"
    private func findFullTechniqueName(for techniqueId: String, currentName: String) -> String? {
        let allTechniques = FrameworkRegistry.allTechniques()

        // First, try direct lookup by ID
        if let technique = allTechniques.first(where: { $0.id == techniqueId }) {
            return technique.name
        }

        // If not found, the techniqueId might be a partial code like "3b"
        // Try to match technique names that start with this code
        // Danielson names are formatted as "3b: Description"
        let searchPrefix = "\(techniqueId):"
        if let technique = allTechniques.first(where: { $0.name.lowercased().hasPrefix(searchPrefix.lowercased()) }) {
            return technique.name
        }

        // Also try matching the current stored name if it's just a code
        let currentNamePrefix = "\(currentName):"
        if let technique = allTechniques.first(where: { $0.name.lowercased().hasPrefix(currentNamePrefix.lowercased()) }) {
            return technique.name
        }

        // No match found - return nil to keep the existing name
        return nil
    }
}
