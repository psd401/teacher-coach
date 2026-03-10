import SwiftUI
import AppKit

// MARK: - PSD Logo

/// Loads the PSD logo from the app bundle resource
struct PSDLogoView: View {
    var size: CGFloat = 80

    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: "psd-logo", withExtension: "png"),
               let nsImage = NSImage(contentsOf: url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Fallback if image not found
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: size * 0.8))
                    .foregroundStyle(PSDTheme.accent)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - View Modifiers

extension View {
    /// Apply PSD card styling (keeps .regularMaterial, brand corner radius)
    func psdCard() -> some View {
        self
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// Apply PSD page background (Skylight)
    func psdPageBackground() -> some View {
        self.background(PSDTheme.pageBackground)
    }

    /// Apply PSD heading font (Josefin Sans Bold)
    func psdHeading(_ size: CGFloat = 17) -> some View {
        self.font(PSDFonts.heading(size: size))
    }

    /// Apply PSD body font (Josefin Slab)
    func psdBody(_ size: CGFloat = 14) -> some View {
        self.font(PSDFonts.body(size: size))
    }
}
