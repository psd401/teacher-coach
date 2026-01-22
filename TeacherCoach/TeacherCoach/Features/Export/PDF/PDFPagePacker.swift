import SwiftUI

/// Algorithm for packing content blocks into pages
@MainActor
struct PDFPagePacker {

    /// Pack blocks into pages, respecting content height limits
    /// - Parameters:
    ///   - blocks: Content blocks to pack
    ///   - maxHeight: Maximum height per page (defaults to PDFLayout.contentHeight)
    /// - Returns: Array of pages, each containing an array of blocks
    static func packIntoPages(
        blocks: [PDFContentBlock],
        maxHeight: CGFloat = PDFLayout.contentHeight
    ) -> [[PDFContentBlock]] {
        var pages: [[PDFContentBlock]] = []
        var currentPage: [PDFContentBlock] = []
        var currentHeight: CGFloat = 0

        for block in blocks {
            let result = tryAddBlock(
                block,
                toPage: &currentPage,
                currentHeight: &currentHeight,
                maxHeight: maxHeight,
                pages: &pages
            )

            // Handle any overflow blocks (continued suggestions)
            if let overflow = result.overflowBlock {
                // Start new page with overflow
                pages.append(currentPage)
                currentPage = [overflow]
                currentHeight = PDFBlockMeasurer.measureHeight(of: overflow)
            }
        }

        // Don't forget the last page
        if !currentPage.isEmpty {
            pages.append(currentPage)
        }

        return pages
    }

    private struct AddBlockResult {
        let added: Bool
        let overflowBlock: PDFContentBlock?
    }

    private static func tryAddBlock(
        _ block: PDFContentBlock,
        toPage currentPage: inout [PDFContentBlock],
        currentHeight: inout CGFloat,
        maxHeight: CGFloat,
        pages: inout [[PDFContentBlock]]
    ) -> AddBlockResult {
        let blockHeight = PDFBlockMeasurer.measureHeight(of: block)
        let spacing = currentPage.isEmpty ? 0 : PDFLayout.blockSpacing

        // Check if block fits on current page
        if currentHeight + spacing + blockHeight <= maxHeight {
            currentPage.append(block)
            currentHeight += spacing + blockHeight
            return AddBlockResult(added: true, overflowBlock: nil)
        }

        // Block doesn't fit - handle based on type
        if case .techniqueCard(let data) = block, !data.suggestions.isEmpty {
            // Try splitting technique card at suggestions boundary
            let splitResult = trySplitTechniqueCard(
                data: data,
                currentPage: &currentPage,
                currentHeight: &currentHeight,
                maxHeight: maxHeight
            )

            if splitResult.success {
                return AddBlockResult(added: true, overflowBlock: splitResult.overflowBlock)
            }
        }

        // Can't split or not a technique card - start new page
        if !currentPage.isEmpty {
            pages.append(currentPage)
        }
        currentPage = [block]
        currentHeight = blockHeight

        // Check if single block exceeds page height (rare edge case)
        if blockHeight > maxHeight {
            // Log warning but allow it - will overflow page
            print("[PDFPagePacker] Warning: Block exceeds page height (\(blockHeight) > \(maxHeight))")
        }

        return AddBlockResult(added: true, overflowBlock: nil)
    }

    private struct SplitResult {
        let success: Bool
        let overflowBlock: PDFContentBlock?
    }

    private static func trySplitTechniqueCard(
        data: TechniqueCardData,
        currentPage: inout [PDFContentBlock],
        currentHeight: inout CGFloat,
        maxHeight: CGFloat
    ) -> SplitResult {
        // Measure card without suggestions
        let cardWithoutSuggestions = data.withoutSuggestions()
        let cardHeight = PDFBlockMeasurer.measureHeight(of: .techniqueCard(cardWithoutSuggestions))
        let spacing = currentPage.isEmpty ? 0 : PDFLayout.blockSpacing

        // Check if feedback+evidence fits on current page
        if currentHeight + spacing + cardHeight <= maxHeight {
            // Add card without suggestions
            currentPage.append(.techniqueCard(cardWithoutSuggestions))
            currentHeight += spacing + cardHeight

            // Create overflow block for suggestions
            let overflow = PDFContentBlock.techniqueSuggestionsContinued(
                techniqueName: data.techniqueName,
                suggestions: data.suggestions
            )
            return SplitResult(success: true, overflowBlock: overflow)
        }

        // Card without suggestions still doesn't fit - can't split effectively
        return SplitResult(success: false, overflowBlock: nil)
    }
}
