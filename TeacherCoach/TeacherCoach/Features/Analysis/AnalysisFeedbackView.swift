import SwiftUI

struct AnalysisFeedbackView: View {
    let analysis: Analysis

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Overall Summary
            SummarySection(summary: analysis.overallSummary)

            // Strengths and Growth Areas
            HStack(alignment: .top, spacing: 16) {
                StrengthsSection(strengths: analysis.strengths)
                GrowthAreasSection(growthAreas: analysis.growthAreas)
            }

            // Technique Evaluations
            if let evaluations = analysis.techniqueEvaluations, !evaluations.isEmpty {
                TechniqueEvaluationsSection(evaluations: evaluations, showRatings: analysis.ratingsIncluded)
            }

            // Actionable Next Steps
            NextStepsSection(steps: analysis.actionableNextSteps)
        }
    }
}

// MARK: - Summary Section

struct SummarySection: View {
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Summary", systemImage: "doc.text")
                .font(.headline)

            Text(summary)
                .font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Strengths Section

struct StrengthsSection: View {
    let strengths: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Strengths", systemImage: "star.fill")
                .font(.headline)
                .foregroundStyle(.green)

            ForEach(strengths, id: \.self) { strength in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)

                    Text(strength)
                        .font(.body)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Growth Areas Section

struct GrowthAreasSection: View {
    let growthAreas: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Growth Areas", systemImage: "arrow.up.right")
                .font(.headline)
                .foregroundStyle(.orange)

            ForEach(growthAreas, id: \.self) { area in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(.orange)
                        .font(.caption)

                    Text(area)
                        .font(.body)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Technique Evaluations Section

struct TechniqueEvaluationsSection: View {
    let evaluations: [TechniqueEvaluation]
    var showRatings: Bool = true

    @State private var expandedIds: Set<UUID> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Technique Feedback", systemImage: "list.bullet.clipboard")
                .font(.headline)

            ForEach(evaluations) { evaluation in
                TechniqueEvaluationCard(
                    evaluation: evaluation,
                    isExpanded: expandedIds.contains(evaluation.id),
                    showRatings: showRatings,
                    onToggle: {
                        withAnimation {
                            if expandedIds.contains(evaluation.id) {
                                expandedIds.remove(evaluation.id)
                            } else {
                                expandedIds.insert(evaluation.id)
                            }
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Technique Evaluation Card

struct TechniqueEvaluationCard: View {
    let evaluation: TechniqueEvaluation
    let isExpanded: Bool
    var showRatings: Bool = true
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button {
                onToggle()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(evaluation.techniqueName)
                            .font(.headline)

                        if !evaluation.wasObserved {
                            Text("Not observed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if showRatings, let rating = evaluation.rating {
                        RatingBadge(rating: rating)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Feedback
                    Text(evaluation.feedback)
                        .font(.body)

                    // Evidence
                    if !evaluation.evidence.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Evidence")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            ForEach(evaluation.evidence, id: \.self) { item in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\u{201C}")
                                        .foregroundStyle(.secondary)
                                    Text(item)
                                        .font(.callout)
                                        .italic()
                                    Text("\u{201D}")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.leading, 8)
                            }
                        }
                    }

                    // Suggestions
                    if !evaluation.suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Suggestions")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            ForEach(evaluation.suggestions, id: \.self) { suggestion in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "lightbulb")
                                        .foregroundStyle(.yellow)
                                        .font(.caption)

                                    Text(suggestion)
                                        .font(.callout)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Rating Badge

struct RatingBadge: View {
    let rating: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(index <= rating ? ratingColor : .secondary.opacity(0.3))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(ratingColor.opacity(0.1))
        .clipShape(Capsule())
    }

    private var ratingColor: Color {
        switch rating {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .blue
        default: return .gray
        }
    }
}

// MARK: - Next Steps Section

struct NextStepsSection: View {
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Next Steps", systemImage: "arrow.right.circle.fill")
                .font(.headline)
                .foregroundStyle(.blue)

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 20, height: 20)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(Circle())

                    Text(step)
                        .font(.body)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let analysis = Analysis(
        overallSummary: "This was an engaging math lesson with strong use of questioning techniques. The teacher demonstrated effective wait time and used specific praise to reinforce student learning.",
        modelUsed: "claude-opus-4-5-20251101",
        strengths: [
            "Consistent use of wait time after questions",
            "Effective positive framing for behavior management"
        ],
        growthAreas: [
            "Incorporate more higher-order questioning",
            "Add check for understanding strategies"
        ],
        actionableNextSteps: [
            "Plan 2-3 higher-order questions for each lesson segment",
            "Use exit tickets to check understanding at end of class"
        ]
    )

    return ScrollView {
        AnalysisFeedbackView(analysis: analysis)
            .padding()
    }
}
