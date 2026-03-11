import Foundation

/// Rosenshine's Principles of Instruction technique definitions
/// Based on Barak Rosenshine's 2012 synthesis of cognitive science and classroom instruction research
/// Enriched with verbal signatures for transcript-based analysis
struct RosenshineTechniques {
    static func createTechniques() -> [Technique] {
        [
            // Principle 1: Daily Review
            Technique(
                id: "rosenshine-1",
                name: "Daily Review",
                category: .instruction,
                description: "Begin each lesson with a short review of previous learning to strengthen retrieval pathways and activate prerequisite knowledge. The verbal signature is backward-linking language at lesson start — explicit references to prior content, retrieval prompts that require students to recall from memory rather than notes, and bridge statements connecting yesterday's learning to today's objective.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 1,
                lookFors: [
                    "Lesson opens with explicit reference to prior content: 'Yesterday we learned...'",
                    "Retrieval prompts require recall from memory, not just recognition",
                    "Students articulate previous concepts in their own words",
                    "Bridge statement connects review to new learning: 'Today we'll build on that by...'",
                    "Gaps surfaced during review are addressed before new content"
                ],
                exemplarPhrases: [
                    "Before we start, without looking at your notes — what were the three causes we identified yesterday?",
                    "Who can remind us of the key principle from last lesson?",
                    "Turn to your partner and explain what we learned about X",
                    "Today we'll build on that foundation by...",
                    "I'm hearing some confusion about Y — let's clear that up before we move forward"
                ]
            ),

            // Principle 2: Present New Material in Small Steps
            Technique(
                id: "rosenshine-2",
                name: "Small Steps",
                category: .instruction,
                description: "Present new material in small amounts with student practice after each step, avoiding working memory overload. The verbal signature is chunking language — the teacher explicitly names boundaries ('Let's focus on just this first part'), pauses for processing, and gates progression on demonstrated understanding ('Before we add the next piece, show me you've got this').",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 2,
                lookFors: [
                    "Content explicitly chunked: 'Let's focus on just this part first'",
                    "Practice follows each chunk before new content is introduced",
                    "Gating language: 'Before we move on, show me you've got this'",
                    "Teacher names the sequence: 'Step one... step two...'",
                    "Complexity increases incrementally with teacher narration of the increase"
                ],
                exemplarPhrases: [
                    "Let's focus on just this first part",
                    "Once you've got this, we'll add the next layer",
                    "Let's practice this before we move on",
                    "I'm going to break this into three pieces so it's manageable",
                    "Show me you've mastered step one before we tackle step two"
                ]
            ),

            // Principle 3: Ask Questions
            Technique(
                id: "rosenshine-3",
                name: "Frequent Questioning",
                category: .questioning,
                description: "Ask a large number of questions throughout instruction and check responses from all students, not just volunteers. The verbal signature is high question density with universal response mechanisms — the teacher poses questions that require every student to produce an answer (whiteboards, signals, choral response) rather than accepting a single raised hand. Follow-up probes deepen initial answers.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 3,
                lookFors: [
                    "High question density — multiple questions per instructional segment",
                    "Universal response mechanisms: 'Everyone show me,' 'Write your answer'",
                    "Absence of 'Who knows...?' as the primary questioning mode",
                    "Follow-up probes after initial answers: 'Why?' 'How do you know?'",
                    "Questions distributed across the room, not just to eager volunteers"
                ],
                exemplarPhrases: [
                    "Everyone, show me your answer on your whiteboard",
                    "I'm going to call on someone — everyone should be ready",
                    "What makes you think that? Tell me more",
                    "Can you give me an example?",
                    "On the count of three, everyone say the answer"
                ]
            ),

            // Principle 4: Provide Models
            Technique(
                id: "rosenshine-4",
                name: "Models and Worked Examples",
                category: .instruction,
                description: "Provide models and worked examples that make expert thinking visible. The verbal signature is think-aloud narration — the teacher externalizes their internal decision-making process ('When I see this, I ask myself...'), shows the complete path including dead ends, and names the strategy being used. Multiple examples before practice is key; a single example followed by 'Now you try' signals insufficient modeling.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 4,
                lookFors: [
                    "Think-aloud narration: 'I'm noticing... so I'm going to...'",
                    "Decision points made explicit: 'Here's where I have to choose between...'",
                    "Multiple examples shown before releasing to practice",
                    "Both correct process and common errors demonstrated",
                    "Strategy named explicitly: 'The strategy I'm using here is called...'"
                ],
                exemplarPhrases: [
                    "Watch my thinking as I work through this — I'm going to narrate what I'm doing",
                    "When I see this type of problem, I first ask myself...",
                    "Here's where most people get tripped up — notice what I do instead",
                    "Let me show you one more example before you try",
                    "The strategy I just used is called X. You'll use it in your practice"
                ]
            ),

            // Principle 5: Guide Practice
            Technique(
                id: "rosenshine-5",
                name: "Guided Practice",
                category: .engagement,
                description: "Work through problems collaboratively with high levels of teacher support before releasing to independent work. The verbal signature is shared cognitive labor — the teacher and students alternate turns on the same problem ('I'll start, you continue'), with the teacher providing real-time prompts and cues. The ratio of teacher-to-student contribution decreases across the practice sequence.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 5,
                lookFors: [
                    "Teacher and students co-construct solutions: 'I'll do the first step, you do the next'",
                    "Prompts and cues provided in real time during practice",
                    "Errors corrected immediately with explanation",
                    "Teacher contribution decreases across successive problems",
                    "Success rate is high — students aren't struggling alone"
                ],
                exemplarPhrases: [
                    "Let's do this one together. What should our first step be?",
                    "I'll start, then you continue from here",
                    "Good start — now what comes next?",
                    "Almost — remember to check for X before you move on",
                    "You're taking over more of the work now. That's the goal."
                ]
            ),

            // Principle 6: Check for Understanding
            Technique(
                id: "rosenshine-6",
                name: "Check for Understanding",
                category: .feedback,
                description: "Frequently verify student understanding using techniques that require responses from all students, then adjust instruction based on results. The verbal signature is the check-adjust cycle — the teacher pauses, samples understanding from multiple students, and either proceeds or reteaches based on what they find. Checking one volunteer and moving on is insufficient; the key is sampling breadth.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 6,
                lookFors: [
                    "Comprehension checks embedded throughout, not just at lesson end",
                    "All students required to respond, not just volunteers",
                    "Teacher acts on the data: 'I'm seeing confusion, so let me re-explain'",
                    "Multiple checking methods: whiteboards, thumbs, turn-and-talk, exit tickets",
                    "Reteaching occurs when understanding is below threshold"
                ],
                exemplarPhrases: [
                    "Before we continue, show me thumbs — got it, sort of, or lost?",
                    "Write your answer on your whiteboard and hold it up",
                    "I'm seeing about half of you have this. Let me come at it differently",
                    "Turn to your partner and explain the concept. I'm going to listen in",
                    "Based on your exit tickets, we need to revisit X tomorrow"
                ]
            ),

            // Principle 7: Obtain High Success Rate
            Technique(
                id: "rosenshine-7",
                name: "High Success Rate",
                category: .feedback,
                description: "Ensure students achieve approximately 80% success during initial learning to build confidence and automaticity before increasing difficulty. The verbal signature is calibration language — the teacher monitors difficulty in real time and names adjustments ('This is too big a jump — let me add a middle step'). Struggling students get more scaffolding, not just encouragement.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 7,
                lookFors: [
                    "Teacher monitors success rate and adjusts difficulty: 'Let me make this more accessible'",
                    "Scaffolding added when struggle exceeds productive level",
                    "Success acknowledged with specificity, not just cheerleading",
                    "Pace allows mastery before progression — no rushing past confusion",
                    "Struggling students receive additional support, not just repeated instructions"
                ],
                exemplarPhrases: [
                    "Most of you are getting this — let's try a harder one",
                    "I can see this is too big a jump. Let me add a step in between",
                    "You've got this — look at how many you answered correctly",
                    "If you're finding this too difficult, try the version with the scaffolds first",
                    "I want everyone to feel successful before we increase the challenge"
                ]
            ),

            // Principle 8: Provide Scaffolds
            Technique(
                id: "rosenshine-8",
                name: "Scaffolds for Difficult Tasks",
                category: .differentiation,
                description: "Provide temporary supports for complex tasks, then systematically remove them as students gain proficiency. The verbal signature is the scaffold-and-fade pattern — the teacher names the support being provided ('I'm giving you sentence starters to get you going'), monitors when it's no longer needed, and explicitly removes it ('Now try without the graphic organizer'). Permanent scaffolds that never fade are crutches, not scaffolds.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 8,
                lookFors: [
                    "Scaffolds named explicitly: 'This graphic organizer is a temporary support'",
                    "Supports matched to task difficulty, not applied uniformly",
                    "Fading language: 'This time, try it without the sentence starters'",
                    "Checklists, templates, or sentence frames provided and then removed",
                    "Teacher monitors readiness for scaffold removal"
                ],
                exemplarPhrases: [
                    "Use this checklist to guide you — we'll remove it once you're confident",
                    "Here's a sentence starter to get you going",
                    "This time, try it without the graphic organizer",
                    "The scaffold is there if you need it, but see if you can work without it first",
                    "You don't need the word bank anymore — you've internalized these terms"
                ]
            ),

            // Principle 9: Independent Practice
            Technique(
                id: "rosenshine-9",
                name: "Independent Practice",
                category: .engagement,
                description: "Require and monitor independent practice to develop automaticity. The verbal signature is the release with monitoring — the teacher explicitly transitions to independent work ('Now it's your turn — I'll be circulating'), checks in with individual students, and provides brief corrective feedback during practice. Silent, unmonitored seatwork is not independent practice in Rosenshine's framework.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 9,
                lookFors: [
                    "Explicit transition to independent work after guided practice",
                    "Teacher circulates and checks individual student work",
                    "Brief corrective feedback given during practice, not just at the end",
                    "Practice is purposeful and connected to the lesson objective",
                    "Students work without teacher assistance on the core task"
                ],
                exemplarPhrases: [
                    "Now it's your turn. I'll be walking around to check your work",
                    "If you get stuck, try using the strategy we just practiced together",
                    "I see you used the right approach here — keep going",
                    "Practice until this feels automatic",
                    "I noticed an error in step two — look at it again"
                ]
            ),

            // Principle 10: Weekly and Monthly Review
            Technique(
                id: "rosenshine-10",
                name: "Spaced Review",
                category: .instruction,
                description: "Engage students in weekly and monthly review to ensure long-term retention through spaced retrieval practice. The verbal signature is temporal reference language — the teacher explicitly connects current content to material from weeks or months ago ('Remember in September when we...'), and structures retrieval tasks that require pulling from long-term memory rather than recent short-term memory.",
                frameworkId: TeachingFramework.rosenshine.rawValue,
                sortOrder: 10,
                lookFors: [
                    "Temporal references to material from weeks/months ago: 'Back in October...'",
                    "Retrieval tasks require recall, not just recognition or re-reading",
                    "Cumulative questions that span multiple units",
                    "Connections drawn across topics and time periods",
                    "Spaced practice structured intentionally, not just end-of-unit review"
                ],
                exemplarPhrases: [
                    "Let's go back to what we learned three weeks ago — without your notes",
                    "This quiz covers material from the whole semester, not just this week",
                    "How does what we're learning now connect to our October unit?",
                    "Remember when we studied X? That's exactly what's happening here",
                    "Pull out your retrieval practice sheet — let's see what you remember"
                ]
            )
        ]
    }

    /// Returns the default enabled technique IDs for Rosenshine
    static var defaultEnabledIds: [String] {
        createTechniques().map { $0.id }
    }
}
