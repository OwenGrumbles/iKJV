import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        let colors = themeManager.colors
        let theme = themeManager.currentTheme

        NavigationView {
            ZStack {
                colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Header description
                        Text("Choose your reading theme")
                            .font(.system(size: 14))
                            .foregroundStyle(colors.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        // Theme cards
                        VStack(spacing: 12) {
                            ForEach(AppTheme.allCases) { appTheme in
                                ThemeCard(
                                    appTheme: appTheme,
                                    isSelected: themeManager.currentTheme == appTheme,
                                    onSelect: {
                                        themeManager.setTheme(appTheme)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            dismiss()
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(colors.accent)
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Theme Card
struct ThemeCard: View {
    let appTheme: AppTheme
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var isPressed = false

    private var tc: ThemeColors { appTheme.colors }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // Preview area
                themePreview
                    .frame(height: 100)
                    .clipped()

                // Info row
                HStack(spacing: 12) {
                    Image(systemName: appTheme.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(tc.accent)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(appTheme.displayName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(tc.primaryText)
                        Text(themeDescription)
                            .font(.system(size: 12))
                            .foregroundStyle(tc.secondaryText)
                    }

                    Spacer()

                    // Selection indicator
                    ZStack {
                        Circle()
                            .strokeBorder(isSelected ? tc.accent : tc.borderColor, lineWidth: 2)
                            .frame(width: 24, height: 24)
                        if isSelected {
                            Circle()
                                .fill(tc.accent)
                                .frame(width: 14, height: 14)
                        }
                    }
                }
                .padding(16)
                .background(tc.surface)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        isSelected ? tc.accent : tc.borderColor.opacity(0.5),
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
            .shadow(
                color: isSelected ? tc.accent.opacity(0.2) : .black.opacity(0.15),
                radius: isSelected ? 12 : 4,
                y: 2
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.08)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.25)) { isPressed = false } }
        )
    }

    // MARK: - Theme Preview
    @ViewBuilder
    private var themePreview: some View {
        ZStack {
            tc.background

            VStack(alignment: .leading, spacing: 8) {
                // Simulated verse lines
                HStack(alignment: .top, spacing: 10) {
                    Text("16")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(tc.verseNumber)
                    Text("For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish,")
                        .font(.system(size: 12))
                        .foregroundStyle(tc.primaryText)
                        .lineLimit(2)
                }
                HStack(alignment: .top, spacing: 10) {
                    Text("17")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(tc.verseNumber)
                    Text("For God sent not his Son into the world to condemn the world;")
                        .font(.system(size: 12))
                        .foregroundStyle(tc.primaryText)
                        .lineLimit(1)
                }

                // Color swatches
                HStack(spacing: 6) {
                    ForEach(appTheme.previewColors.prefix(5), id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var themeDescription: String {
        switch appTheme {
        case .vsCodeRed:  return "Dark editor aesthetic, crimson accents"
        case .dracula:    return "Purple twilight, neon highlights"
        case .catppuccin: return "Warm mocha tones, pastel palette"
        case .gruvbox:    return "Retro earthy contrast, warm amber"
        }
    }
}
