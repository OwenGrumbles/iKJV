import SwiftUI

struct VerseReaderView: View {
    // Can be called with explicit params or pick up from viewModel
    var book: BookInfo? = nil
    var chapter: Int? = nil

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var viewModel: BibleViewModel

    @State private var showFontControls = false
    @State private var showThemePicker = false
    @State private var copiedVerseID: String? = nil
    @State private var scrollProxy: ScrollViewProxy? = nil

    // Resolve which book/chapter to show
    private var resolvedBook: BookInfo? { book ?? viewModel.selectedBook }
    private var resolvedChapter: Int? { chapter ?? viewModel.selectedChapter }

    var body: some View {
        let theme = themeManager.currentTheme
        let colors = theme.colors

        ZStack(alignment: .bottom) {
            colors.background.ignoresSafeArea()

            if let bookInfo = resolvedBook, let chap = resolvedChapter {
                mainContent(book: bookInfo, chapter: chap, theme: theme, colors: colors)
            } else {
                noSelectionView(colors: colors)
            }

            // Floating font size panel
            if showFontControls {
                fontControlPanel(colors: colors, theme: theme)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems(theme: theme, colors: colors) }
        .sheet(isPresented: $showThemePicker) { ThemePickerView() }
        .onAppear {
            if let b = book, let c = chapter {
                viewModel.selectBook(b)
                viewModel.selectChapter(c)
            }
        }
    }

    // MARK: - Main Content
    @ViewBuilder
    private func mainContent(book: BookInfo, chapter: Int, theme: AppTheme, colors: ThemeColors) -> some View {
        let verses = KJVData.verses(book: book.name, chapter: chapter)

        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Chapter header
                    chapterHeader(book: book, chapter: chapter, colors: colors, theme: theme)

                    if verses.isEmpty {
                        emptyChapterView(book: book, chapter: chapter, colors: colors)
                    } else {
                        // Verses
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(verses) { verse in
                                VerseRow(
                                    verse: verse,
                                    theme: theme,
                                    colors: colors,
                                    fontSize: viewModel.fontSize,
                                    isCopied: copiedVerseID == verse.id,
                                    onCopy: { copyVerse(verse) }
                                )
                                .id(verse.id)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 80)
                    }
                }
            }
            .onAppear { scrollProxy = proxy }
        }

        // Chapter nav bar (at very bottom, behind font panel)
        if !showFontControls {
            chapterNavBar(book: book, chapter: chapter, colors: colors, theme: theme)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
    }

    // MARK: - Chapter Header
    @ViewBuilder
    private func chapterHeader(book: BookInfo, chapter: Int, colors: ThemeColors, theme: AppTheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Breadcrumb
            HStack(spacing: 6) {
                Text(book.testament.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(colors.secondaryText.opacity(0.7))
                Image(systemName: "chevron.right")
                    .font(.system(size: 9))
                    .foregroundStyle(colors.secondaryText.opacity(0.4))
                Text(book.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(colors.secondaryText)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Big chapter title
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(book.name)
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(colors.primaryText)
                    Text("Chapter \(chapter)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(colors.accentSecondary)
                }
                Spacer()

                // Chapter badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [accentColor(book: book, colors: colors).opacity(0.3),
                                         accentColor(book: book, colors: colors).opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                    Text("\(chapter)")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(accentColor(book: book, colors: colors))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            Divider()
                .background(colors.borderColor.opacity(0.5))
        }
    }

    // MARK: - Empty Chapter
    @ViewBuilder
    private func emptyChapterView(book: BookInfo, chapter: Int, colors: ThemeColors) -> some View {
        VStack(spacing: 20) {
            Spacer(minLength: 60)
            Image(systemName: "text.page.slash")
                .font(.system(size: 48))
                .foregroundStyle(colors.secondaryText.opacity(0.4))
            VStack(spacing: 8) {
                Text("Text Not Yet Included")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(colors.primaryText.opacity(0.6))
                Text("\(book.name) \(chapter)")
                    .font(.system(size: 14))
                    .foregroundStyle(colors.secondaryText)
                Text("KJV Bible text for this chapter\nwill appear here.")
                    .font(.system(size: 13))
                    .foregroundStyle(colors.secondaryText.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }

    // MARK: - No Selection
    @ViewBuilder
    private func noSelectionView(colors: ThemeColors) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "book.pages")
                .font(.system(size: 56))
                .foregroundStyle(colors.accent.opacity(0.4))
            Text("Select a chapter to begin reading")
                .font(.title3)
                .foregroundStyle(colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Chapter Nav Bar
    @ViewBuilder
    private func chapterNavBar(book: BookInfo, chapter: Int, colors: ThemeColors, theme: AppTheme) -> some View {
        HStack(spacing: 0) {
            // Prev
            Button {
                if chapter > 1 {
                    navigateTo(book: book, chapter: chapter - 1)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Prev")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(chapter > 1 ? colors.accent : colors.secondaryText.opacity(0.3))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .disabled(chapter <= 1)

            Divider()
                .frame(height: 20)
                .background(colors.borderColor)

            // Reference
            Text("\(book.abbreviation) \(chapter)")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(colors.primaryText)
                .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 20)
                .background(colors.borderColor)

            // Next
            Button {
                if chapter < book.chapterCount {
                    navigateTo(book: book, chapter: chapter + 1)
                }
            } label: {
                HStack(spacing: 6) {
                    Text("Next")
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(chapter < book.chapterCount ? colors.accent : colors.secondaryText.opacity(0.3))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .disabled(chapter >= book.chapterCount)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colors.surface.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(colors.borderColor.opacity(0.5), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
    }

    // MARK: - Font Control Panel
    @ViewBuilder
    private func fontControlPanel(colors: ThemeColors, theme: AppTheme) -> some View {
        HStack(spacing: 20) {
            Button {
                viewModel.decreaseFontSize()
            } label: {
                Image(systemName: "textformat.size.smaller")
                    .font(.system(size: 20))
                    .foregroundStyle(colors.accent)
                    .frame(width: 44, height: 44)
            }

            Text("Aa")
                .font(.system(size: viewModel.fontSize, weight: .medium))
                .foregroundStyle(colors.primaryText)
                .frame(width: 50)

            Button {
                viewModel.increaseFontSize()
            } label: {
                Image(systemName: "textformat.size.larger")
                    .font(.system(size: 20))
                    .foregroundStyle(colors.accent)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Slider(value: $viewModel.fontSize, in: 12...32, step: 1)
                .tint(colors.accent)
                .frame(maxWidth: 140)

            Button {
                withAnimation(.spring(response: 0.3)) { showFontControls = false }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(colors.secondaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(colors.borderColor, lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.3), radius: 10, y: -2)
        )
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private func toolbarItems(theme: AppTheme, colors: ThemeColors) -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if let b = resolvedBook, let c = resolvedChapter {
                Text("\(b.name) \(c)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
            }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                withAnimation(.spring(response: 0.35)) {
                    showFontControls.toggle()
                }
            } label: {
                Image(systemName: "textformat.size")
                    .foregroundStyle(colors.accent)
            }

            Button { showThemePicker = true } label: {
                Image(systemName: theme.icon)
                    .foregroundStyle(colors.accent)
            }
        }
    }

    // MARK: - Helpers
    private func accentColor(book: BookInfo, colors: ThemeColors) -> Color {
        book.testament == .old ? colors.accent : colors.accentSecondary
    }

    private func copyVerse(_ verse: BibleVerse) {
        let text = "\(verse.book) \(verse.chapter):\(verse.verse) — \(verse.text)"
        UIPasteboard.general.string = text
        copiedVerseID = verse.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            copiedVerseID = nil
        }
    }

    private func navigateTo(book: BookInfo, chapter: Int) {
        // Navigation handled by NavigationLink in parent
        viewModel.selectBook(book)
        viewModel.selectChapter(chapter)
    }
}

// MARK: - Verse Row
struct VerseRow: View {
    let verse: BibleVerse
    let theme: AppTheme
    let colors: ThemeColors
    let fontSize: CGFloat
    let isCopied: Bool
    let onCopy: () -> Void

    @State private var isHighlighted = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Verse number
            Text("\(verse.verse)")
                .font(.system(size: max(fontSize - 5, 10), weight: .bold, design: .monospaced))
                .foregroundStyle(colors.verseNumber)
                .frame(minWidth: 28, alignment: .trailing)
                .padding(.top, 3)

            // Verse text
            Text(verse.text)
                .font(.system(size: fontSize, weight: .regular))
                .foregroundStyle(colors.primaryText)
                .lineSpacing(fontSize * 0.35)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHighlighted ? colors.accent.opacity(0.08) : Color.clear)
        )
        .overlay(
            isCopied ?
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(colors.highlight.opacity(0.6), lineWidth: 1)
            : nil
        )
        .contextMenu {
            Button {
                onCopy()
            } label: {
                Label("Copy Verse", systemImage: "doc.on.doc")
            }
            Button {
                shareVerse()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }

    private func shareVerse() {
        let text = "\(verse.book) \(verse.chapter):\(verse.verse) — \(verse.text)"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let vc = window.rootViewController {
            vc.present(av, animated: true)
        }
    }
}
