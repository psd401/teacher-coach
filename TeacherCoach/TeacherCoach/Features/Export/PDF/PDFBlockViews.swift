import SwiftUI

// MARK: - Document Header Block

struct PDFDocumentHeaderView: View {
    let title: String
    let duration: String
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(PSDFonts.title)
                .foregroundStyle(Color.psdPacific)

            HStack(spacing: 16) {
                Label(duration, systemImage: "clock")
                Label {
                    Text(date, format: .dateTime.month().day().year())
                } icon: {
                    Image(systemName: "calendar")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.gray)
        }
        .frame(width: PDFLayout.contentWidth, alignment: .leading)
    }
}

// MARK: - Summary Block

struct PDFSummaryView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Summary", systemImage: "doc.text")
                .font(PSDFonts.headline)
                .foregroundStyle(Color.psdPacific)

            Text(text)
                .font(.body)
                .foregroundStyle(.black)
        }
        .padding()
        .frame(width: PDFLayout.contentWidth, alignment: .leading)
        .background(Color.psdSeaFoam)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Strengths and Growth Areas Block

struct PDFStrengthsGrowthView: View {
    let strengths: [String]
    let growthAreas: [String]
    let stacked: Bool

    var body: some View {
        Group {
            if stacked {
                VStack(alignment: .leading, spacing: 12) {
                    if !strengths.isEmpty {
                        strengthsSection
                    }
                    if !growthAreas.isEmpty {
                        growthAreasSection
                    }
                }
            } else {
                HStack(alignment: .top, spacing: 16) {
                    if !strengths.isEmpty {
                        strengthsSection
                    }
                    if !growthAreas.isEmpty {
                        growthAreasSection
                    }
                }
            }
        }
        .frame(width: PDFLayout.contentWidth, alignment: .leading)
    }

    private var strengthsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Strengths", systemImage: "star.fill")
                .font(PSDFonts.headline)
                .foregroundStyle(PSDTheme.strength)

            ForEach(strengths, id: \.self) { strength in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(PSDTheme.strength)
                        .font(.caption)

                    Text(strength)
                        .font(.body)
                        .foregroundStyle(.black)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PSDTheme.strength.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var growthAreasSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Growth Areas", systemImage: "arrow.up.right")
                .font(PSDFonts.headline)
                .foregroundStyle(PSDTheme.growth)

            ForEach(growthAreas, id: \.self) { area in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(PSDTheme.growth)
                        .font(.caption)

                    Text(area)
                        .font(.body)
                        .foregroundStyle(.black)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PSDTheme.growth.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Rating Legend Block

struct PDFRatingLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rating Scale")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.black)

            HStack(spacing: 8) {
                ForEach(RatingLevel.allCases, id: \.rawValue) { level in
                    VStack(alignment: .center, spacing: 4) {
                        HStack(spacing: 1) {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= level.rawValue ? "star.fill" : "star")
                                    .font(.system(size: 8))
                                    .foregroundStyle(index <= level.rawValue ? level.swiftUIColor : .gray.opacity(0.3))
                            }
                        }

                        Text(level.displayText)
                            .font(.system(size: 9))
                            .fontWeight(.medium)
                            .foregroundStyle(level.swiftUIColor)

                        Text(level.description)
                            .font(.system(size: 7))
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 95)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .frame(width: PDFLayout.contentWidth, alignment: .leading)
        .background(Color.psdSeaFoam)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Technique Card Block

struct PDFTechniqueCardView: View {
    let data: TechniqueCardData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(data.techniqueName)
                    .font(PSDFonts.headline)
                    .foregroundStyle(Color.psdPacific)

                Spacer()

                if data.ratingsIncluded, let rating = data.rating {
                    ratingBadge(rating: rating)
                }
            }

            if !data.wasObserved {
                Text("Not observed")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            // Feedback
            Text(data.feedback)
                .font(.body)
                .foregroundStyle(.black)

            // Evidence
            if !data.evidence.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Evidence")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)

                    ForEach(data.evidence, id: \.self) { item in
                        Text("\"\(item)\"")
                            .font(.callout)
                            .italic()
                            .foregroundStyle(.gray)
                            .padding(.leading, 8)
                    }
                }
            }

            // Suggestions
            if !data.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suggestions")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)

                    ForEach(data.suggestions, id: \.self) { suggestion in
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
        .frame(width: PDFLayout.contentWidth, alignment: .leading)
        .background(Color.psdSeaFoam)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func ratingBadge(rating: Int) -> some View {
        let color = PSDTheme.ratingColor(rating)
        return HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(index <= rating ? color : .gray.opacity(0.3))
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Technique Suggestions Continued Block

struct PDFTechniqueSuggestionsContinuedView: View {
    let techniqueName: String
    let suggestions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(techniqueName) (continued)")
                .font(PSDFonts.headline)
                .foregroundStyle(Color.psdPacific)

            VStack(alignment: .leading, spacing: 4) {
                Text("Suggestions")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)

                ForEach(suggestions, id: \.self) { suggestion in
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
        .padding()
        .frame(width: PDFLayout.contentWidth, alignment: .leading)
        .background(Color.psdSeaFoam)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Next Steps Block

struct PDFNextStepsView: View {
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Next Steps", systemImage: "arrow.right.circle.fill")
                .font(PSDFonts.headline)
                .foregroundStyle(PSDTheme.nextSteps)

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 20, height: 20)
                        .background(PSDTheme.nextSteps)
                        .foregroundStyle(.white)
                        .clipShape(Circle())

                    Text(step)
                        .font(.body)
                        .foregroundStyle(.black)
                }
            }
        }
        .padding()
        .frame(width: PDFLayout.contentWidth, alignment: .leading)
        .background(PSDTheme.nextSteps.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
