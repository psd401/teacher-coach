import AppKit
import SwiftUI
import SwiftData

/// Service for exporting analysis to PDF and Markdown formats
@MainActor
final class ExportService {

    enum ExportError: LocalizedError {
        case pdfGenerationFailed
        case saveCancelled
        case fileWriteFailed(Error)

        var errorDescription: String? {
            switch self {
            case .pdfGenerationFailed:
                return "Failed to generate PDF"
            case .saveCancelled:
                return "Export cancelled"
            case .fileWriteFailed(let error):
                return "Failed to save file: \(error.localizedDescription)"
            }
        }
    }

    /// Export analysis to the selected format
    func export(
        analysis: Analysis,
        recording: Recording,
        configuration: ExportConfiguration
    ) async throws -> URL {
        switch configuration.format {
        case .pdf:
            return try await exportPDF(analysis: analysis, recording: recording, configuration: configuration)
        case .markdown:
            return try await exportMarkdown(analysis: analysis, recording: recording, configuration: configuration)
        }
    }

    // MARK: - PDF Export

    private func exportPDF(
        analysis: Analysis,
        recording: Recording,
        configuration: ExportConfiguration
    ) async throws -> URL {
        // Build content blocks from configuration
        let blocks = buildContentBlocks(
            analysis: analysis,
            recording: recording,
            configuration: configuration
        )

        // Pack blocks into pages
        let pageContents = PDFPagePacker.packIntoPages(blocks: blocks)
        let totalPages = max(pageContents.count, 1)

        // Create PDF context
        let pdfData = NSMutableData()
        let pageRect = CGRect(
            x: 0,
            y: 0,
            width: PDFLayout.pageWidth,
            height: PDFLayout.pageHeight
        )

        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
              let pdfContext = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            throw ExportError.pdfGenerationFailed
        }

        // Render each page
        for (index, pageBlocks) in pageContents.enumerated() {
            let pageView = PDFPageView(
                blocks: pageBlocks,
                pageNumber: index + 1,
                totalPages: totalPages,
                recordingDate: recording.createdAt
            )

            let renderer = ImageRenderer(content: pageView)
            renderer.scale = PDFLayout.rendererScale

            guard let cgImage = renderer.cgImage else {
                throw ExportError.pdfGenerationFailed
            }

            // Scale image to fit page dimensions
            var mediaBox = pageRect
            pdfContext.beginPDFPage([kCGPDFContextMediaBox as String: NSValue(rect: mediaBox)] as CFDictionary)
            pdfContext.draw(cgImage, in: pageRect)
            pdfContext.endPDFPage()
        }

        pdfContext.closePDF()

        // Present save panel
        let defaultFilename = sanitizeFilename("\(recording.title)_Analysis.pdf")
        let url = try await presentSavePanel(defaultFilename: defaultFilename, allowedTypes: ["pdf"])

