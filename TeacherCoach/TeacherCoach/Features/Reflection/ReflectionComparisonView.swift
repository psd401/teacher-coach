import SwiftUI

/// Side-by-side comparison of self-ratings vs AI ratings
struct ReflectionComparisonView: View {
    let reflection: Reflection
    let analysis: Analysis

    @State private var isExpanded = true

    private var techniqueEvaluations: [TechniqueEvaluation] {
        analysis.techniqueEvaluations ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Label("Self vs AI Comparison", systemImage: "chart.bar.doc.horizontal")
                        .font(PSDFonts.headline)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                // Reflection text summaries
                if !reflection.whatWentWell.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("What went well")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        Text(reflection.whatWentWell)
                            .font(.body)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(PSDTheme.strength.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                if !reflection.whatToChange.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("What to change")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        Text(reflection.whatToChange)
                            .font(.body)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(PSDTheme.growth.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Rating comparison table
                if analysis.ratingsIncluded && !reflection.selfRatings.isEmpty {
                    ratingComparisonTable
                }

                // Focus techniques
                if !reflection.focusTechniqueIds.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Focus Areas")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        ForEach(reflection.selfRatings.filter { reflection.focusTechniqueIds.contains($0.techniqueId) }) { rating in
                            Label(rating.techniqueName, systemImage: "target")
                                .font(.body)
                                .foregroundStyle(PSDTheme.nextSteps)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(PSDTheme.nextSteps.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .psdCard()
    }

    // MARK: - Rating Comparison Table

    private var ratingComparisonTable: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Column headers
            HStack {
                Text("Technique")
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Self")
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(width: 80, alignment: .center)

                Text("AI")
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(width: 80, alignment: .center)

                Text("Delta")
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(width: 50, alignment: .center)
            }
            .foregroundStyle(.secondary)

            Divider()

            // Rows
            ForEach(reflection.selfRatings) { selfRating in
                let aiRating = techniqueEvaluations.first(where: { $0.techniqueId == selfRating.techniqueId })?.rating

                HStack {
                    Text(selfRating.techniqueName)
                        .font(.caption)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Self-rating stars
                    CompactRatingStars(rating: selfRating.rating)
                        .frame(width: 80, alignment: .center)

                    // AI rating stars
                    if let aiRating = aiRating {
                        CompactRatingStars(rating: aiRating)
                            .frame(width: 80, alignment: .center)
                    } else {
                        Text("--")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 80, alignment: .center)
                    }

                    // Delta indicator
                    DeltaIndicator(selfRating: selfRating.rating, aiRating: aiRating)
                        .frame(width: 50, alignment: .center)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Compact Rating Stars

struct CompactRatingStars: View {
    let rating: Int

    var body: some View {
        HStack(spacing: 1) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: 8))
                    .foregroundStyle(index <= rating ? PSDTheme.ratingColor(rating) : .secondary.opacity(0.3))
            }
        }
    }
}

// MARK: - Delta Indicator

struct DeltaIndicator: View {
    let selfRating: Int
    let aiRating: Int?

    private var delta: Int? {
        guard let aiRating = aiRating else { return nil }
        return selfRating - aiRating
    }

    var body: some View {
        if let delta = delta {
            HStack(spacing: 2) {
                if delta > 0 {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 8))
                    Text("+\(delta)")
                        .font(.caption2)
                } else if delta < 0 {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 8))
                    Text("\(delta)")
                        .font(.caption2)
                } else {
                    Image(systemName: "equal")
                        .font(.system(size: 8))
                    Text("0")
                        .font(.caption2)
                }
            }
            .foregroundStyle(deltaColor)
        } else {
            Text("--")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var deltaColor: Color {
        guard let delta = delta else { return .secondary }
        if delta > 0 { return .orange }   // Self-rated higher than AI
        if delta < 0 { return PSDTheme.accent }  // AI rated higher
        return PSDTheme.strength  // Match
    }
}
