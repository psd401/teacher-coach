import Foundation

/// Danielson Framework for Teaching technique definitions
/// Based on Charlotte Danielson's Framework for Teaching (2022 revision)
/// Focused on observable classroom components (Domains 2 and 3)
/// with verbal signatures optimized for transcript and video analysis
struct DanielsonTechniques {
    static func createTechniques() -> [Technique] {
        [
            // Domain 2: Classroom Environment

            Technique(
                id: "danielson-2a",
                name: "2a: Environment of Respect",
                category: .management,
                description: "Creating an environment of respect and rapport through teacher-student and student-student interactions. The verbal signature is warmth language — personal acknowledgment, active listening responses, and de-escalation through empathy rather than authority. At its best, students mirror the respectful tone unprompted.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 1,
                lookFors: [
                    "Teacher uses student names naturally and frequently",
                    "Active listening markers: 'I hear you,' 'Tell me more,' restating student ideas",
                    "De-escalation through empathy: 'I understand that's frustrating' vs. authority",
                    "Students use respectful language with peers without teacher prompting",
                    "Personal connections referenced: 'I remember you mentioned...'"
                ],
                exemplarPhrases: [
                    "Thank you for sharing that, Marcus — that took courage",
                    "I hear what you're saying. Tell me more about that",
                    "We can disagree and still respect each other's thinking",
                    "I remember you mentioned you like baseball — this is like that",
                    "I appreciate you listening so carefully to Jasmine's idea"
                ]
            ),
            Technique(
                id: "danielson-2b",
                name: "2b: Culture for Learning",
                category: .engagement,
                description: "Establishing a culture where the classroom conveys high expectations and genuine belief that all students can achieve. The verbal signature is the absence of hedging or lowered expectations, replaced by language that frames challenge as worthwhile and mistakes as productive. Students internalize this when they persist aloud through difficulty.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 2,
                lookFors: [
                    "Challenge framed as opportunity, not burden: 'This is hard and you're ready'",
                    "Mistakes reframed productively: 'That error tells us something useful'",
                    "Absence of ability-sorting language ('my low kids,' 'the smart group')",
                    "Students persist verbally through difficulty: 'I'm stuck but let me try...'",
                    "Content framed as important and worthy: 'This matters because...'"
                ],
                exemplarPhrases: [
                    "This is challenging work — and that's exactly why we're doing it",
                    "That mistake is actually helpful. What can we learn from it?",
                    "I know you can do this. Let's work through it together",
                    "Quality work means pushing past your first answer",
                    "This matters because it changes how you see the world"
                ]
            ),
            Technique(
                id: "danielson-2c",
                name: "2c: Managing Procedures",
                category: .management,
                description: "Managing classroom procedures so instructional time is maximized. The verbal signature is economy of language during transitions — brief, practiced cues that students respond to without elaboration. At the highest level, students manage transitions themselves and the teacher's procedural language nearly disappears.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 3,
                lookFors: [
                    "Transition cues are brief and practiced: single words or short phrases",
                    "Students respond to cues without needing repeated directions",
                    "Minimal instructional time lost — teacher doesn't re-explain routines",
                    "Students self-manage: distributing materials, forming groups without prompting",
                    "Countdown or signal language used consistently"
                ],
                exemplarPhrases: [
                    "Transition.",
                    "Materials managers.",
                    "You have 30 seconds — go.",
                    "Check the board for your next step",
                    "Same groups as yesterday. Begin."
                ]
            ),
            Technique(
                id: "danielson-2d",
                name: "2d: Managing Behavior",
                category: .management,
                description: "Managing student behavior through clear standards, preventive monitoring, and subtle interventions. The verbal signature is redirection that doesn't break instructional flow — proximity language, inclusive corrections ('I need everyone'), and private redirects rather than public call-outs. The most effective corrections are nearly invisible in transcript because they're woven into instruction.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 4,
                lookFors: [
                    "Redirections embedded in instruction rather than stopping to address behavior",
                    "Inclusive language: 'I need everyone's eyes' vs. naming individual offenders",
                    "Questions used as redirects: 'What should you be doing right now?'",
                    "Absence of threats, raised voice, or punitive language",
                    "Students self-correct after subtle cues"
                ],
                exemplarPhrases: [
                    "I need everyone tracking the speaker",
                    "I'm going to wait for all voices off",
                    "What should you be doing right now?",
                    "Remember our agreement about...",
                    "I notice some of us are ready. Just waiting on a few more."
                ]
            ),

            // Domain 3: Instruction

            Technique(
                id: "danielson-3a",
                name: "3a: Communicating with Students",
                category: .instruction,
                description: "Communicating content and expectations with clarity and precision. The verbal signature is explicit framing — learning targets stated as outcomes ('By the end, you will be able to...'), directions broken into numbered steps, and vocabulary defined in context rather than assumed. Vague language ('We're going to do some stuff with fractions') is a clear negative indicator.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 5,
                lookFors: [
                    "Learning targets stated as student outcomes, not activities",
                    "Directions given in numbered or sequenced steps",
                    "Vocabulary defined in context: 'This word means... in this context'",
                    "Connections to prior learning made explicit: 'Remember when we...'",
                    "Absence of vague language: 'stuff,' 'things,' 'kind of'"
                ],
                exemplarPhrases: [
                    "By the end of class, you'll be able to identify the theme and support it with evidence",
                    "Step one: read the passage. Step two: annotate for the author's claim. Step three: discuss with your partner",
                    "This word — 'synthesis' — means combining ideas to create something new",
                    "This connects to what we learned last week about...",
                    "Let me be precise about what I'm asking you to do"
                ]
            ),
            Technique(
                id: "danielson-3b",
                name: "3b: Questioning and Discussion",
                category: .questioning,
                description: "Using questioning and discussion to engage students in genuine thinking. The verbal signature is a high ratio of open-ended to closed questions, teacher talk time that decreases as discussion develops, and student-to-student exchanges that reference peers' ideas. The teacher's role shifts from questioner to facilitator — fewer teacher turns, longer student turns.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 6,
                lookFors: [
                    "Open-ended questions outnumber yes/no or recall questions",
                    "Teacher talk time decreases as discussion progresses",
                    "Students respond to each other, not just back to teacher",
                    "Probing follow-ups: 'What makes you think that?' 'Say more'",
                    "Wait time of 3+ seconds after questions"
                ],
                exemplarPhrases: [
                    "What makes you think that?",
                    "Can someone build on what Marcus just said?",
                    "Do you agree or disagree with that reasoning? Why?",
                    "Say more about that",
                    "Who has a different perspective?",
                    "I'm going to step back — talk to each other about this"
                ]
            ),
            Technique(
                id: "danielson-3c",
                name: "3c: Engaging Students",
                category: .engagement,
                description: "Engaging students in learning through intellectually challenging work and appropriate pacing. The verbal signature is cognitive demand language — tasks framed as problems to solve rather than procedures to follow, student choice in approach, and pacing adjustments voiced transparently. Disengagement shows up as silence, off-topic talk, or the teacher doing the thinking for students.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 7,
                lookFors: [
                    "Tasks framed as problems or questions, not just procedures",
                    "Student choice in approach or representation",
                    "Pacing adjustments voiced: 'I can see you need more time' or 'Let's pick up the pace'",
                    "Students explaining their reasoning without being asked to",
                    "Absence of teacher doing the cognitive work for students"
                ],
                exemplarPhrases: [
                    "You can show your understanding any way that makes sense to you",
                    "There are multiple valid approaches — which one will you try?",
                    "I can see you need more time with this. Let's extend by two minutes",
                    "Don't wait for me to tell you — what do you think the next step is?",
                    "How else might we represent this?"
                ]
            ),
            Technique(
                id: "danielson-3d",
                name: "3d: Using Assessment",
                category: .feedback,
                description: "Using assessment during instruction to monitor learning and provide actionable feedback. The verbal signature is the feedback loop — teacher checks understanding, names what's working and what to change, and student revises. Generic praise ('Good job') and grades-only feedback are negative indicators. Specific, improvement-oriented language is the hallmark.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 8,
                lookFors: [
                    "Feedback names specific strengths: 'Your claim is clear because...'",
                    "Feedback identifies specific next steps: 'Now add evidence that...'",
                    "Students act on feedback visibly (revision, retry, correction)",
                    "Multiple students checked, not just volunteers",
                    "Absence of grades-only or generic feedback ('Good,' 'Nice work')"
                ],
                exemplarPhrases: [
                    "Your claim is clear. Now connect your evidence more directly to it",
                    "Show me what you've got so far — I want to see your thinking",
                    "One thing that's working: your use of details. Next step: organize them by importance",
                    "Check your work against the success criteria. Where are you?",
                    "What feedback would you give yourself based on the rubric?"
                ]
            ),
            Technique(
                id: "danielson-3e",
                name: "3e: Flexibility and Responsiveness",
                category: .differentiation,
                description: "Adjusting instruction in real-time based on student cues. The verbal signature is the pivot — teacher notices confusion or a teachable moment and transparently shifts course mid-lesson. The language is metacognitive: 'I can see this isn't landing, so let me try a different approach.' Rigid adherence to a plan despite clear student struggle is a negative indicator.",
                frameworkId: TeachingFramework.danielson.rawValue,
                sortOrder: 9,
                lookFors: [
                    "Teacher voices the pivot: 'Let me try explaining this differently'",
                    "Teachable moments seized: 'Great question — let's explore that'",
                    "Instruction adjusts when checks reveal low understanding",
                    "Additional examples or representations offered spontaneously",
                    "Absence of plowing through material despite visible confusion"
                ],
                exemplarPhrases: [
                    "I can see this isn't clicking yet. Let me come at it from a different angle",
                    "That's a great question — let's pause and dig into that",
                    "Based on what I'm seeing, we need more practice before moving on",
                    "Let me show you another way to think about this",
                    "I'm going to adjust our plan because you need more time here"
                ]
            )
        ]
    }

    /// Returns the default enabled technique IDs for Danielson
    static var defaultEnabledIds: [String] {
        createTechniques().map { $0.id }
    }
}
