import Foundation

/// Rosenshine's Principles of Instruction technique definitions
/// Based on Barak Rosenshine's 2012 synthesis of cognitive science and classroom instruction research
struct RosenshineTechniques {
    static func createTechniques() -> [Technique] {
        [
            // Principle 1: Daily Review
            Technique(
                id: "rosenshine-1",
                name: "Daily Review",
                category: .instruction,
                description: "Begin each lesson with a short review of previous learning to strengthen connections and ensure prerequisite skills are readily available.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 1,
                lookFors: [
                    "Lesson begins with review of previous content",
                    "Teacher checks for retention of prior learning",
                    "Students recall and articulate previous concepts",
                    "Connections made between prior and new learning",
                    "Homework or practice from previous day is reviewed",
                    "Gaps in understanding are identified and addressed"
                ],
                exemplarPhrases: [
                    "Let's start by reviewing what we learned yesterday",
                    "Who can remind us of the key points from last lesson?",
                    "Before we move on, let's check our understanding of...",
                    "How does this connect to what we learned before?",
                    "What questions came up from yesterday's practice?"
                ]
            ),

            // Principle 2: Present New Material in Small Steps
            Technique(
                id: "rosenshine-2",
                name: "Present New Material in Small Steps",
                category: .instruction,
                description: "Present new material in small amounts with student practice after each step to avoid overwhelming working memory.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 2,
                lookFors: [
                    "Content broken into manageable chunks",
                    "Practice follows each small step",
                    "Teacher pauses to check understanding before moving on",
                    "Complexity gradually increases",
                    "One concept taught before introducing the next",
                    "Students master each step before proceeding"
                ],
                exemplarPhrases: [
                    "Let's focus on just this first part",
                    "Once you've got this, we'll add the next step",
                    "Let's practice this before we move on",
                    "I'm going to break this down into smaller pieces",
                    "Now that you've mastered that, here's the next part"
                ]
            ),

            // Principle 3: Ask Questions
            Technique(
                id: "rosenshine-3",
                name: "Ask Questions",
                category: .questioning,
                description: "Ask a large number of questions and check responses of all students to ensure engagement and assess understanding.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 3,
                lookFors: [
                    "Frequent questions throughout instruction",
                    "Questions check for understanding, not just recall",
                    "All students required to respond (not just volunteers)",
                    "Teacher uses cold calling or response systems",
                    "Follow-up questions probe deeper thinking",
                    "Questions spaced throughout the lesson"
                ],
                exemplarPhrases: [
                    "Everyone, show me your answer on your whiteboard",
                    "Turn to your partner and explain why...",
                    "I'm going to call on someone to explain this",
                    "What makes you think that? Tell me more",
                    "Can you give me an example of that?"
                ]
            ),

            // Principle 4: Provide Models
            Technique(
                id: "rosenshine-4",
                name: "Provide Models",
                category: .instruction,
                description: "Provide models and worked examples that demonstrate the steps or processes students will use.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 4,
                lookFors: [
                    "Teacher demonstrates complete worked examples",
                    "Think-aloud reveals expert thinking process",
                    "Multiple examples provided before practice",
                    "Models show both correct process and common errors",
                    "Exemplars of quality work are shared",
                    "Visual models and graphic organizers used"
                ],
                exemplarPhrases: [
                    "Watch as I work through this example",
                    "I'm thinking out loud so you can hear my process",
                    "Here's what a strong response looks like",
                    "Notice how I...",
                    "Let me show you another example before you try"
                ]
            ),

            // Principle 5: Guide Practice
            Technique(
                id: "rosenshine-5",
                name: "Guide Practice",
                category: .engagement,
                description: "Guide student practice by working through problems together with high levels of teacher support before independent work.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 5,
                lookFors: [
                    "Teacher and students work through problems together",
                    "Gradual release from teacher to student control",
                    "Teacher provides prompts and cues during practice",
                    "Errors corrected immediately",
                    "High levels of success during guided practice",
                    "Teacher monitors and adjusts support as needed"
                ],
                exemplarPhrases: [
                    "Let's do this one together",
                    "What should our first step be?",
                    "I'll start, then you continue",
                    "Let me give you a hint...",
                    "Good, now what comes next?"
                ]
            ),

            // Principle 6: Check for Understanding
            Technique(
                id: "rosenshine-6",
                name: "Check for Understanding",
                category: .feedback,
                description: "Check for student understanding frequently by using techniques that require responses from all students.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 6,
                lookFors: [
                    "Frequent comprehension checks throughout lesson",
                    "All students required to demonstrate understanding",
                    "Multiple checking methods used (whiteboards, signals, etc.)",
                    "Teacher adjusts instruction based on checks",
                    "Misconceptions identified and addressed",
                    "Reteaching occurs when understanding is low"
                ],
                exemplarPhrases: [
                    "Show me thumbs up if you understand, thumbs down if you need help",
                    "Write your answer on your whiteboard and hold it up",
                    "Before we continue, let me check that everyone's got this",
                    "I noticed some confusion, so let me explain again",
                    "On a scale of 1-5, how confident are you?"
                ]
            ),

            // Principle 7: Obtain High Success Rate
            Technique(
                id: "rosenshine-7",
                name: "Obtain High Success Rate",
                category: .feedback,
                description: "Ensure students have a high success rate (80% or higher) during initial learning to build confidence and automaticity.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 7,
                lookFors: [
                    "Most students succeeding on practice tasks",
                    "Task difficulty appropriately scaffolded",
                    "Teacher provides support before frustration sets in",
                    "Success is celebrated and reinforced",
                    "Struggling students receive additional help",
                    "Pace allows for mastery before moving on"
                ],
                exemplarPhrases: [
                    "You've got this - look at how many you're getting right",
                    "Let me make this a bit easier so you can build success",
                    "Great progress! Most of you are ready for the next challenge",
                    "If you're finding this too hard, come see me for support",
                    "I want everyone to feel successful before we move on"
                ]
            ),

            // Principle 8: Provide Scaffolds
            Technique(
                id: "rosenshine-8",
                name: "Provide Scaffolds",
                category: .differentiation,
                description: "Provide scaffolds and supports for difficult tasks, then gradually remove them as students become more proficient.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 8,
                lookFors: [
                    "Temporary supports provided for complex tasks",
                    "Scaffolds match the difficulty of the task",
                    "Supports gradually removed over time",
                    "Checklists, templates, or sentence starters used",
                    "Think sheets or graphic organizers provided",
                    "Teacher models use of scaffolds"
                ],
                exemplarPhrases: [
                    "Use this checklist to help you remember the steps",
                    "Here's a sentence starter to get you going",
                    "This graphic organizer will help you organize your thinking",
                    "Once you're comfortable, try it without the support",
                    "The scaffold is there if you need it"
                ]
            ),

            // Principle 9: Independent Practice
            Technique(
                id: "rosenshine-9",
                name: "Independent Practice",
                category: .engagement,
                description: "Require and monitor independent practice to develop fluency and automaticity with new learning.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 9,
                lookFors: [
                    "Students practice independently after guided practice",
                    "Practice is sufficient for overlearning",
                    "Teacher monitors during independent work",
                    "Feedback provided on independent practice",
                    "Practice is purposeful and connected to learning goals",
                    "Students work without teacher assistance"
                ],
                exemplarPhrases: [
                    "Now it's your turn to try on your own",
                    "Practice until it becomes automatic",
                    "I'll be walking around to check your work",
                    "If you get stuck, try using the strategies we learned",
                    "Keep practicing - this is how we build fluency"
                ]
            ),

            // Principle 10: Weekly and Monthly Review
            Technique(
                id: "rosenshine-10",
                name: "Weekly and Monthly Review",
                category: .instruction,
                description: "Engage students in weekly and monthly review to ensure long-term retention and transfer of learning.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 10,
                lookFors: [
                    "Regular review sessions scheduled",
                    "Previously learned material revisited",
                    "Spaced practice incorporated",
                    "Cumulative assessments or quizzes used",
                    "Connections made across units and topics",
                    "Students retrieve information from memory"
                ],
                exemplarPhrases: [
                    "Let's review what we've learned this week",
                    "Remember when we studied this last month? Let's revisit it",
                    "This quiz covers everything we've learned so far",
                    "How does this connect to what we learned in September?",
                    "Let's practice retrieving this from memory"
                ]
            )
        ]
    }

    /// Returns the default enabled technique IDs for Rosenshine
    static var defaultEnabledIds: [String] {
        createTechniques().map { $0.id }
    }
}
