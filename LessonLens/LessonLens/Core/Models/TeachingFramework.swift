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
            return URL(string: "https://danielsongroup.org/wp-content/uploads/2022/06/2022-Framework-for-Teaching_Draft_June-28-2022-.pdf")
        case .rosenshine:
            return URL(string: "https://www.aft.org/sites/default/files/Rosenshine.pdf")
        case .avid:
            return URL(string: "https://avidopenaccess.org/wp-content/uploads/2021/08/AVID-WICOR-flyer-080521_proofed.pdf")
        case .nationalBoard:
            return URL(string: "https://www.nbpts.org")
        case .psdEssentials:
            return URL(string: "https://www.canva.com/design/DAGufxfG2jY/fm4g7AIiXYPFf5pyNH3G2A/edit?ui=eyJEIjp7IlAiOnsiQiI6ZmFsc2V9fX0")
        case .behaviorSupport:
            return URL(string: "https://www.pbis.org")
        }
    }

    var displayOrder: Int {
        switch self {
        case .psdEssentials: return 0
        case .danielson: return 1
        case .behaviorSupport: return 2
        case .tlac: return 3
        case .rosenshine: return 4
        case .nationalBoard: return 5
        case .avid: return 6
        }
    }
}
