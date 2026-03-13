import SwiftUI

struct BibleDownloadView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var downloadManager: BibleDownloadManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        let colors = themeManager.colors
        let theme = themeManager.currentTheme

        NavigationView {
            ZStack {
                colors.background.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // Icon
                    ZStack {
                        Circle()
                            .fill(colors.accent.opacity(0.12))
                            .frame(width: 100, height: 100)
                        Image(systemName: iconName)
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(iconColor(colors: colors))
                    }
                    .animation(.spring(response: 0.4), value: downloadManager.phase)

                    // Title + subtitle
                    VStack(spacing: 10) {
                        Text(titleText)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                            .multilineTextAlignment(.center)

                        Text(subtitleText)
                            .font(.system(size: 14))
                            .foregroundStyle(colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    // Progress bar (only while downloading)
                    if case .downloading(let progress, let detail) = downloadManager.phase {
                        VStack(spacing: 10) {
                            ProgressView(value: progress)
                                .tint(colors.accent)
                                .padding(.horizontal, 40)

                            Text(detail)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(colors.secondaryText)
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    if case .saving = downloadManager.phase {
                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(colors.accent)
                            Text("Saving to device…")
                                .font(.system(size: 13))
                                .foregroundStyle(colors.secondaryText)
                        }
                    }

                    // Action button
                    actionButton(theme: theme, colors: colors)

                    Spacer()
                    Spacer()
                }
            }
            .navigationTitle("Download Bible")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if downloadManager.isIdle || downloadManager.isComplete || downloadManager.isFailed {
                        Button("Close") { dismiss() }
                            .foregroundStyle(colors.accent)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Action Button
    @ViewBuilder
    private func actionButton(theme: AppTheme, colors: ThemeColors) -> some View {
        switch downloadManager.phase {
        case .idle:
            Button {
                Task { await downloadManager.downloadFullBible() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 18))
                    Text("Download Full Bible")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            colors: [colors.accent, colors.accentSecondary],
                            startPoint: .leading, endPoint: .trailing))
                )
                .padding(.horizontal, 32)
            }
            .buttonStyle(.plain)

        case .downloading, .saving:
            // No button while in progress
            EmptyView()

        case .complete:
            Button {
                dismiss()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("Done — Start Reading")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colors.highlight)
                )
                .padding(.horizontal, 32)
            }
            .buttonStyle(.plain)

        case .failed:
            VStack(spacing: 12) {
                Button {
                    downloadManager.reset()
                    Task { await downloadManager.downloadFullBible() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Try Again")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(colors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(colors.accent.opacity(0.12)))
                    .padding(.horizontal, 32)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Dynamic text / icons
    private var iconName: String {
        switch downloadManager.phase {
        case .idle:                          return "arrow.down.circle"
        case .downloading, .saving:          return "arrow.down.circle.fill"
        case .complete:                      return "checkmark.circle.fill"
        case .failed:                        return "exclamationmark.triangle.fill"
        }
    }

    private func iconColor(colors: ThemeColors) -> Color {
        switch downloadManager.phase {
        case .idle:                          return colors.accent
        case .downloading, .saving:          return colors.accentSecondary
        case .complete:                      return colors.highlight
        case .failed:                        return colors.accent
        }
    }

    private var titleText: String {
        switch downloadManager.phase {
        case .idle:                          return "Download Full Bible"
        case .downloading:                   return "Downloading…"
        case .saving:                        return "Saving…"
        case .complete(let n):               return "\(n) Verses Loaded"
        case .failed:                        return "Download Failed"
        }
    }

    private var subtitleText: String {
        switch downloadManager.phase {
        case .idle:
            return "Get all 66 books, 1,189 chapters, and 31,102 verses — Genesis to Revelation. Requires an internet connection (~4 MB)."
        case .downloading(_, let detail):
            return detail
        case .saving:
            return "Writing verses to device…"
        case .complete:
            return "The complete King James Bible is now available offline."
        case .failed(let msg):
            return msg
        }
    }
}
