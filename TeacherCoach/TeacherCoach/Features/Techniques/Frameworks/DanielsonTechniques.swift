import Foundation

/// Danielson Framework for Teaching technique definitions
/// Based on Charlotte Danielson's Framework for Teaching
/// Focused on observable classroom components (Domains 2 and 3)
struct DanielsonTechniques {
    static func createTechniques() -> [Technique] {
        [
            // Domain 2: Classroom Environment
            Technique(
                id: "danielson-2a",
                name: "2a: Environment of Respect",
                category: .management,
                description: "Creating an environment of respect and rapport where teacher-student and student-student interactions are respectful.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 1,
                lookFors: [
                    "Respectful talk between teacher and students",
                    "Students demonstrate respect for each other",
                    "Teacher responds appropriately to disrespect",
                    "Body language conveys warmth and caring",
                    "Use of student names and personal connections"
                ],
                exemplarPhrases: [
                    "Thank you for sharing your perspective",
                    "I appreciate you helping your classmate",
                    "That's a thoughtful question",
                    "We can disagree respectfully",
                    "I can see you're working hard on this"
                ]
            ),
            Technique(
                id: "danielson-2b",
                name: "2b: Culture for Learning",
                category: .engagement,
                description: "Establishing a culture for learning where the classroom conveys high expectations for student achievement.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 2,
                lookFors: [
                    "High expectations communicated to all students",
                    "Importance of content is evident",
                    "Students demonstrate pride in their work",
                    "Learning mistakes treated as opportunities",
                    "Students persist through challenges"
                ],
                exemplarPhrases: [
                    "I know this is challenging, and I know you can do it",
                    "This work matters because...",
                    "Let's dig deeper into this",
                    "Making mistakes helps us learn",
                    "Quality work looks like..."
                ]
            ),
            Technique(
                id: "danielson-2c",
                name: "2c: Managing Procedures",
                category: .management,
                description: "Managing classroom procedures so instructional time is maximized through efficient routines and transitions.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 3,
                lookFors: [
                    "Smooth transitions between activities",
                    "Students know procedures without prompting",
                    "Materials distributed efficiently",
                    "Little instructional time lost",
                    "Students manage their own work"
                ],
                exemplarPhrases: [
                    "When you hear the signal, begin...",
                    "Materials managers, please distribute...",
                    "You have 30 seconds to transition",
                    "Remember our procedure for...",
                    "Check the board for your next step"
                ]
            ),
            Technique(
                id: "danielson-2d",
                name: "2d: Managing Behavior",
                category: .management,
                description: "Managing student behavior through clear standards and preventive monitoring.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 4,
                lookFors: [
                    "Clear standards of conduct evident",
                    "Teacher monitors behavior proactively",
                    "Subtle, non-disruptive interventions",
                    "Students self-regulate behavior",
                    "Consistent application of expectations"
                ],
                exemplarPhrases: [
                    "Remember our agreement about...",
                    "I notice some of us are...",
                    "What should you be doing right now?",
                    "I'm going to wait for everyone",
                    "Show me what ready looks like"
                ]
            ),

            // Domain 3: Instruction
            Technique(
                id: "danielson-3a",
                name: "3a: Communicating with Students",
                category: .instruction,
                description: "Communicating with students using clear and accurate explanations of content and learning expectations.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 5,
                lookFors: [
                    "Clear explanation of learning goals",
                    "Accurate content presentation",
                    "Vocabulary appropriate to students",
                    "Clear directions for activities",
                    "Connects new learning to prior knowledge"
                ],
                exemplarPhrases: [
                    "Today's learning target is...",
                    "By the end of class, you will be able to...",
                    "This connects to what we learned about...",
                    "Let me explain what I mean by...",
                    "Here are the steps you'll follow..."
                ]
            ),
            Technique(
                id: "danielson-3b",
                name: "3b: Questioning and Discussion",
                category: .questioning,
                description: "Using questioning and discussion techniques that engage students and promote deep thinking.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 6,
                lookFors: [
                    "Questions at multiple cognitive levels",
                    "Adequate wait time provided",
                    "Students respond to each other",
                    "Teacher probes for deeper understanding",
                    "Discussion is genuine, not scripted"
                ],
                exemplarPhrases: [
                    "What makes you think that?",
                    "Can someone build on that idea?",
                    "Do you agree or disagree? Why?",
                    "How did you arrive at that conclusion?",
                    "What would happen if...?"
                ]
            ),
            Technique(
                id: "danielson-3c",
                name: "3c: Engaging Students",
                category: .engagement,
                description: "Engaging students in learning through meaningful activities and appropriate pacing.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 7,
                lookFors: [
                    "Activities aligned to learning goals",
                    "Students intellectually engaged",
                    "Appropriate pacing for all learners",
                    "Multiple modalities used",
                    "Students have choices in their learning"
                ],
                exemplarPhrases: [
                    "You can show your understanding by...",
                    "Work at your own pace on...",
                    "Choose which problem to start with",
                    "Let's try a different approach",
                    "How else might we represent this?"
                ]
            ),
            Technique(
                id: "danielson-3d",
                name: "3d: Using Assessment",
                category: .feedback,
                description: "Using assessment in instruction to monitor student learning and provide feedback.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 8,
                lookFors: [
                    "Ongoing monitoring of understanding",
                    "Timely and specific feedback given",
                    "Students use feedback to improve",
                    "Self and peer assessment used",
                    "Instruction adjusted based on data"
                ],
                exemplarPhrases: [
                    "Show me what you've got so far",
                    "Here's what's working well...",
                    "One thing to improve is...",
                    "Check your work against the rubric",
                    "What feedback would you give yourself?"
                ]
            ),
            Technique(
                id: "danielson-3e",
                name: "3e: Flexibility and Responsiveness",
                category: .differentiation,
                description: "Demonstrating flexibility and responsiveness by adjusting instruction based on student needs.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 9,
                lookFors: [
                    "Teacher adjusts based on student cues",
                    "Capitalizes on teachable moments",
                    "Persists with struggling students",
                    "Accommodates student questions",
                    "Modifies plans when needed"
                ],
                exemplarPhrases: [
                    "Let's take a different approach",
                    "That's a great question, let's explore it",
                    "I can see some of us need more practice",
                    "Let me show you another way",
                    "Since you're ready, here's a challenge..."
                ]
            )
        ]
    }

    /// Returns the default enabled technique IDs for Danielson
    static var defaultEnabledIds: [String] {
        createTechniques().map { $0.id }
    }
}
