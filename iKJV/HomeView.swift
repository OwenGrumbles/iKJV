import SwiftUI

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var viewModel: BibleViewModel
    @State private var showThemePicker = false
    @State private var animateIn = false

    var body: some View {
        let theme = themeManager.currentTheme
        let colors = theme.colors

        ZStack {
            // Animated gradient background
            backgroundGradient(colors: colors)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection(theme: theme, colors: colors)

                    // Testament Cards
                    testamentCards(theme: theme, colors: colors)

                    // Continue Reading
                    continueReadingCard(theme: theme, colors: colors)

                    // Feature row
                    featureRow(theme: theme, colors: colors)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems(theme: theme, colors: colors) }
        .sheet(isPresented: $showThemePicker) {
            ThemePickerView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateIn = true
            }
        }
    }

    // MARK: - Background
    @ViewBuilder
    private func backgroundGradient(colors: ThemeColors) -> some View {
        LinearGradient(
            colors: [
                colors.background,
                colors.background.opacity(0.95),
                colors.accent.opacity(0.08),
                colors.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Header
    @ViewBuilder
    private func headerSection(theme: AppTheme, colors: ThemeColors) -> some View {
        VStack(spacing: 8) {
            // Logo / Title
            HStack(spacing: 12) {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [colors.accent, colors.accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: colors.accent.opacity(0.5), radius: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text("iKJV")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(colors.primaryText)
                    Text("King James Bible")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(colors.secondaryText)
                        .tracking(2)
                        .textCase(.uppercase)
                }
            }
        }
        .padding(.vertical, 12)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : -20)
    }

    // MARK: - Testament Cards
    @ViewBuilder
    private func testamentCards(theme: AppTheme, colors: ThemeColors) -> some View {
        VStack(spacing: 14) {
            Text("TESTAMENTS")
                .font(.system(size: 11, weight: .semibold))
                .tracking(3)
                .foregroundStyle(colors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 14) {
                TestamentCard(
                    testament: .old,
                    theme: theme,
                    colors: colors
                )
                TestamentCard(
                    testament: .new,
                    theme: theme,
                    colors: colors
                )
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: animateIn)
    }

    // MARK: - Continue Reading
    @ViewBuilder
    private func continueReadingCard(theme: AppTheme, colors: ThemeColors) -> some View {
        let loc = viewModel.lastLocation
        NavigationLink {
            BookListView()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colors.accent.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "book.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(colors.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Continue Reading")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                    Text("\(loc.bookName) \(loc.chapter)")
                        .font(.system(size: 13))
                        .foregroundStyle(colors.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(colors.accent)
            }
            .padding(16)
            .themedSurface(theme, cornerRadius: 14)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: animateIn)
    }

    // MARK: - Feature Row (stats)
    @ViewBuilder
    private func featureRow(theme: AppTheme, colors: ThemeColors) -> some View {
        HStack(spacing: 12) {
            FeatureChip(icon: "text.book.closed.fill", label: "66 Books", colors: colors)
            FeatureChip(icon: "list.number", label: "1,189 Chapters", colors: colors)
            FeatureChip(icon: "paragraph", label: "31,102 Verses", colors: colors)
        }
        .opacity(animateIn ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.35), value: animateIn)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private func toolbarItems(theme: AppTheme, colors: ThemeColors) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showThemePicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: theme.icon)
                        .font(.system(size: 14))
                    Text(theme.displayName)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(colors.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(colors.accent.opacity(0.12))
                        .overlay(
                            Capsule().strokeBorder(colors.accent.opacity(0.3), lineWidth: 0.5)
                        )
                )
            }
        }
    }
}

// MARK: - Testament Card
struct TestamentCard: View {
    let testament: Testament
    let theme: AppTheme
    let colors: ThemeColors
    @EnvironmentObject var viewModel: BibleViewModel
    @State private var isPressed = false

    var body: some View {
        NavigationLink {
            BookListView(testament: testament)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                // Icon row
                HStack {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.18))
                            .frame(width: 44, height: 44)
                        Image(systemName: testament.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(accentColor)
                    }
                    Spacer()
                    Text(testament.shortName)
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(accentColor.opacity(0.7))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(testament.rawValue)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(colors.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text("\(testament.bookCount) Books")
                        .font(.system(size: 13))
                        .foregroundStyle(colors.secondaryText)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .themedSurface(theme, cornerRadius: 18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        LinearGradient(
                            colors: [accentColor.opacity(0.4), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3)) { isPressed = false }
                }
        )
    }

    private var accentColor: Color {
        testament == .old ? colors.accent : colors.accentSecondary
    }
}

// MARK: - Feature Chip
struct FeatureChip: View {
    let icon: String
    let label: String
    let colors: ThemeColors

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(colors.accent)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(colors.secondaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(colors.surface.opacity(0.6))
                .overlay(Capsule().strokeBorder(colors.borderColor.opacity(0.5), lineWidth: 0.5))
        )
    }
}
