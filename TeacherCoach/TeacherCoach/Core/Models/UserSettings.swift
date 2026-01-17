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

    // Technique preferences (stored as JSON array of technique IDs)
    var enabledTechniquesData: Data?

    // Display preferences
    var showTimestamps: Bool
    var compactFeedbackView: Bool

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Computed Properties
    var enabledTechniqueIds: [String] {
        get {
            guard let data = enabledTechniquesData else {
                // Default: all techniques enabled
                return Technique.createBuiltInTechniques().map { $0.id }
            }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            enabledTechniquesData = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        userEmail: String,
        defaultRecordingTitle: String = "Teaching Session",
        autoStartTranscription: Bool = true,
        autoStartAnalysis: Bool = false,
        showTimestamps: Bool = true,
        compactFeedbackView: Bool = false
    ) {
        self.id = id
        self.userEmail = userEmail
        self.defaultRecordingTitle = defaultRecordingTitle
        self.autoStartTranscription = autoStartTranscription
        self.autoStartAnalysis = autoStartAnalysis
        self.showTimestamps = showTimestamps
        self.compactFeedbackView = compactFeedbackView
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods
    func isTechniqueEnabled(_ techniqueId: String) -> Bool {
        enabledTechniqueIds.contains(techniqueId)
    }

    func toggleTechnique(_ techniqueId: String) {
        var ids = enabledTechniqueIds
        if ids.contains(techniqueId) {
            ids.removeAll { $0 == techniqueId }
        } else {
            ids.append(techniqueId)
        }
        enabledTechniqueIds = ids
    }
}
