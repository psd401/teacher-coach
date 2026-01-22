import SwiftUI

/// A complete PDF page with header, content blocks, and footer
struct PDFPageView: View {
    let blocks: [PDFContentBlock]
    let pageNumber: Int
    let totalPages: Int
    let recordingDate: Date

    var body: some View {
        VStack(spacing: 0) {
            // Page header
            pageHeader
                .frame(height: PDFLayout.headerHeight)

            // Content area
            VStack(alignment: .leading, spacing: PDFLayout.blockSpacing) {
                ForEach(blocks) { block in
                    PDFBlockMeasurer.viewForBlock(block)
                }
                Spacer(minLength: 0)
            }
            .frame(height: PDFLayout.contentHeight, alignment: .top)

            // Page footer
            pageFooter
                .frame(height: PDFLayout.footerHeight)
        }
        .padding(PDFLayout.margin)
        .frame(width: PDFLayout.pageWidth, height: PDFLayout.pageHeight)
        .background(Color.white)
    }

    private var pageHeader: some View {
        HStack {
            Text("Teacher Coach")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)

            Spacer()

            Text(recordingDate, format: .dateTime.month().day().year())
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(.bottom, 8)
    }

    private var pageFooter: some View {
        HStack {
            Spacer()
            Text("Page \(pageNumber) of \(totalPages)")
                .font(.caption)
                .foregroundStyle(.gray)
            Spacer()
        }
        .padding(.top, 8)
    }
}
