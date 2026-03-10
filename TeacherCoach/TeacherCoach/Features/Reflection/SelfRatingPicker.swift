import SwiftUI

/// Reusable 1-5 star picker using the RatingLevel scale
struct SelfRatingPicker: View {
    let techniqueName: String
    @Binding var rating: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(techniqueName)
                .font(PSDFonts.headline)

            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { value in
                    Button {
                        rating = value
                    } label: {
                        Image(systemName: value <= rating ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundStyle(value <= rating ? PSDTheme.ratingColor(rating) : .secondary.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                if let level = RatingLevel(rawValue: rating) {
                    Text(level.displayText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(level.swiftUIColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(level.swiftUIColor.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }
}
