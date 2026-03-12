import SwiftUI

struct ChapterListView: View {
    let book: BookInfo

    @EnvironmentObject var themeManager: ThemeManager
    @State private var showThemePicker = false

    private let columns = [GridItem(.adaptive(minimum: 64, maximum: 78), spacing: 12)]

    var body: some View {
        let colors = themeManager.colors
        let theme = themeManager.currentTheme

        ZStack {
            colors.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    bookHeader(theme: theme, colors: colors)

                    HStack {
                        Text("CHAPTERS")
                            .font(.system(size: 11, weight: .bold)).tracking(3)
                            .foregroundStyle(colors.secondaryText)
                        Spacer()
                        Text("\(book.chapterCount)")
                            .font(.system(size: 11)).foregroundStyle(colors.secondaryText.opacity(0.5))
                    }
                    .padding(.horizontal, 4)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(1...book.chapterCount, id: \.self) { chapter in
                            // NavigationLink(value:) pushes VerseReaderView via .navigationDestination
                            NavigationLink(value: ChapterRef(book: book, chapter: chapter)) {
                                ChapterCellLabel(chapter: chapter, book: book, colors: colors)
                            }
                            .buttonStyle(.plain)
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
                    Image(systemName: theme.icon).foregroundStyle(colors.accent)
                }
            }
        }
        .sheet(isPresented: $showThemePicker) { ThemePickerView() }
    }

    private func bookHeader(theme: AppTheme, colors: ThemeColors) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(accent(colors).opacity(0.18))
                    .frame(width: 52, height: 52)
                Text(book.abbreviation)
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundStyle(accent(colors))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(book.name)
                    .font(.system(size: 20, weight: .bold)).foregroundStyle(colors.primaryText)
                Label(book.testament.rawValue, systemImage: book.testament.icon)
                    .font(.system(size: 12)).foregroundStyle(colors.secondaryText)
            }
            Spacer()
        }
        .padding(16)
        .themedSurface(theme, cornerRadius: 16)
    }

    private func accent(_ c: ThemeColors) -> Color {
        book.testament == .old ? c.accent : c.accentSecondary
    }
}

// MARK: - Chapter Cell
struct ChapterCellLabel: View {
    let chapter: Int
    let book: BookInfo
    let colors: ThemeColors
    @State private var isPressed = false

    private var hasContent: Bool { BibleLoader.hasContent(book: book.name, chapter: chapter) }
    private var accent: Color { book.testament == .old ? colors.accent : colors.accentSecondary }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(colors.surface)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(colors.borderColor.opacity(0.5), lineWidth: 0.5))
            VStack(spacing: 4) {
                Text("\(chapter)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(colors.primaryText)
                if hasContent {
                    Circle().fill(accent.opacity(0.6)).frame(width: 4, height: 4)
                }
            }
        }
        .frame(width: 64, height: 64)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in isPressed = true }
            .onEnded   { _ in isPressed = false })
    }
}
