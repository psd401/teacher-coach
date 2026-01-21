import Foundation

/// Export format options
enum ExportFormat: String, CaseIterable {
    case pdf = "PDF"
    case markdown = "Markdown"
}

/// Configuration for analysis export
struct ExportConfiguration {
    var format: ExportFormat = .pdf
    var includeSummary: Bool = true
    var includeStrengths: Bool = true
    var includeGrowthAreas: Bool = true
    var includeNextSteps: Bool = true
    var includedTechniqueIds: Set<UUID> = []

    /// Whether at least one item is selected for export
    var hasSelection: Bool {
        includeSummary || includeStrengths || includeGrowthAreas || includeNextSteps || !includedTechniqueIds.isEmpty
    }
}
