import SwiftUI

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var viewModel: BibleViewModel
    @EnvironmentObject var downloadManager: BibleDownloadManager
    @State private var showThemePicker = false
    @State private var showDownloader = false
    @State private var animateIn = false

    var body: some View {
        let theme = themeManager.currentTheme
        let colors = theme.colors

        ZStack {
            backgroundGradient(colors: colors).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 28) {
                    headerSection(colors: colors)
                    testamentCards(theme: theme, colors: colors)
                    bibleStatusCard(theme: theme, colors: colors)
                    statsRow(colors: colors)
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent(theme: theme, colors: colors) }
        .sheet(isPresented: $showThemePicker) { ThemePickerView() }
        .sheet(isPresented: $showDownloader) { BibleDownloadView() }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateIn = true
            }
        }
    }

    // MARK: - Background
    private func backgroundGradient(colors: ThemeColors) -> some View {
        LinearGradient(
            colors: [colors.background, colors.accent.opacity(0.07), colors.background],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    // MARK: - Header
    private func headerSection(colors: ThemeColors) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "book.pages.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(LinearGradient(
                    colors: [colors.accent, colors.accentSecondary],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: colors.accent.opacity(0.4), radius: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text("iKJV")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(colors.primaryText)
                Text("King James Bible")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(colors.secondaryText)
                    .tracking(2).textCase(.uppercase)
            }
            Spacer()
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : -16)
    }

    // MARK: - Testament Cards (NavigationLink(value:) for proper push nav)
    private func testamentCards(theme: AppTheme, colors: ThemeColors) -> some View {
        VStack(spacing: 12) {
            Text("TESTAMENTS")
                .font(.system(size: 11, weight: .semibold)).tracking(3)
                .foregroundStyle(colors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 12) {
                NavigationLink(value: Testament.old) {
                    TestamentCard(testament: .old, theme: theme, colors: colors)
                }
                .buttonStyle(.plain)
                NavigationLink(value: Testament.new) {
                    TestamentCard(testament: .new, theme: theme, colors: colors)
                }
                .buttonStyle(.plain)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: animateIn)
    }

    // MARK: - Bible Status / Download Card
    private func bibleStatusCard(theme: AppTheme, colors: ThemeColors) -> some View {
        let hasFullBible = BibleLoader.jsonLoaded
        return Button { if !hasFullBible { showDownloader = true } } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill((hasFullBible ? colors.highlight : colors.accent).opacity(0.15))
                        .frame(width: 46, height: 46)
                    Image(systemName: hasFullBible ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(hasFullBible ? colors.highlight : colors.accent)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(hasFullBible ? "Full Bible Loaded" : "Download Full Bible")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                    Text(hasFullBible
                         ? "All 31,102 verses — Genesis to Revelation"
                         : "Tap to download all 66 books in-app")
                        .font(.system(size: 12))
                        .foregroundStyle(colors.secondaryText)
                }
                Spacer()
                if !hasFullBible {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(colors.accent)
                }
            }
            .padding(14)
            .themedSurface(theme, cornerRadius: 14)
        }
        .buttonStyle(.plain)
        .disabled(hasFullBible)
        .opacity(animateIn ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: animateIn)
    }

    // MARK: - Stats
    private func statsRow(colors: ThemeColors) -> some View {
        HStack(spacing: 10) {
            FeatureChip(icon: "text.book.closed.fill", label: "66 Books", colors: colors)
            FeatureChip(icon: "list.number", label: "1,189 Chapters", colors: colors)
            FeatureChip(icon: "paragraph", label: "31,102 Verses", colors: colors)
        }
        .opacity(animateIn ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.35), value: animateIn)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private func toolbarContent(theme: AppTheme, colors: ThemeColors) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showThemePicker = true } label: {
                HStack(spacing: 5) {
                    Image(systemName: theme.icon).font(.system(size: 13))
                    Text(theme.displayName).font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(colors.accent)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(colors.accent.opacity(0.12))
                    .overlay(Capsule().strokeBorder(colors.accent.opacity(0.25), lineWidth: 0.5)))
            }
        }
    }
}

// MARK: - Testament Card
struct TestamentCard: View {
    let testament: Testament
    let theme: AppTheme
    let colors: ThemeColors
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    Circle().fill(accent.opacity(0.18)).frame(width: 42, height: 42)
                    Image(systemName: testament.icon)
                        .font(.system(size: 19, weight: .semibold)).foregroundStyle(accent)
                }
                Spacer()
                Text(testament.shortName)
                    .font(.system(size: 10, weight: .bold)).tracking(2)
                    .foregroundStyle(accent.opacity(0.6))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(testament.rawValue)
                    .font(.system(size: 15, weight: .bold)).foregroundStyle(colors.primaryText)
                    .multilineTextAlignment(.leading)
                Text("\(testament.bookCount) Books")
                    .font(.system(size: 12)).foregroundStyle(colors.secondaryText)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .themedSurface(theme, cornerRadius: 18)
        .overlay(RoundedRectangle(cornerRadius: 18)
            .strokeBorder(LinearGradient(colors: [accent.opacity(0.4), .clear],
                                         startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
    }
    private var accent: Color { testament == .old ? colors.accent : colors.accentSecondary }
}

// MARK: - Feature Chip
struct FeatureChip: View {
    let icon: String; let label: String; let colors: ThemeColors
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10)).foregroundStyle(colors.accent)
            Text(label).font(.system(size: 10, weight: .medium)).foregroundStyle(colors.secondaryText)
        }
        .padding(.horizontal, 9).padding(.vertical, 5)
        .background(Capsule().fill(colors.surface.opacity(0.5))
            .overlay(Capsule().strokeBorder(colors.borderColor.opacity(0.4), lineWidth: 0.5)))
    }
}
