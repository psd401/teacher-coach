import SwiftUI

/// Utility for measuring content block heights for PDF pagination
@MainActor
struct PDFBlockMeasurer {

    /// Measure the rendered height of a content block
    static func measureHeight(of block: PDFContentBlock) -> CGFloat {
        let view = viewForBlock(block)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 1.0  // Use 1.0 for measurement (faster)
        renderer.proposedSize = ProposedViewSize(
            width: PDFLayout.contentWidth,
            height: nil
        )

        guard let cgImage = renderer.cgImage else { return 0 }
        return CGFloat(cgImage.height)
    }

    /// Create the appropriate view for a content block
    @ViewBuilder
    static func viewForBlock(_ block: PDFContentBlock) -> some View {
        switch block {
        case .documentHeader(let title, let duration, let date):
            PDFDocumentHeaderView(title: title, duration: duration, date: date)

        case .summary(let text):
            PDFSummaryView(text: text)

        case .strengthsAndGrowth(let strengths, let growthAreas, let stacked):
            PDFStrengthsGrowthView(strengths: strengths, growthAreas: growthAreas, stacked: stacked)

        case .ratingLegend:
            PDFRatingLegendView()

        case .techniqueCard(let data):
            PDFTechniqueCardView(data: data)

        case .techniqueSuggestionsContinued(let name, let suggestions):
            PDFTechniqueSuggestionsContinuedView(techniqueName: name, suggestions: suggestions)

        case .nextSteps(let steps):
            PDFNextStepsView(steps: steps)
        }
    }

    /// Measure a technique card without suggestions (for split detection)
    static func measureTechniqueWithoutSuggestions(_ data: TechniqueCardData) -> CGFloat {
        let reducedData = data.withoutSuggestions()
        return measureHeight(of: .techniqueCard(reducedData))
    }

    /// Measure just the suggestions portion of a technique card
    static func measureSuggestionsContinued(techniqueName: String, suggestions: [String]) -> CGFloat {
        return measureHeight(of: .techniqueSuggestionsContinued(techniqueName: techniqueName, suggestions: suggestions))
    }
}
