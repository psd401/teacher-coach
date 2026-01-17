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
        self.isBuiltIn = isBuiltIn
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
        self.lookForsData = try? JSONEncoder().encode(lookFors)
        self.exemplarPhrasesData = try? JSONEncoder().encode(exemplarPhrases)
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
    /// Creates all 10 built-in teaching techniques
    static func createBuiltInTechniques() -> [Technique] {
        [
            // Questioning
            Technique(
                id: "wait-time",
                name: "Wait Time",
                category: .questioning,
                description: "Providing 3-5 seconds of think time after asking a question before calling on students.",
                sortOrder: 1,
                lookFors: [
                    "Pause of 3+ seconds after asking question",
                    "Teacher not answering own questions",
                    "Silence allowed without rushing",
                    "Students given time to formulate thoughts"
                ],
                exemplarPhrases: [
                    "Take a moment to think about that",
                    "I'll give you some time to consider",
                    "Let's pause and think",
                    "I want everyone to have time to think"
                ]
            ),
            Technique(
                id: "higher-order-questions",
                name: "Higher-Order Questions",
                category: .questioning,
                description: "Asking questions that require analysis, synthesis, or evaluation rather than simple recall.",
                sortOrder: 2,
                lookFors: [
                    "Questions starting with 'why', 'how', 'what if'",
                    "Requests for comparison or contrast",
                    "Asking for predictions or hypotheses",
                    "Questions requiring justification or evidence"
                ],
                exemplarPhrases: [
                    "Why do you think that happened?",
                    "How would you solve this differently?",
                    "What evidence supports your answer?",
                    "What would happen if we changed...?",
                    "How does this compare to...?"
                ]
            ),

            // Engagement
            Technique(
                id: "cold-calling",
                name: "Cold Calling",
                category: .engagement,
                description: "Calling on students regardless of whether they raised their hand, in a supportive and predictable manner.",
                sortOrder: 3,
                lookFors: [
                    "Random or strategic student selection",
                    "Questions posed before naming student",
                    "All students appear engaged/ready to respond",
                    "Positive, low-stakes atmosphere maintained"
                ],
                exemplarPhrases: [
                    "Let's see... Marcus, what do you think?",
                    "I'm going to call on someone to share",
                    "Everyone should be ready to answer",
                    "[Student name], can you add to that?"
                ]
            ),
            Technique(
                id: "think-pair-share",
                name: "Think-Pair-Share",
                category: .engagement,
                description: "Structured collaborative learning where students think individually, discuss with a partner, then share with the class.",
                sortOrder: 4,
                lookFors: [
                    "Clear signal for think time",
                    "Partner discussion observed",
                    "Whole-class sharing follows",
                    "Structured timing for each phase"
                ],
                exemplarPhrases: [
                    "First, think on your own for 30 seconds",
                    "Now turn to your partner and discuss",
                    "Let's hear what you and your partner talked about",
                    "Share your thinking with your elbow partner"
                ]
            ),

            // Feedback
            Technique(
                id: "specific-praise",
                name: "Specific Praise",
                category: .feedback,
                description: "Providing precise, behavior-focused positive feedback that identifies exactly what the student did well.",
                sortOrder: 5,
                lookFors: [
                    "Names specific action or behavior",
                    "Connects praise to learning objective",
                    "Genuine and proportionate",
                    "Focuses on effort or strategy, not ability"
                ],
                exemplarPhrases: [
                    "I noticed you used evidence from the text",
                    "Your strategy of breaking it into steps worked well",
                    "That's a clear topic sentence that sets up your argument",
                    "You showed persistence when you tried a different approach"
                ]
            ),
            Technique(
                id: "check-for-understanding",
                name: "Check for Understanding",
                category: .feedback,
                description: "Systematically gathering evidence of student comprehension during instruction.",
                sortOrder: 6,
                lookFors: [
                    "Frequent pauses to check learning",
                    "Multiple students sampled",
                    "Variety of checking methods used",
                    "Instruction adjusted based on responses"
                ],
                exemplarPhrases: [
                    "Show me thumbs up if you've got it",
                    "Quick write: What's the main idea so far?",
                    "Turn and tell your partner the steps",
                    "On your whiteboard, show me...",
                    "Before we move on, who can summarize?"
                ]
            ),

            // Management
            Technique(
                id: "positive-framing",
                name: "Positive Framing",
                category: .management,
                description: "Guiding behavior through positive narration of expectations and highlighting desired behaviors.",
                sortOrder: 7,
                lookFors: [
                    "Describes what students should do, not what they shouldn't",
                    "Highlights students meeting expectations",
                    "Redirects with positive language",
                    "Assumes best intentions"
                ],
                exemplarPhrases: [
                    "I see table 3 is ready to begin",
                    "Thank you for tracking the speaker",
                    "When you're ready, your eyes will be on me",
                    "I'm looking for voices off and materials out"
                ]
            ),

            // Instruction
            Technique(
                id: "modeling-think-aloud",
                name: "Modeling/Think Aloud",
                category: .instruction,
                description: "Demonstrating thinking processes explicitly by verbalizing thoughts while solving problems or completing tasks.",
                sortOrder: 8,
                lookFors: [
                    "Teacher verbalizes internal thinking",
                    "Shows struggle and recovery",
                    "Makes expert strategies visible",
                    "Connects steps to concepts"
                ],
                exemplarPhrases: [
                    "Watch me as I work through this...",
                    "I'm noticing that... so I'm going to...",
                    "When I see this, I ask myself...",
                    "Let me show you what I'm thinking",
                    "Here's where I might get stuck, so I..."
                ]
            ),
            Technique(
                id: "scaffolded-practice",
                name: "Scaffolded Practice",
                category: .instruction,
                description: "Gradually releasing responsibility from teacher to students through structured practice phases.",
                sortOrder: 9,
                lookFors: [
                    "Clear 'I do, we do, you do' structure",
                    "Decreasing support over time",
                    "Checks before releasing to independent work",
                    "Returns to guided practice when needed"
                ],
                exemplarPhrases: [
                    "Let me show you first, then we'll try together",
                    "Now let's do one as a class",
                    "Try the next one with your partner",
                    "When you're confident, start the independent practice"
                ]
            ),

            // Differentiation
            Technique(
                id: "strategic-grouping",
                name: "Strategic Grouping",
                category: .differentiation,
                description: "Intentionally organizing students into groups based on learning needs, readiness, or interests.",
                sortOrder: 10,
                lookFors: [
                    "Different groups working on varied tasks/levels",
                    "Flexible grouping changes over time",
                    "Teacher circulates strategically to groups",
                    "Materials/scaffolds vary by group"
                ],
                exemplarPhrases: [
                    "Today you'll work with your blue group",
                    "This group will have sentence starters to help",
                    "Your extension activity is...",
                    "I'll meet with this small group while you..."
                ]
            )
        ]
    }
}
