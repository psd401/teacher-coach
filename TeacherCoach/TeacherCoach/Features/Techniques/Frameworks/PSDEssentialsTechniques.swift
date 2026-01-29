import Foundation

/// PSD Instructional Essentials technique definitions
/// Based on Peninsula School District's Tier 1 instructional practices organized into four focus areas:
/// Rigor & Inclusion, Data-Driven Decisions, Continuous Growth, and Innovation
struct PSDEssentialsTechniques {
    static func createTechniques() -> [Technique] {
        [
            // FOCUS AREA: Rigor & Inclusion

            Technique(
                id: "psd-building-academic-background",
                name: "Building Academic Background",
                category: .differentiation,
                description: "Teachers actively link new learning to what students already know, drawing from their cultural context, lived experiences, and previous learning to create a strong foundation for success with rigorous, grade-level content.",
                frameworkId: TeachingFramework.psdEssentials.rawValue,
                sortOrder: 1,
                lookFors: [
                    "Students refer to personal or community knowledge during class discussions",
                    "Student work shows increased accuracy and depth due to a strong conceptual foundation",
                    "Academic vocabulary is evident in student talk and writing",
                    "Students demonstrate confidence in participating early in a new unit or complex task",
                    "Shared experiences used to create common reference points before new content",
                    "Culturally relevant and identity-affirming hooks integrated into instruction"
                ],
                exemplarPhrases: [
                    "Before we begin, let's think about what you already know about this topic",
                    "How does this connect to your own experiences or community?",
                    "Let's look at these vocabulary words together before we read",
                    "What do you notice about this image? How does it relate to our new learning?",
                    "Tell me about a time when you experienced something similar",
                    "Let's create a shared experience we can all reference as we learn"
                ]
            ),

            Technique(
                id: "psd-scaffolding-differentiation",
                name: "Scaffolding & Differentiation",
                category: .differentiation,
                description: "Intentionally designing instruction so that all students—regardless of readiness, language background, or learning needs—can access rigorous content and engage in meaningful learning through temporary supports and multiple pathways.",
                frameworkId: TeachingFramework.psdEssentials.rawValue,
                sortOrder: 2,
                lookFors: [
                    "Student engagement is high across varying ability levels",
                    "All students complete rigorous tasks with appropriate supports",
                    "Students can articulate what helps them learn or what tools they use",
                    "Groupings and scaffolds are fluid and responsive to learning progress",
                    "Multiple pathways to demonstrate understanding offered",
                    "Scaffolds are temporary and gradually removed as independence grows"
                ],
                exemplarPhrases: [
                    "I've prepared different options based on what you need",
                    "Choose the method that works best for you",
                    "Here's a graphic organizer to help you structure your thinking",
                    "Let's work through this first example together before you try independently",
                    "Use these sentence frames if you need support getting started",
                    "If you're ready for more challenge, try this extension"
                ]
            ),

            // FOCUS AREA: Data-Driven Decisions

            Technique(
                id: "psd-formative-assessment-feedback",
                name: "Formative Assessment & Feedback",
                category: .feedback,
                description: "Ongoing process of gathering evidence of learning, providing students with actionable feedback, and adjusting instruction in real time to improve student understanding and ensure all learners stay on track.",
                frameworkId: TeachingFramework.psdEssentials.rawValue,
                sortOrder: 3,
                lookFors: [
                    "Students can articulate what they are learning and how they know they're making progress",
                    "Feedback given during class is specific, tied to the learning goal, and prompts visible revision",
                    "Instruction visibly shifts based on student needs within or across lessons",
                    "Student work improves over time in response to feedback",
                    "Formative checks are embedded throughout instruction—not just at the end",
                    "Misconceptions identified and addressed immediately"
                ],
                exemplarPhrases: [
                    "Show me with your thumbs where you are with this concept",
                    "Write your answer on your whiteboard so I can see everyone's thinking",
                    "Your claim is strong—now revise the evidence to connect more clearly",
                    "Based on your responses, we need to revisit this before moving on",
                    "I'm noticing some confusion here—let me clarify",
                    "Here's what you did well, and here's your specific next step"
                ]
            ),

            Technique(
                id: "psd-student-self-assessment",
                name: "Student Self-Assessment",
                category: .engagement,
                description: "Students evaluate their own learning relative to clear goals and criteria, becoming more engaged, metacognitive, and invested in improving by monitoring their progress and reflecting on strengths and growth areas.",
                frameworkId: TeachingFramework.psdEssentials.rawValue,
                sortOrder: 4,
                lookFors: [
                    "Students refer to learning goals and success criteria during work time",
                    "Student reflections show understanding of their own progress including strengths and growth areas",
                    "Students can articulate how they are improving and what strategies help them learn",
                    "Students use checklists, rubrics, or progress trackers to make instructional choices",
                    "Teachers use student self-assessment data to support goal-setting conferences",
                    "Regular structured reflection opportunities provided"
                ],
                exemplarPhrases: [
                    "Look at the success criteria—how would you rate your work?",
                    "What's one thing you did well and one thing you want to improve?",
                    "Set a goal for yourself based on where you are with this learning target",
                    "Use your rubric to identify your next step",
                    "Reflect on your progress—what strategies have been most helpful?",
                    "How do you know you're making progress toward mastery?"
                ]
            ),

            // FOCUS AREA: Continuous Growth

            Technique(
                id: "psd-collaborative-professional-learning",
                name: "Collaborative Professional Learning",
                category: .instruction,
                description: "Educators working together regularly and intentionally to reflect on their practice, analyze student work, and apply new strategies that lead to improved outcomes for all learners, grounded in shared responsibility and collective efficacy.",
                frameworkId: TeachingFramework.psdEssentials.rawValue,
                sortOrder: 5,
                lookFors: [
                    "Collaborative time is grounded in student learning—not logistics or administrative tasks",
                    "Teachers bring evidence (student work, data, planning artifacts) and engage in purposeful analysis",
                    "Teams reflect on the implementation of new strategies and adjust based on what works",
                    "Teachers feel a sense of shared responsibility for all students—not just their own",
                    "Instruction across classrooms becomes more coherent and aligned to grade-level expectations",
                    "Student work used as anchor for calibrating expectations"
                ],
                exemplarPhrases: [
                    "Let's look at these student samples together to calibrate our expectations",
                    "What does the data tell us about where students need support?",
                    "How did the new strategy work in your classroom? What adjustments did you make?",
                    "What evidence are we using to drive our decisions?",
                    "Let's plan this lesson together so we're aligned across classrooms",
                    "How are we measuring whether our shared practices are improving outcomes?"
                ]
            ),

            Technique(
                id: "psd-observation-feedback-cycles",
                name: "Actionable Observation & Feedback Cycles",
                category: .feedback,
                description: "Timely, targeted feedback based on evidence of practice, which leads to reflection, professional learning, and improved student outcomes through focused, non-evaluative input on instructional practices.",
                frameworkId: TeachingFramework.psdEssentials.rawValue,
                sortOrder: 6,
                lookFors: [
                    "Feedback is timely (within 24-48 hours) and aligned to instructional goals",
                    "Teachers can articulate a clear focus area or goal they're working on",
                    "Observation and feedback cycles are seen as developmental, not evaluative",
                    "Teachers apply feedback in visible, actionable ways that impact instruction",
                    "Feedback is part of an ongoing cycle, not a one-time event",
                    "Time provided for reflection and two-way dialogue"
                ],
                exemplarPhrases: [
                    "I noticed you used wait time effectively—students had time to think",
                    "Let's look at the evidence from your lesson and discuss what you noticed",
                    "What instructional goal are you currently working on?",
                    "Here's what I observed about student engagement during the activity",
                    "How has recent feedback informed changes in your practice?",
                    "What kind of feedback would be most helpful to you right now?"
                ]
            ),

            // FOCUS AREA: Innovation

            Technique(
                id: "psd-real-world-connections",
                name: "Real-World Connections",
                category: .engagement,
                description: "Learning experiences that reflect authentic problems, scenarios, or applications students may encounter in their lives, communities, or future careers, fostering engagement, critical thinking, and purpose.",
                frameworkId: TeachingFramework.psdEssentials.rawValue,
                sortOrder: 7,
                lookFors: [
                    "Students can clearly articulate how their learning connects to the world beyond school",
                    "Tasks include elements of student voice, purpose, and choice",
                    "Guest speakers, local contexts, or community issues are integrated into instruction",
                    "Student products have audiences beyond the teacher (presentations, exhibits, publications)",
                    "Engagement increases as students see relevance and value in what they're learning",
                    "Authentic problems or contexts frame the learning"
                ],
                exemplarPhrases: [
                    "How does this connect to something happening in our community right now?",
                    "Who might use this skill in their career?",
                    "You'll be presenting your solutions to actual community members",
                    "What real-world problem could we solve using what we're learning?",
                    "Choose a topic that matters to you personally",
                    "How might you apply this learning outside of school?"
                ]
            ),

            Technique(
                id: "psd-intentional-technology",
                name: "Intentional Use of Technology",
                category: .instruction,
                description: "Selecting tools and platforms that meaningfully support instructional goals by promoting engagement, collaboration, creativity, accessibility, and student agency—technology that enhances rather than replaces strong instruction.",
                frameworkId: TeachingFramework.psdEssentials.rawValue,
                sortOrder: 8,
                lookFors: [
                    "Technology use is clearly aligned to instructional goals—not used for its own sake",
                    "Students use digital tools to explore, create, and collaborate—not just consume",
                    "Tools are selected to enhance accessibility, personalize learning, or offer flexible expression",
                    "Students can explain how the technology supports their learning",
                    "Classrooms reflect a blend of tech-enhanced and hands-on learning",
                    "Built-in accessibility features (text-to-speech, captions, translations) utilized"
                ],
                exemplarPhrases: [
                    "Use this tool to collaborate with your partner in real time",
                    "Choose the digital tool that best helps you demonstrate your understanding",
                    "The immersive reader feature can help you access this text",
                    "How is this technology helping you think more deeply about the content?",
                    "Record your thinking using the voice note feature",
                    "Create a digital artifact that shows your learning process"
                ]
            )
        ]
    }

    /// Returns the default enabled technique IDs for PSD Instructional Essentials
    static var defaultEnabledIds: [String] {
        createTechniques().map { $0.id }
    }
}
