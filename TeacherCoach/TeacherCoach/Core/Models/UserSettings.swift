import Foundation
import SwiftData

/// User-specific settings stored in SwiftData
@Model
final class UserSettings {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID
    var userEmail: String

    // Recording preferences
    var defaultRecordingTitle: String
    var autoStartTranscription: Bool
    var autoStartAnalysis: Bool

    // Framework and technique preferences
    var selectedFrameworkId: String = "tlac"  // Default for migration
    var frameworkTechniqueSelectionsData: Data?  // JSON: {"tlac": [...], "danielson": [...]}

    // Legacy: kept for migration, now stored per-framework
    var enabledTechniquesData: Data?

    // Display preferences
    var showTimestamps: Bool
    var compactFeedbackView: Bool

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Computed Properties

    /// The currently selected teaching framework
    var selectedFramework: TeachingFramework {
        get {
            TeachingFramework(rawValue: selectedFrameworkId) ?? .tlac
        }
        set {
            selectedFrameworkId = newValue.rawValue
            updatedAt = Date()
        }
    }

    /// Per-framework technique selections
    private var frameworkTechniqueSelections: [String: [String]] {
        get {
            guard let data = frameworkTechniqueSelectionsData else {
                return [:]
            }
            return (try? JSONDecoder().decode([String: [String]].self, from: data)) ?? [:]
        }
        set {
            frameworkTechniqueSelectionsData = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    /// Legacy: enabled technique IDs (for backwards compatibility)
    /// Now returns IDs for the selected framework
    var enabledTechniqueIds: [String] {
        get {
            enabledTechniqueIds(for: selectedFramework)
        }
        set {
            setEnabledTechniqueIds(newValue, for: selectedFramework)
        }
    }

    /// Returns enabled technique IDs for a specific framework
    func enabledTechniqueIds(for framework: TeachingFramework) -> [String] {
        // Check per-framework storage first
        if let ids = frameworkTechniqueSelections[framework.rawValue], !ids.isEmpty {
            return ids
        }

        // Fall back to legacy storage for TLAC (migration path)
        if framework == .tlac, let data = enabledTechniquesData,
           let ids = try? JSONDecoder().decode([String].self, from: data), !ids.isEmpty {
            return ids
        }

        // Default: all techniques for the framework
        return FrameworkRegistry.defaultEnabledIds(for: framework)
    }

    /// Sets enabled technique IDs for a specific framework
    func setEnabledTechniqueIds(_ ids: [String], for framework: TeachingFramework) {
        var selections = frameworkTechniqueSelections
        selections[framework.rawValue] = ids
        frameworkTechniqueSelections = selections
    }

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        userEmail: String,
        defaultRecordingTitle: String = "Teaching Session",
        autoStartTranscription: Bool = true,
        autoStartAnalysis: Bool = false,
        selectedFramework: TeachingFramework = .tlac,
        showTimestamps: Bool = true,
        compactFeedbackView: Bool = false
    ) {
        self.id = id
        self.userEmail = userEmail
        self.defaultRecordingTitle = defaultRecordingTitle
        self.autoStartTranscription = autoStartTranscription
        self.autoStartAnalysis = autoStartAnalysis
        self.selectedFrameworkId = selectedFramework.rawValue
        self.showTimestamps = showTimestamps
        self.compactFeedbackView = compactFeedbackView
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    /// Checks if a technique is enabled for the current framework
    func isTechniqueEnabled(_ techniqueId: String) -> Bool {
        enabledTechniqueIds.contains(techniqueId)
    }

    /// Checks if a technique is enabled for a specific framework
    func isTechniqueEnabled(_ techniqueId: String, for framework: TeachingFramework) -> Bool {
        enabledTechniqueIds(for: framework).contains(techniqueId)
    }

    /// Toggles a technique for the current framework
    func toggleTechnique(_ techniqueId: String) {
        toggleTechnique(techniqueId, for: selectedFramework)
    }

    /// Toggles a technique for a specific framework
    func toggleTechnique(_ techniqueId: String, for framework: TeachingFramework) {
        var ids = enabledTechniqueIds(for: framework)
        if ids.contains(techniqueId) {
            ids.removeAll { $0 == techniqueId }
        } else {
            ids.append(techniqueId)
        }
        setEnabledTechniqueIds(ids, for: framework)
    }
}
