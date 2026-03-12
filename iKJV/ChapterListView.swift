import SwiftUI

struct ChapterListView: View {
    let book: BookInfo

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var viewModel: BibleViewModel
    @State private var showThemePicker = false

    private let columns = [
        GridItem(.adaptive(minimum: 64, maximum: 80), spacing: 12)
    ]

    var body: some View {
        let colors = themeManager.colors
        let theme = themeManager.currentTheme

        ZStack {
            colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Book header card
                    bookHeader(theme: theme, colors: colors)

                    // Chapter count label
                    HStack {
                        Text("CHAPTERS")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(3)
                            .foregroundStyle(colors.secondaryText)
                        Spacer()
                        Text("\(book.chapterCount) chapters")
                            .font(.system(size: 11))
                            .foregroundStyle(colors.secondaryText.opacity(0.6))
                    }
                    .padding(.horizontal, 4)

                    // Grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(1...book.chapterCount, id: \.self) { chapter in
                            ChapterButton(
                                chapter: chapter,
                                book: book,
                                theme: theme,
                                colors: colors
                            )
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showThemePicker = true } label: {
                    Image(systemName: theme.icon)
                        .foregroundStyle(colors.accent)
                }
            }
        }
        .sheet(isPresented: $showThemePicker) {
            ThemePickerView()
        }
    }

    // MARK: - Book Header
    @ViewBuilder
    private func bookHeader(theme: AppTheme, colors: ThemeColors) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                accentColor(book: book, colors: colors).opacity(0.25),
                                accentColor(book: book, colors: colors).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                Text(book.abbreviation)
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundStyle(accentColor(book: book, colors: colors))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(book.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(colors.primaryText)
                HStack(spacing: 12) {
                    Label(book.testament.rawValue, systemImage: book.testament.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(colors.secondaryText)
                    Text("•")
                        .foregroundStyle(colors.secondaryText.opacity(0.4))
                    Text("\(book.chapterCount) Chapters")
                        .font(.system(size: 12))
                        .foregroundStyle(colors.secondaryText)
                }
            }

            Spacer()
        }
        .padding(16)
        .themedSurface(theme, cornerRadius: 16)
    }

    private func accentColor(book: BookInfo, colors: ThemeColors) -> Color {
        book.testament == .old ? colors.accent : colors.accentSecondary
    }
}

// MARK: - Chapter Button
struct ChapterButton: View {
    let chapter: Int
    let book: BookInfo
    let theme: AppTheme
    let colors: ThemeColors

    @EnvironmentObject var viewModel: BibleViewModel
    @State private var isPressed = false

    private var isSelected: Bool {
        viewModel.selectedBook?.id == book.id && viewModel.selectedChapter == chapter
    }

    private var hasContent: Bool {
        BibleLoader.hasContent(book: book.name, chapter: chapter)
    }

    var body: some View {
        NavigationLink {
            VerseReaderView(book: book, chapter: chapter)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? accentColor.opacity(0.25) : colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? accentColor : colors.borderColor.opacity(0.6),
                                lineWidth: isSelected ? 1.5 : 0.5
                            )
                    )

                VStack(spacing: 4) {
                    Text("\(chapter)")
                        .font(.system(size: 18, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(isSelected ? accentColor : colors.primaryText)

                    if hasContent {
                        Circle()
                            .fill(accentColor.opacity(0.6))
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .frame(width: 64, height: 64)
            .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.08)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.25)) { isPressed = false } }
        )
    }

    private var accentColor: Color {
        book.testament == .old ? colors.accent : colors.accentSecondary
    }
}
