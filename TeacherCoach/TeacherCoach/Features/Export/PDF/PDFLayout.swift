import Foundation

/// Constants for PDF page layout (Letter size: 8.5 x 11 inches)
enum PDFLayout {
    /// Page width in points (8.5 inches)
    static let pageWidth: CGFloat = 612

    /// Page height in points (11 inches)
    static let pageHeight: CGFloat = 792

    /// Margin on all sides
    static let margin: CGFloat = 36

    /// Height reserved for page header
    static let headerHeight: CGFloat = 50

    /// Height reserved for page footer
    static let footerHeight: CGFloat = 30

    /// Spacing between content blocks
    static let blockSpacing: CGFloat = 12

    /// Available width for content (page width minus margins)
    static let contentWidth: CGFloat = pageWidth - (margin * 2)

    /// Available height for content per page (excluding header/footer)
    static let contentHeight: CGFloat = pageHeight - (margin * 2) - headerHeight - footerHeight

    /// Renderer scale for print quality
    static let rendererScale: CGFloat = 2.0
}
