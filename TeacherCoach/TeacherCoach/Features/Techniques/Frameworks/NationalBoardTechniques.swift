import Foundation

/// National Board for Professional Teaching Standards technique definitions
/// Based on the Five Core Propositions expanded into observable classroom practices
struct NationalBoardTechniques {
    static func createTechniques() -> [Technique] {
        [
            // Proposition 1: Teachers are committed to students and their learning

            Technique(
                id: "nbpts-equity-access",
                name: "Equity & Access",
                category: .differentiation,
                description: "Ensuring all students have equitable access to learning opportunities regardless of background, ability, or circumstances.",
                frameworkId: TeachingFramework.nationalBoard.rawValue,
                sortOrder: 1,
                lookFors: [
                    "All students called on equitably during discussions",
                    "Materials and resources accessible to all learners",
                    "Physical arrangement supports all students' participation",
                    "Multiple entry points provided for learning tasks",
                    "Teacher actively addresses barriers to participation",
                    "Diverse perspectives and voices represented in content"
                ],
                exemplarPhrases: [
                    "I want to hear from someone who hasn't shared yet",
                    "There are multiple ways to approach this problem",
                    "Let me make sure everyone can see and access the materials",
                    "Your perspective matters - tell us more",
                    "How can I help you engage with this material?",
                    "Everyone's contribution is valuable here"
                ]
            ),

            Technique(
                id: "nbpts-student-centered",
                name: "Student-Centered Differentiation",
                category: .differentiation,
                description: "Recognizing and responding to individual student differences in development, learning styles, strengths, and needs.",
                frameworkId: TeachingFramework.nationalBoard.rawValue,
                sortOrder: 2,
                lookFors: [
                    "Tasks adjusted based on individual student needs",
                    "Multiple pathways to demonstrate understanding offered",
                    "Student interests incorporated into learning",
                    "Flexible grouping based on learning needs",
                    "Scaffolds provided for struggling learners",
                    "Extensions available for advanced learners"
                ],
                exemplarPhrases: [
                    "Choose the method that works best for you",
                    "I've prepared different options based on what you need",
                    "How does this connect to what you're interested in?",
                    "Let's work together on this part before you continue",
                    "If you're ready for more challenge, try this extension",
                    "What support do you need to be successful?"
                ]
            ),

            // Proposition 2: Teachers know the subjects they teach and how to teach those subjects

            Technique(
                id: "nbpts-content-mastery",
                name: "Content Mastery",
                category: .instruction,
                description: "Demonstrating deep understanding of subject matter, including its history, structure, and real-world applications.",
                frameworkId: TeachingFramework.nationalBoard.rawValue,
                sortOrder: 3,
                lookFors: [
                    "Accurate and precise use of content vocabulary",
                    "Connections made between concepts within the discipline",
                    "Real-world applications of content explained",
                    "Misconceptions anticipated and addressed",
                    "Content presented with appropriate depth and complexity",
                    "Teacher responds confidently to student content questions"
                ],
                exemplarPhrases: [
                    "This concept connects to what we learned about...",
                    "Scientists use this in the real world when they...",
                    "A common misconception is... but actually...",
                    "Let me explain the underlying principle here",
                    "This is foundational because it helps us understand...",
                    "Good question - here's how this relates to the bigger picture"
                ]
            ),

            Technique(
                id: "nbpts-pedagogical-repertoire",
                name: "Pedagogical Repertoire",
                category: .instruction,
                description: "Using multiple instructional strategies effectively to make content accessible and engaging for all learners.",
                frameworkId: TeachingFramework.nationalBoard.rawValue,
                sortOrder: 4,
                lookFors: [
                    "Multiple modalities used in instruction",
                    "Strategies matched to learning objectives",
                    "Smooth transitions between instructional approaches",
                    "Student engagement maintained through varied methods",
                    "Abstract concepts made concrete through examples",
                    "Technology integrated purposefully"
                ],
                exemplarPhrases: [
                    "Let's look at this a different way",
                    "Watch as I demonstrate, then you'll try it",
                    "Here's a visual representation of the concept",
                    "Now let's apply this through hands-on practice",
                    "Work with your partner to explore this idea",
                    "Let's use this simulation to see the concept in action"
                ]
            ),

            // Proposition 3: Teachers are responsible for managing and monitoring student learning

            Technique(
                id: "nbpts-learning-goals",
                name: "Learning Goals & Objectives",
                category: .instruction,
                description: "Clear articulation and communication of learning targets that guide instruction and student effort.",
                frameworkId: TeachingFramework.nationalBoard.rawValue,
                sortOrder: 5,
                lookFors: [
                    "Learning objectives clearly stated and visible",
                    "Success criteria defined and shared",
                    "Objectives referenced throughout the lesson",
                    "Students can articulate what they are learning",
                    "Activities aligned to stated objectives",
                    "Closure connects back to learning goals"
                ],
                exemplarPhrases: [
                    "Today's learning target is...",
                    "By the end of class, you'll be able to...",
                    "Here's how you'll know you've met the objective",
                    "How does this activity help us reach our goal?",
                    "Let's check in - where are we with our learning target?",
                    "What did we learn today that connects to our objective?"
                ]
            ),

            Technique(
                id: "nbpts-formative-assessment",
                name: "Formative Assessment",
                category: .feedback,
                description: "Ongoing monitoring of student understanding to adjust instruction in real-time.",
                frameworkId: TeachingFramework.nationalBoard.rawValue,
                sortOrder: 6,
                lookFors: [
                    "Frequent checks for understanding throughout lesson",
                    "Multiple students' understanding assessed, not just volunteers",
                    "Instruction adjusted based on student responses",
                    "Exit tickets or quick assessments used",
                    "Misconceptions identified and addressed immediately",
                    "Students receive timely feedback on their learning"
                ],
                exemplarPhrases: [
                    "Show me with your thumbs where you are",
                    "Write your answer on your whiteboard",
                    "I'm noticing some confusion here - let me clarify",
                    "Based on your responses, we need to revisit this",
                    "Let's pause and check our understanding",
                    "Before we move on, tell me one thing you learned"
                ]
            ),

            Technique(
                id: "nbpts-student-engagement",
                name: "Student Engagement",
                category: .engagement,
                description: "Active involvement of all students in meaningful, rigorous learning experiences.",
                frameworkId: TeachingFramework.nationalBoard.rawValue,
                sortOrder: 7,
                lookFors: [
                    "Students actively participating, not passively receiving",
                    "High cognitive demand maintained in tasks",
                    "Students explaining their thinking",
                    "Multiple students engaged simultaneously",
                    "Off-task behavior minimal and quickly redirected",
                    "Students take ownership of their learning"
                ],
                exemplarPhrases: [
                    "Everyone think about this, then share with your partner",
                    "Explain your reasoning to the class",
                    "I need everyone's pencils moving",
                    "What's your evidence for that conclusion?",
                    "You're the expert now - teach your group",
                    "Push yourself to think more deeply about this"
                ]
            ),

            // Proposition 4: Teachers think systematically about their practice and learn from experience

            Technique(
                id: "nbpts-reflective-practice",
                name: "Reflective Practice",
                category: .feedback,
                description: "Evidence-based reflection on teaching effectiveness and continuous improvement of practice.",
                frameworkId: TeachingFramework.nationalBoard.rawValue,
                sortOrder: 8,
                lookFors: [
                    "Teacher acknowledges what worked and what didn't",
                    "Adjustments made based on student outcomes",
                    "Teacher solicits student feedback on learning",
                    "Lesson modifications noted for future teaching",
                    "Teacher models reflective thinking for students",
                    "Growth mindset demonstrated about teaching practice"
                ],
                exemplarPhrases: [
                    "That didn't go as planned - let me try a different approach",
                    "What worked for you today? What didn't?",
                    "Next time I teach this, I'll...",
                    "I'm learning from your feedback",
                    "Let's think about what we could do differently",
                    "I noticed that strategy was effective - I'll use it again"
                ]
            ),

            Technique(
                id: "nbpts-data-driven",
                name: "Data-Driven Decisions",
                category: .instruction,
                description: "Using evidence and data to inform instructional decisions and interventions.",
                frameworkId: TeachingFramework.nationalBoard.rawValue,
                sortOrder: 9,
                lookFors: [
                    "Assessment data referenced in planning",
                    "Student work analyzed to inform instruction",
                    "Patterns in student understanding identified",
                    "Interventions based on documented needs",
                    "Progress monitoring evident in instruction",
                    "Data shared with students to set goals"
                ],
                exemplarPhrases: [
                    "Based on yesterday's assessment, we need to focus on...",
                    "The data shows most of you understand X but need work on Y",
                    "Let's look at your progress over time",
                    "I've grouped you based on what you need next",
                    "Your work tells me you're ready for the next step",
                    "Here's what the evidence shows about your learning"
                ]
            ),

            // Proposition 5: Teachers are members of learning communities

            Technique(
                id: "nbpts-collaborative-culture",
                name: "Collaborative Culture",
                category: .engagement,
                description: "Building a classroom community that values collaboration, respect, and collective responsibility for learning.",
                frameworkId: TeachingFramework.nationalBoard.rawValue,
                sortOrder: 10,
                lookFors: [
                    "Classroom norms established and referenced",
                    "Students work collaboratively and support each other",
                    "Respectful discourse modeled and expected",
                    "Students hold each other accountable for learning",
                    "Mistakes treated as learning opportunities",
                    "Sense of belonging and community evident"
                ],
                exemplarPhrases: [
                    "Remember our agreement about respectful discussion",
                    "Help your partner understand the concept",
                    "We're all learners here - it's okay to make mistakes",
                    "What can we do as a class to help everyone succeed?",
                    "I appreciate how you supported your classmate",
                    "We learn better when we work together"
                ]
            )
        ]
    }

    /// Returns the default enabled technique IDs for National Board Standards
    static var defaultEnabledIds: [String] {
        createTechniques().map { $0.id }
    }
}
