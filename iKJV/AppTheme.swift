import SwiftUI

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 128, 128, 128)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme Colors
struct ThemeColors {
    let background: Color
    let surface: Color
    let surfaceHighlight: Color
    let primaryText: Color
    let secondaryText: Color
    let accent: Color
    let accentSecondary: Color
    let highlight: Color
    let verseNumber: Color
    let glassAccent: Color
    let borderColor: Color
}

// MARK: - App Theme
enum AppTheme: String, CaseIterable, Identifiable {
    case vsCodeRed   = "VS Code Red"
    case dracula     = "Dracula"
    case catppuccin  = "Catppuccin"
    case gruvbox     = "Gruvbox"

    var id: String { rawValue }

    var colors: ThemeColors {
        switch self {

        case .vsCodeRed:
            return ThemeColors(
                background:       Color(hex: "1E1E1E"),
                surface:          Color(hex: "252526"),
                surfaceHighlight: Color(hex: "2D2D30"),
                primaryText:      Color(hex: "D4D4D4"),
                secondaryText:    Color(hex: "808080"),
                accent:           Color(hex: "F44747"),
                accentSecondary:  Color(hex: "569CD6"),
                highlight:        Color(hex: "CE9178"),
                verseNumber:      Color(hex: "4FC1FF"),
                glassAccent:      Color(hex: "F44747").opacity(0.25),
                borderColor:      Color(hex: "404040")
            )

        case .dracula:
            return ThemeColors(
                background:       Color(hex: "282A36"),
                surface:          Color(hex: "44475A"),
                surfaceHighlight: Color(hex: "6272A4"),
                primaryText:      Color(hex: "F8F8F2"),
                secondaryText:    Color(hex: "6272A4"),
                accent:           Color(hex: "FF79C6"),
                accentSecondary:  Color(hex: "BD93F9"),
                highlight:        Color(hex: "50FA7B"),
                verseNumber:      Color(hex: "FFB86C"),
                glassAccent:      Color(hex: "BD93F9").opacity(0.25),
                borderColor:      Color(hex: "6272A4")
            )

        case .catppuccin:
            return ThemeColors(
                background:       Color(hex: "1E1E2E"),
                surface:          Color(hex: "313244"),
                surfaceHighlight: Color(hex: "45475A"),
                primaryText:      Color(hex: "CDD6F4"),
                secondaryText:    Color(hex: "A6ADC8"),
                accent:           Color(hex: "CBA6F7"),
                accentSecondary:  Color(hex: "89B4FA"),
                highlight:        Color(hex: "FAB387"),
                verseNumber:      Color(hex: "F38BA8"),
                glassAccent:      Color(hex: "CBA6F7").opacity(0.25),
                borderColor:      Color(hex: "585B70")
            )

        case .gruvbox:
            return ThemeColors(
                background:       Color(hex: "282828"),
                surface:          Color(hex: "3C3836"),
                surfaceHighlight: Color(hex: "504945"),
                primaryText:      Color(hex: "EBDBB2"),
                secondaryText:    Color(hex: "A89984"),
                accent:           Color(hex: "FB4934"),
                accentSecondary:  Color(hex: "FABD2F"),
                highlight:        Color(hex: "B8BB26"),
                verseNumber:      Color(hex: "83A598"),
                glassAccent:      Color(hex: "FB4934").opacity(0.25),
                borderColor:      Color(hex: "665C54")
            )
        }
    }

    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .vsCodeRed:  return "chevron.left.forwardslash.chevron.right"
        case .dracula:    return "moon.stars.fill"
        case .catppuccin: return "pawprint.fill"
        case .gruvbox:    return "leaf.fill"
        }
    }

    var previewColors: [Color] {
        let c = colors
        return [c.background, c.surface, c.accent, c.accentSecondary, c.highlight]
    }
}

// MARK: - Glass Effect Modifier
struct ThemedGlassBackground: ViewModifier {
    let theme: AppTheme
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(theme.colors.glassAccent), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(theme.colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .strokeBorder(theme.colors.borderColor, lineWidth: 1)
                        )
                )
        }
    }
}

extension View {
    func themedGlass(_ theme: AppTheme, cornerRadius: CGFloat = 16) -> some View {
        modifier(ThemedGlassBackground(theme: theme, cornerRadius: cornerRadius))
    }
}

// MARK: - Themed Surface Modifier
struct ThemedSurface: ViewModifier {
    let theme: AppTheme
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(theme.colors.surface.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(theme.colors.borderColor.opacity(0.6), lineWidth: 0.5)
                    )
            )
    }
}

extension View {
    func themedSurface(_ theme: AppTheme, cornerRadius: CGFloat = 12) -> some View {
        modifier(ThemedSurface(theme: theme, cornerRadius: cornerRadius))
    }
}
