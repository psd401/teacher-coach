import Foundation

/// Represents a teaching framework for evaluation
enum TeachingFramework: String, Codable, CaseIterable, Identifiable {
    case tlac = "tlac"
    case danielson = "danielson"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tlac:
            return "TLAC (Teach Like A Champion)"
        case .danielson:
            return "Danielson Framework"
        }
    }

    var shortName: String {
        switch self {
        case .tlac:
            return "TLAC"
        case .danielson:
            return "Danielson"
        }
    }

    var description: String {
        switch self {
        case .tlac:
            return "Practical teaching techniques from Doug Lemov's research on high-performing teachers."
        case .danielson:
            return "Charlotte Danielson's Framework for Teaching, focusing on observable classroom components."
        }
    }
}