        // Write PDF to file
        do {
            try (pdfData as Data).write(to: url)
            return url
        } catch {
            throw ExportError.fileWriteFailed(error)
        }
    }

    /// Build content blocks from analysis and configuration
    private func buildContentBlocks(
        analysis: Analysis,
        recording: Recording,
        configuration: ExportConfiguration
    ) -> [PDFContentBlock] {
        var blocks: [PDFContentBlock] = []

        // Document header (always first)
        blocks.append(.documentHeader(
            title: recording.title,
            duration: recording.formattedDuration,
            date: recording.createdAt
        ))

        // Summary
        if configuration.includeSummary {
            blocks.append(.summary(text: analysis.overallSummary))
        }

        // Strengths and Growth Areas
        if configuration.includeStrengths || configuration.includeGrowthAreas {
            let strengths = configuration.includeStrengths ? analysis.strengths : []
            let growthAreas = configuration.includeGrowthAreas ? analysis.growthAreas : []

            // Measure side-by-side vs stacked to determine layout
            let sideBySideBlock = PDFContentBlock.strengthsAndGrowth(
                strengths: strengths,
                growthAreas: growthAreas,
                stacked: false
            )
            let sideBySideHeight = PDFBlockMeasurer.measureHeight(of: sideBySideBlock)

            // Use stacked layout if side-by-side would be too tall
            let useStacked = sideBySideHeight > PDFLayout.contentHeight * 0.4

            blocks.append(.strengthsAndGrowth(
                strengths: strengths,
                growthAreas: growthAreas,
                stacked: useStacked
            ))
        }

        // Technique cards (each as separate block)
        let selectedTechniques = (analysis.techniqueEvaluations ?? [])
            .filter { configuration.includedTechniqueIds.contains($0.id) }

        // Add rating legend before technique cards if ratings are included
        if !selectedTechniques.isEmpty && analysis.ratingsIncluded {
            blocks.append(.ratingLegend)
        }

        for technique in selectedTechniques {
            let data = TechniqueCardData(from: technique, ratingsIncluded: analysis.ratingsIncluded)
            blocks.append(.techniqueCard(data))
        }

        // Next steps
        if configuration.includeNextSteps && !analysis.actionableNextSteps.isEmpty {
            blocks.append(.nextSteps(analysis.actionableNextSteps))
        }

        return blocks
    }

    // MARK: - Markdown Export

    private func exportMarkdown(
        analysis: Analysis,
        recording: Recording,
        configuration: ExportConfiguration
    ) async throws -> URL {
        let markdown = generateMarkdown(analysis: analysis, recording: recording, configuration: configuration)

        // Present save panel
        let defaultFilename = sanitizeFilename("\(recording.title)_Analysis.md")
        let url = try await presentSavePanel(defaultFilename: defaultFilename, allowedTypes: ["md"])

        // Write markdown to file
        do {
            try markdown.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            throw ExportError.fileWriteFailed(error)
        }
    }

    private func generateMarkdown(
        analysis: Analysis,
        recording: Recording,
        configuration: ExportConfiguration
    ) -> String {
        var lines: [String] = []

        // Header
        lines.append("# \(recording.title)")
        lines.append("")
        lines.append("**Duration:** \(recording.formattedDuration)")
        lines.append("**Date:** \(formatDate(recording.createdAt))")
        lines.append("")
        lines.append("---")
        lines.append("")

        // Summary
        if configuration.includeSummary {
            lines.append("## Summary")
            lines.append("")
            lines.append(analysis.overallSummary)
            lines.append("")
        }

        // Strengths
        if configuration.includeStrengths && !analysis.strengths.isEmpty {
            lines.append("## Strengths")
            lines.append("")
            for strength in analysis.strengths {
                lines.append("- \(strength)")
            }
            lines.append("")
        }

        // Growth Areas
        if configuration.includeGrowthAreas && !analysis.growthAreas.isEmpty {
            lines.append("## Growth Areas")
            lines.append("")
            for area in analysis.growthAreas {
                lines.append("- \(area)")
            }
            lines.append("")
        }

        // Technique Feedback
        let selectedTechniques = (analysis.techniqueEvaluations ?? []).filter {
            configuration.includedTechniqueIds.contains($0.id)
        }

        if !selectedTechniques.isEmpty {
            lines.append("## Technique Feedback")
            lines.append("")

            // Rating legend if ratings are included
            if analysis.ratingsIncluded {
                lines.append("### Rating Scale")
                lines.append("")
                lines.append("| Rating | Level | Description |")
                lines.append("|--------|-------|-------------|")
                for level in RatingLevel.allCases {
                    let stars = String(repeating: "\u{2605}", count: level.rawValue) + String(repeating: "\u{2606}", count: 5 - level.rawValue)
                    lines.append("| \(stars) | \(level.displayText) | \(level.description) |")
                }
                lines.append("")
            }

            for technique in selectedTechniques {
                lines.append("### \(technique.techniqueName)")

                if analysis.ratingsIncluded, let rating = technique.rating {
                    lines.append("")
                    lines.append("**Rating:** \(String(repeating: "\u{2605}", count: rating))\(String(repeating: "\u{2606}", count: 5 - rating))")
                }

                if !technique.wasObserved {
                    lines.append("")
                    lines.append("*Not observed*")
                }

                lines.append("")
                lines.append(technique.feedback)

                if !technique.evidence.isEmpty {
                    lines.append("")
                    lines.append("**Evidence:**")
                    for evidence in technique.evidence {
                        lines.append("> \"\(evidence)\"")
                    }
                }

                if !technique.suggestions.isEmpty {
                    lines.append("")
                    lines.append("**Suggestions:**")
                    for suggestion in technique.suggestions {
                        lines.append("- \(suggestion)")
                    }
                }

                lines.append("")
            }
        }

        // Next Steps
        if configuration.includeNextSteps && !analysis.actionableNextSteps.isEmpty {
            lines.append("## Next Steps")
            lines.append("")
            for (index, step) in analysis.actionableNextSteps.enumerated() {
                lines.append("\(index + 1). \(step)")
            }
            lines.append("")
        }

        // Footer
        lines.append("---")
        lines.append("")
        lines.append("*Generated by Teacher Coach*")

        return lines.joined(separator: "\n")
    }

    // MARK: - Helpers

    private func presentSavePanel(defaultFilename: String, allowedTypes: [String]) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let panel = NSSavePanel()
            panel.nameFieldStringValue = defaultFilename
            panel.allowedContentTypes = allowedTypes.compactMap { ext in
                switch ext {
                case "pdf": return .pdf
                case "md": return .plainText
                default: return nil
                }
            }
            panel.canCreateDirectories = true
            panel.isExtensionHidden = false

            panel.begin { response in
                if response == .OK, let url = panel.url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: ExportError.saveCancelled)
                }
            }
        }
    }

    private func sanitizeFilename(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name.components(separatedBy: invalidCharacters).joined(separator: "_")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
