import Foundation

/// AVID WICOR technique definitions
/// Based on AVID's college-readiness framework with five pillars: Writing, Inquiry, Collaboration, Organization, Reading
struct AVIDTechniques {
    static func createTechniques() -> [Technique] {
        [
            // Writing - Writing to Learn
            Technique(
                id: "avid-writing",
                name: "Writing to Learn",
                category: .instruction,
                description: "Using writing as a tool for thinking and learning across all content areas, including note-taking, reflective writing, and written responses.",
                frameworkId: TeachingFramework.avid.rawValue,
                sortOrder: 1,
                lookFors: [
                    "Students take focused notes during instruction",
                    "Cornell Notes or similar note-taking system used",
                    "Quick writes or reflective writing prompts given",
                    "Students summarize learning in writing",
                    "Written responses required before discussion",
                    "Learning logs or journals used to process content"
                ],
                exemplarPhrases: [
                    "Take two minutes to write what you're thinking about this",
                    "Add this to the notes section of your Cornell Notes",
                    "Write a summary in your own words",
                    "Before we discuss, write your initial response",
                    "In the cue column, write a question about this concept",
                    "Complete your learning log entry for today"
                ]
            ),

            // Inquiry - Questioning to Drive Learning
            Technique(
                id: "avid-inquiry",
                name: "Inquiry",
                category: .questioning,
                description: "Using questions to drive learning and develop critical thinking skills through Socratic seminars, Costa's Levels of Questioning, and student-generated questions.",
                frameworkId: TeachingFramework.avid.rawValue,
                sortOrder: 2,
                lookFors: [
                    "Students generate their own questions",
                    "Costa's Levels of Questioning used (Level 1, 2, 3)",
                    "Socratic seminars or philosophical chairs conducted",
                    "Teacher poses open-ended questions",
                    "Questions move from recall to analysis to evaluation",
                    "Students defend positions with evidence"
                ],
                exemplarPhrases: [
                    "What Level 2 or 3 question could you ask about this?",
                    "Let's use a Socratic seminar to explore this text",
                    "What evidence supports your thinking?",
                    "Generate three questions you still have about this topic",
                    "How would you evaluate this claim?",
                    "What's the relationship between these two concepts?"
                ]
            ),

            // Collaboration - Structured Student Interaction
            Technique(
                id: "avid-collaboration",
                name: "Collaboration",
                category: .engagement,
                description: "Structured student-to-student interaction through collaborative study groups, tutorials, and academic discourse protocols.",
                frameworkId: TeachingFramework.avid.rawValue,
                sortOrder: 3,
                lookFors: [
                    "Students work in structured collaborative groups",
                    "AVID tutorials or similar inquiry-based groups used",
                    "Students explain thinking to each other",
                    "Academic discourse protocols followed",
                    "Students build on each other's ideas",
                    "Group norms and roles established"
                ],
                exemplarPhrases: [
                    "Turn to your partner and explain your thinking",
                    "In your tutorial group, present your point of confusion",
                    "Use sentence starters to respond to your classmate",
                    "As a group, come to consensus on the answer",
                    "Build on what your partner said",
                    "Take turns being the presenter and the questioner"
                ]
            ),

            // Organization - Managing Learning
            Technique(
                id: "avid-organization",
                name: "Organization",
                category: .management,
                description: "Teaching explicit tools and strategies for managing time, materials, and learning including binders, planners, and goal-setting.",
                frameworkId: TeachingFramework.avid.rawValue,
                sortOrder: 4,
                lookFors: [
                    "Students use planners or agendas consistently",
                    "Binder or folder organization system taught",
                    "Students set and track academic goals",
                    "Time management strategies explicitly taught",
                    "Materials organized and accessible",
                    "Students monitor their own progress"
                ],
                exemplarPhrases: [
                    "Write this in your planner with the due date",
                    "File this in the correct section of your binder",
                    "Let's check in on your SMART goals",
                    "How will you plan your time to complete this project?",
                    "Update your grade tracker",
                    "What organizational strategy will help you here?"
                ]
            ),

            // Reading - Reading to Learn
            Technique(
                id: "avid-reading",
                name: "Reading to Learn",
                category: .instruction,
                description: "Strategic reading instruction across content areas using marking the text, annotation strategies, and active reading protocols.",
                frameworkId: TeachingFramework.avid.rawValue,
                sortOrder: 5,
                lookFors: [
                    "Students annotate texts while reading",
                    "Marking the text strategies used",
                    "Pre-reading strategies activate prior knowledge",
                    "Students identify main ideas and supporting details",
                    "Vocabulary instruction embedded in reading",
                    "Students discuss and write about texts"
                ],
                exemplarPhrases: [
                    "Mark the text as you read - underline key ideas",
                    "Annotate in the margin what you're thinking",
                    "Before we read, let's preview the text structure",
                    "Circle words you don't know as you read",
                    "What's the author's main argument? Find evidence",
                    "Use your annotations to prepare for discussion"
                ]
            )
        ]
    }

    /// Returns the default enabled technique IDs for AVID
    static var defaultEnabledIds: [String] {
        createTechniques().map { $0.id }
    }
}
