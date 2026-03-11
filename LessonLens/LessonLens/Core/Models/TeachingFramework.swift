import Foundation

/// Represents a teaching framework for evaluation
enum TeachingFramework: String, Codable, CaseIterable, Identifiable {
    case tlac = "tlac"
    case danielson = "danielson"
    case rosenshine = "rosenshine"
    case avid = "avid"
    case nationalBoard = "nationalBoard"
    case psdEssentials = "psdEssentials"
    case behaviorSupport = "behaviorSupport"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tlac:
            return "TLAC (Teach Like A Champion)"
        case .danielson:
            return "Danielson Framework"
        case .rosenshine:
            return "Rosenshine's Principles of Instruction"
        case .avid:
            return "AVID WICOR"
        case .nationalBoard:
            return "National Board Standards"
        case .psdEssentials:
            return "PSD Instructional Essentials"
        case .behaviorSupport:
            return "Behavior Support Strategies"
        }
    }

    var shortName: String {
        switch self {
        case .tlac:
            return "TLAC"
        case .danielson:
            return "Danielson"
        case .rosenshine:
            return "Rosenshine"
        case .avid:
            return "AVID"
        case .nationalBoard:
            return "NBPTS"
        case .psdEssentials:
            return "PSD"
        case .behaviorSupport:
            return "Behavior"
        }
    }

    var description: String {
        switch self {
        case .tlac:
            return "Practical teaching techniques from Doug Lemov's research on high-performing teachers."
        case .danielson:
            return "Charlotte Danielson's Framework for Teaching, focusing on observable classroom components."
        case .rosenshine:
            return "Research-based principles from Barak Rosenshine's synthesis of cognitive science and classroom instruction research."
        case .avid:
            return "AVID's WICOR framework focusing on Writing, Inquiry, Collaboration, Organization, and Reading strategies for college readiness."
        case .nationalBoard:
            return "National Board for Professional Teaching Standards' Five Core Propositions for accomplished teaching practice."
        case .psdEssentials:
            return "Peninsula School District's Tier 1 instructional practices supporting rigorous, inclusive, and future-focused learning."
        case .behaviorSupport:
            return "Focused on proactive and responsive strategies teachers can implement immediately to support student behavior and classroom management."
        }
    }

    var learnMoreURL: URL? {
        switch self {
        case .tlac:
            return URL(string: "https://teachlikeachampion.org")
        case .danielson:
            return URL(string: "https://danielsongroup.org")
        case .rosenshine:
            return URL(string: "https://www.teachertoolkit.co.uk/2020/01/07/rosenshine-principles")
        case .avid:
            return URL(string: "https://www.avid.org")
        case .nationalBoard:
            return URL(string: "https://www.nbpts.org")
        case .psdEssentials:
            return URL(string: "https://www.psd401.net")
        case .behaviorSupport:
            return URL(string: "https://www.pbis.org")
        }
    }
}
