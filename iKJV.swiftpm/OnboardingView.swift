import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var downloadManager: BibleDownloadManager
    @Binding var hasSeenOnboarding: Bool

    var body: some View {
        let colors = themeManager.colors
        let theme = themeManager.currentTheme

        ZStack {
            // Background
            LinearGradient(
                colors: [colors.background, colors.accent.opacity(0.1), colors.background],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App icon area
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [colors.accent.opacity(0.25), colors.accentSecondary.opacity(0.15)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 110, height: 110)
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: 52, weight: .medium))
                            .foregroundStyle(LinearGradient(
                                colors: [colors.accent, colors.accentSecondary],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                    .shadow(color: colors.accent.opacity(0.3), radius: 20)

                    VStack(spacing: 6) {
                        Text("iKJV")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(colors.primaryText)
                        Text("King James Bible")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(colors.secondaryText)
                            .tracking(3).textCase(.uppercase)
                    }
                }

                Spacer().frame(height: 48)

                // Info card
                VStack(spacing: 20) {
                    infoRow(
                        icon: "arrow.down.circle.fill",
                        color: colors.accent,
                        title: "Additional Data Required",
                        body: "To read the full Bible — all 66 books, Genesis to Revelation — please download the scripture data (~4 MB)."
                    )
                    infoRow(
                        icon: "wifi",
                        color: colors.accentSecondary,
                        title: "Internet Required Once",
                        body: "Downloaded once, then available completely offline — no account, no subscription."
                    )
                    infoRow(
                        icon: "paintbrush.fill",
                        color: colors.highlight,
                        title: "4 Beautiful Themes",
                        body: "VS Code Red, Dracula, Catppuccin, and Gruvbox — switch any time."
                    )
                }
                .padding(.horizontal, 32)

                Spacer().frame(height: 40)

                // Download button
                downloadButton(theme: theme, colors: colors)

                // Skip option
                Button {
                    hasSeenOnboarding = true
                } label: {
                    Text("Skip for now — browse available chapters")
                        .font(.system(size: 13))
                        .foregroundStyle(colors.secondaryText.opacity(0.7))
                        .underline()
                }
                .padding(.top, 16)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: .constant(downloadManager.isComplete == false && !downloadManager.isIdle),
               onDismiss: { if downloadManager.isComplete { hasSeenOnboarding = true } }) {
            // intentionally empty — sheet triggered differently below
        }
        .onChange(of: downloadManager.isComplete) { complete in
            if complete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    hasSeenOnboarding = true
                }
            }
        }
    }

    // MARK: - Info Row
    private func infoRow(icon: String, color: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 28)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(themeManager.colors.primaryText)
                Text(body)
                    .font(.system(size: 13))
                    .foregroundStyle(themeManager.colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Download Button / Progress
    @ViewBuilder
    private func downloadButton(theme: AppTheme, colors: ThemeColors) -> some View {
        switch downloadManager.phase {
        case .idle:
            Button {
                Task { await downloadManager.downloadFullBible() }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 20))
                    Text("Download Bible Data")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(LinearGradient(
                            colors: [colors.accent, colors.accentSecondary],
                            startPoint: .leading, endPoint: .trailing))
                        .shadow(color: colors.accent.opacity(0.4), radius: 12, y: 4)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)

        case .downloading(let progress, let detail):
            VStack(spacing: 14) {
                HStack {
                    Text("Downloading…")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(colors.accent)
                }
                ProgressView(value: progress)
                    .tint(colors.accent)
                Text(detail)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(colors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(colors.surface))
            .padding(.horizontal, 8)

        case .saving:
            HStack(spacing: 10) {
                ProgressView().tint(colors.accent)
                Text("Saving to device…")
                    .font(.system(size: 15)).foregroundStyle(colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(RoundedRectangle(cornerRadius: 16).fill(colors.surface))
            .padding(.horizontal, 8)

        case .complete(let count):
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24)).foregroundStyle(colors.highlight)
                    Text("Download complete!")
                        .font(.system(size: 16, weight: .bold)).foregroundStyle(colors.primaryText)
                }
                Text("\(count) verses ready")
                    .font(.system(size: 13)).foregroundStyle(colors.secondaryText)
                Text("Opening Bible…")
                    .font(.system(size: 12)).foregroundStyle(colors.secondaryText.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(RoundedRectangle(cornerRadius: 16).fill(colors.highlight.opacity(0.12)))
            .padding(.horizontal, 8)

        case .failed(let msg):
            VStack(spacing: 12) {
                Text("Download failed")
                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(colors.accent)
                Text(msg)
                    .font(.system(size: 12)).foregroundStyle(colors.secondaryText)
                    .multilineTextAlignment(.center)
                Button {
                    downloadManager.reset()
                    Task { await downloadManager.downloadFullBible() }
                } label: {
                    Label("Try Again", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(colors.accent)
                        .padding(.vertical, 12).frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 14).fill(colors.accent.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(colors.surface))
            .padding(.horizontal, 8)
        }
    }
}
