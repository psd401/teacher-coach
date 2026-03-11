import Foundation

/// Behavior Support Strategies technique definitions
/// Focused on proactive and responsive strategies teachers can implement
/// immediately to support student behavior and classroom management.
/// These are practical, next-day strategies — not FBAs or deep interventions.
struct BehaviorSupportTechniques {
    static func createTechniques() -> [Technique] {
        [
            Technique(
                id: "behavior-routines",
                name: "Proactive Routines & Expectations",
                category: .management,
                description: "Establishing clear, consistent routines with verbal cues so students know what to expect at every transition. The verbal signature is economy and predictability — the same short phrases used the same way every time. When routines are strong, behavior issues decrease because ambiguity disappears.",
                frameworkId: TeachingFramework.behaviorSupport.rawValue,
                sortOrder: 1,
                lookFors: [
                    "Consistent verbal cues for transitions: same phrase each time",
                    "Expectations stated before activities begin, not after problems arise",
                    "Routines referenced by name: 'Do our hallway protocol'",
                    "Students follow routines without repeated reminders",
                    "Teacher narrates compliance rather than non-compliance: 'I see table 3 is ready'"
                ],
                exemplarPhrases: [
                    "Before we start, here's what this looks like and sounds like",
                    "You know the routine — materials out, voices off, eyes on me",
                    "I see table 3 is ready. Table 1 is almost there",
                    "Same procedure as yesterday. You know what to do",
                    "Let's reset. What does our routine say comes next?"
                ]
            ),
            Technique(
                id: "behavior-environment",
                name: "Environmental Arrangement",
                category: .management,
                description: "Strategic use of physical proximity, room layout, and positioning to prevent behavior issues before they start. The verbal signature is minimal — effective environmental management reduces the need for verbal corrections. When the teacher does speak, it is brief positioning language or proximity cues.",
                frameworkId: TeachingFramework.behaviorSupport.rawValue,
                sortOrder: 2,
                lookFors: [
                    "Teacher circulates during independent work rather than staying at the front",
                    "Proximity used to redirect without verbal correction",
                    "Seating adjusted proactively based on student needs",
                    "Materials arranged so students can access them without disruption",
                    "Teacher positions near potential disruption points during transitions"
                ],
                exemplarPhrases: [
                    "I'm going to walk around while you work",
                    "Let me come over and see how you're doing",
                    "I'm going to stand right here while we discuss this",
                    "Let's rearrange so everyone can see the board",
                    "I'll be circulating — raise a hand if you need me"
                ]
            ),
            Technique(
                id: "behavior-greeting",
                name: "Greeting & Connection",
                category: .engagement,
                description: "Positive first contact that sets the emotional tone for the class. Threshold greetings, personal check-ins, and brief connection moments build relational trust that prevents escalation later. The verbal signature is warmth and recognition — using names, noticing something specific, and signaling that each student is seen.",
                frameworkId: TeachingFramework.behaviorSupport.rawValue,
                sortOrder: 3,
                lookFors: [
                    "Students greeted individually by name at the door or start of class",
                    "Brief personal check-ins: 'How was your game last night?'",
                    "Positive tone established before any academic demands",
                    "Teacher notices and names something specific about the student",
                    "Students respond warmly, indicating established rapport"
                ],
                exemplarPhrases: [
                    "Good morning, Aiden. Glad you're here today",
                    "Hey, Sofia — how did that project turn out?",
                    "Welcome back. I saved your seat",
                    "I noticed you had a rough day yesterday. Fresh start today",
                    "It's good to see you. We've got some interesting work today"
                ]
            ),
            Technique(
                id: "behavior-specific-praise",
                name: "Specific Behavioral Praise",
                category: .feedback,
                description: "Naming the exact behavior being reinforced rather than offering generic praise. The verbal signature is precision — instead of 'Good job,' the teacher says exactly what the student did and why it matters. This clarity helps students replicate the behavior and signals expectations to the whole class.",
                frameworkId: TeachingFramework.behaviorSupport.rawValue,
                sortOrder: 4,
                lookFors: [
                    "Praise names the specific behavior: 'You waited your turn to speak'",
                    "Praise connects behavior to impact: 'That helped everyone hear the directions'",
                    "Ratio of specific to generic praise is high",
                    "Praise directed at effort and choices, not traits",
                    "Public praise used strategically to reinforce expectations for the group"
                ],
                exemplarPhrases: [
                    "I noticed you waited patiently for your turn — that shows respect for your classmates",
                    "You got right to work without being asked. That's self-management",
                    "Thank you for putting your materials away. That helps us transition smoothly",
                    "I see you chose to take a breath instead of reacting. That was a strong choice",
                    "You helped your partner without being asked. That's the kind of teamwork we need"
                ]
            ),
            Technique(
                id: "behavior-calm-redirect",
                name: "Calm Redirection",
                category: .management,
                description: "Low-key, non-escalating redirects that correct behavior without drawing attention or creating power struggles. The verbal signature is brevity, neutral tone, and a focus on what the student should be doing rather than what they are doing wrong. The best redirects are nearly invisible to the rest of the class.",
                frameworkId: TeachingFramework.behaviorSupport.rawValue,
                sortOrder: 5,
                lookFors: [
                    "Redirections are brief — one sentence or less",
                    "Focus on desired behavior, not the infraction: 'Eyes on your paper'",
                    "Neutral or warm tone maintained during redirects",
                    "Private redirects preferred over public call-outs",
                    "Teacher returns to instruction immediately after redirect without lingering"
                ],
                exemplarPhrases: [
                    "Eyes on your paper, please",
                    "Back to your seat — thank you",
                    "I need you with us right now",
                    "Check yourself against our expectations",
                    "Let's get back on track. You know what to do"
                ]
            ),
            Technique(
                id: "behavior-deescalation",
                name: "De-escalation Language",
                category: .management,
                description: "Using tone, volume, pacing, and specific language to reduce tension when a student is dysregulated or a situation is escalating. The verbal signature is a deliberate lowering of intensity — slower speech, quieter voice, validating language, and offering a way forward rather than issuing ultimatums.",
                frameworkId: TeachingFramework.behaviorSupport.rawValue,
                sortOrder: 6,
                lookFors: [
                    "Teacher lowers voice volume when student escalates",
                    "Pacing slows during tense moments — deliberate pauses",
                    "Validating language used: 'I can see this is frustrating'",
                    "Options offered instead of ultimatums: 'You can... or you can...'",
                    "Teacher avoids arguing, defending, or matching the student's intensity"
                ],
                exemplarPhrases: [
                    "I can see you're frustrated. Let's figure this out",
                    "I'm not going to argue about this. Here's what I can offer",
                    "Take a minute if you need it. I'll check back with you",
                    "I hear you. Let's talk about what we can do",
                    "You're not in trouble. I just want to help you get back on track"
                ]
            ),
            Technique(
                id: "behavior-choice",
                name: "Choice & Autonomy",
                category: .management,
                description: "Offering managed choices that maintain dignity and give students a sense of control within clear boundaries. The verbal signature is framing two acceptable options rather than issuing a single demand. This reduces power struggles because the student is deciding, not simply complying.",
                frameworkId: TeachingFramework.behaviorSupport.rawValue,
                sortOrder: 7,
                lookFors: [
                    "Two acceptable options offered: 'You can work here or at the back table'",
                    "Choices framed positively, not as threats",
                    "Student agency acknowledged: 'It's your call'",
                    "Boundaries clear within the choices offered",
                    "Teacher accepts student's choice without judgment"
                ],
                exemplarPhrases: [
                    "You can work here or at the back table — your choice",
                    "Would you like to start with the reading or the questions?",
                    "You can take a break now or finish this section first. Up to you",
                    "I'll give you two options. You decide which works better for you",
                    "You get to choose how you show me you understand this"
                ]
            ),
            Technique(
                id: "behavior-momentum",
                name: "Group Momentum & Acknowledgment",
                category: .engagement,
                description: "Maintaining instructional pace and collectively acknowledging group effort to sustain engagement. The verbal signature is pacing language that keeps energy up and group praise that reinforces collective norms. When momentum stalls, behavior issues fill the gap — this technique keeps the class moving.",
                frameworkId: TeachingFramework.behaviorSupport.rawValue,
                sortOrder: 8,
                lookFors: [
                    "Brisk pacing maintained — no dead time between activities",
                    "Group effort acknowledged: 'This class is locked in today'",
                    "Transition speed praised: 'That was our fastest transition yet'",
                    "Energy matched to the task — teacher adjusts pace to maintain focus",
                    "Collective language used: 'we,' 'our class,' 'as a team'"
                ],
                exemplarPhrases: [
                    "We are moving today. Keep it up",
                    "This class is locked in. I can feel the focus",
                    "That was our fastest transition yet. Well done, everyone",
                    "We're on a roll — let's keep this momentum going",
                    "Every single person is working right now. That's what this class is about"
                ]
            ),
            Technique(
                id: "behavior-restorative",
                name: "Restorative Check-ins",
                category: .management,
                description: "Brief private conversations after behavioral incidents that rebuild the relationship and plan forward. The verbal signature is curiosity over judgment — asking what happened from the student's perspective, naming the impact, and collaborating on a plan. These conversations prevent repeat incidents by addressing root causes.",
                frameworkId: TeachingFramework.behaviorSupport.rawValue,
                sortOrder: 9,
                lookFors: [
                    "Private conversation initiated after the student has calmed down",
                    "Teacher asks for the student's perspective: 'Tell me what happened'",
                    "Impact named without blame: 'When that happened, it made it hard for others to focus'",
                    "Collaborative planning: 'What can we do differently next time?'",
                    "Relationship repaired: conversation ends on a positive or neutral note"
                ],
                exemplarPhrases: [
                    "Can we talk for a minute? I want to hear your side",
                    "Tell me what happened from your perspective",
                    "When that happened, it made it hard for your classmates to focus. Do you see that?",
                    "What can we do differently next time so this doesn't happen again?",
                    "We're good. Tomorrow is a fresh start"
                ]
            ),
            Technique(
                id: "behavior-reset",
                name: "Next-Day Reset",
                category: .management,
                description: "Planning tomorrow's approach based on today's patterns. The verbal signature is forward-looking — communicating to students that each day is a clean slate while privately adjusting strategies based on what did and didn't work. This technique is about the teacher's planning mindset as much as student-facing language.",
                frameworkId: TeachingFramework.behaviorSupport.rawValue,
                sortOrder: 10,
                lookFors: [
                    "Teacher communicates fresh start: 'New day, clean slate'",
                    "No references to yesterday's incidents as leverage or threat",
                    "Adjusted seating, grouping, or routines based on previous day's patterns",
                    "Proactive check-in with students who had a rough day",
                    "Teacher's plan reflects lessons learned from the previous session"
                ],
                exemplarPhrases: [
                    "New day. I'm glad you're here",
                    "Yesterday was yesterday. Today we start fresh",
                    "I thought about what happened and I have an idea that might help",
                    "I moved some things around today to set us up better",
                    "I want to check in with you before we get started"
                ]
            )
        ]
    }

    /// Returns the default enabled technique IDs for Behavior Support
    static var defaultEnabledIds: [String] {
        createTechniques().map { $0.id }
    }
}
