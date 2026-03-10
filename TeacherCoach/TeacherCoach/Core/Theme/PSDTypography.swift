import SwiftUI
import CoreText

/// PSD brand typography using Josefin Sans (headings) and Josefin Slab (body)
enum PSDFonts {

    // MARK: - Font Registration

    /// Register custom fonts at app startup. Call once from TeacherCoachApp.init or .onAppear.
    static func registerFonts() {
        let fontNames = [
            "JosefinSans-Bold",
            "JosefinSlab-Regular",
            "JosefinSlab-Bold"
        ]

        for name in fontNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts") else {
                // Try without subdirectory (flat bundle)
                if let flatURL = Bundle.main.url(forResource: name, withExtension: "ttf") {
                    registerFont(at: flatURL)
                }
                continue
            }
            registerFont(at: url)
        }
    }

    private static func registerFont(at url: URL) {
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            if let err = error?.takeRetainedValue() {
                let desc = CFErrorCopyDescription(err) as String? ?? "unknown"
                // Font may already be registered — not fatal
                print("Font registration note: \(desc)")
            }
        }
    }

    // MARK: - Semantic Font Helpers

    /// Heading font: Josefin Sans Bold (>=17pt), falls back to system bold
    static func heading(size: CGFloat = 20) -> Font {
        if size >= 17 {
            return .custom("JosefinSans-Bold", size: size)
        }
        return .system(size: size, weight: .bold)
    }

    /// Body font: Josefin Slab Regular (>=12pt), falls back to system
    static func body(size: CGFloat = 14) -> Font {
        if size >= 12 {
            return .custom("JosefinSlab-Regular", size: size)
        }
        return .system(size: size)
    }

    /// Body bold font: Josefin Slab Bold (>=12pt), falls back to system bold
    static func bodyBold(size: CGFloat = 14) -> Font {
        if size >= 12 {
            return .custom("JosefinSlab-Bold", size: size)
        }
        return .system(size: size, weight: .bold)
    }

    /// Caption font: Always system font (Josefin has reduced legibility below 12pt)
    static func caption(size: CGFloat = 11) -> Font {
        .system(size: size)
    }

    /// Monospaced font for timer displays
    static func monospaced(size: CGFloat = 48) -> Font {
        .system(size: size, weight: .light, design: .monospaced)
    }

    // MARK: - SwiftUI Font Sizes (matching system semantic sizes)

    /// .largeTitle equivalent in Josefin Sans Bold
    static let largeTitle: Font = heading(size: 34)

    /// .title equivalent in Josefin Sans Bold
    static let title: Font = heading(size: 28)

    /// .title2 equivalent in Josefin Sans Bold
    static let title2: Font = heading(size: 22)

    /// .title3 equivalent in Josefin Slab Regular
    static let title3: Font = body(size: 20)

    /// .headline equivalent in Josefin Sans Bold
    static let headline: Font = heading(size: 17)

    /// .subheadline equivalent in Josefin Slab Regular
    static let subheadline: Font = body(size: 15)
}
