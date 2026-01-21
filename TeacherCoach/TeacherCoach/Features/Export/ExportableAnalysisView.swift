import SwiftUI
import SwiftData

/// Print-optimized view for PDF export
/// Simplified version of AnalysisFeedbackView without interactive elements
struct ExportableAnalysisView: View {
    let analysis: Analysis
    let recording: Recording
    let configuration: ExportConfiguration

    // Letter-size paper dimensions in points (8.5 x 11 inches)
    static let pageWidth: CGFloat = 612
    static let pageHeight: CGFloat = 792
    static let margin: CGFloat = 36

    private var selectedTechniques: [TechniqueEvaluation] {
        (analysis.techniqueEvaluations ?? []).filter { configuration.includedTechniqueIds.contains($0.id) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            headerSection

            Divider()

            // Summary
            if configuration.includeSummary {
                summarySection
            }

            // Strengths and Growth Areas
            if configuration.includeStrengths || configuration.includeGrowthAreas {
                HStack(alignment: .top, spacing: 16) {
                    if configuration.includeStrengths {
                        strengthsSection
                    }
                    if configuration.includeGrowthAreas {
                        growthAreasSection
                    }
                }
            }

            // Technique Evaluations
            if !selectedTechniques.isEmpty {
                techniquesSection
            }

            // Next Steps
            if configuration.includeNextSteps {
                nextStepsSection
            }

            Spacer(minLength: 0)
        }
        .padding(Self.margin)
        .frame(width: Self.pageWidth, alignment: .topLeading)
        .background(Color.white)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recording.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.black)

            HStack(spacing: 16) {
                Label(recording.formattedDuration, systemImage: "clock")
                Label {
                    Text(recording.createdAt, format: .dateTime.month().day().year())
                } icon: {
                    Image(systemName: "calendar")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.gray)
        }
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Summary", systemImage: "doc.text")
                .font(.headline)
                .foregroundStyle(.black)

            Text(analysis.overallSummary)
                .font(.body)
                .foregroundStyle(.black)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Strengths Section

    private var strengthsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Strengths", systemImage: "star.fill")
                .font(.headline)
                .foregroundStyle(.green)

            ForEach(analysis.strengths, id: \.self) { strength in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)

                    Text(strength)
                        .font(.body)
                        .foregroundStyle(.black)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Growth Areas Section

    private var growthAreasSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Growth Areas", systemImage: "arrow.up.right")
                .font(.headline)
                .foregroundStyle(.orange)

            ForEach(analysis.growthAreas, id: \.self) { area in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(.orange)
                        .font(.caption)

                    Text(area)
                        .font(.body)
                        .foregroundStyle(.black)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Techniques Section

    private var techniquesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Technique Feedback", systemImage: "list.bullet.clipboard")
                .font(.headline)
                .foregroundStyle(.black)

            ForEach(selectedTechniques) { technique in
                techniqueCard(technique)
            }
        }
    }

    private func techniqueCard(_ technique: TechniqueEvaluation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(technique.techniqueName)
                    .font(.headline)
                    .foregroundStyle(.black)

                Spacer()

                if analysis.ratingsIncluded, let rating = technique.rating {
                    exportRatingBadge(rating: rating)
                }
            }

            if !technique.wasObserved {
                Text("Not observed")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            // Feedback
            Text(technique.feedback)
                .font(.body)
                .foregroundStyle(.black)

            // Evidence
            if !technique.evidence.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Evidence")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)

                    ForEach(technique.evidence, id: \.self) { item in
                        Text("\"\(item)\"")
                            .font(.callout)
                            .italic()
                            .foregroundStyle(.gray)
                            .padding(.leading, 8)
                    }
                }
            }

            // Suggestions
            if !technique.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suggestions")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)

                    ForEach(technique.suggestions, id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb")
                                .foregroundStyle(.yellow)
                                .font(.caption)

                            Text(suggestion)
                                .font(.callout)
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func exportRatingBadge(rating: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(index <= rating ? ratingColor(rating) : .gray.opacity(0.3))
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(ratingColor(rating).opacity(0.1))
        .clipShape(Capsule())
    }

    private func ratingColor(_ rating: Int) -> Color {
        switch rating {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .blue
        default: return .gray
        }
    }

    // MARK: - Next Steps Section

    private var nextStepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Next Steps", systemImage: "arrow.right.circle.fill")
                .font(.headline)
                .foregroundStyle(.blue)

            ForEach(Array(analysis.actionableNextSteps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 20, height: 20)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Circle())

                    Text(step)
                        .font(.body)
                        .foregroundStyle(.black)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    let analysis = Analysis(
        overallSummary: "This was an engaging math lesson with strong use of questioning techniques.",
        modelUsed: "claude-opus-4-5-20251101",
        strengths: ["Consistent use of wait time", "Effective positive framing"],
        growthAreas: ["More higher-order questioning", "Add check for understanding"],
        actionableNextSteps: ["Plan 2-3 higher-order questions", "Use exit tickets"]
    )

    let recording = Recording(
        title: "Math Lesson",
        duration: 1800,
        audioFilePath: "test.m4a",
        status: .complete
    )

    var config = ExportConfiguration()
    config.includedTechniqueIds = []

    return ExportableAnalysisView(
        analysis: analysis,
        recording: recording,
        configuration: config
    )
}
