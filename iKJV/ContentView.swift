import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var viewModel: BibleViewModel

    // iPad split column visibility
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        let theme = themeManager.currentTheme
        let colors = theme.colors

        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadLayout(theme: theme, colors: colors)
            } else {
                iPhoneLayout(theme: theme, colors: colors)
            }
        }
        .background(colors.background.ignoresSafeArea())
    }

    // MARK: - iPad: NavigationSplitView
    @ViewBuilder
    private func iPadLayout(theme: AppTheme, colors: ThemeColors) -> some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar: Books
            BookListView()
                .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 320)
        } content: {
            // Middle: Chapters
            if let book = viewModel.selectedBook {
                ChapterListView(book: book)
            } else {
                HomeView()
            }
        } detail: {
            // Detail: Verses
            if viewModel.selectedChapter != nil {
                VerseReaderView()
            } else {
                EmptyDetailView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .background(colors.background.ignoresSafeArea())
    }

    // MARK: - iPhone: NavigationStack
    @ViewBuilder
    private func iPhoneLayout(theme: AppTheme, colors: ThemeColors) -> some View {
        NavigationStack {
            HomeView()
        }
        .background(colors.background.ignoresSafeArea())
    }
}

// MARK: - Empty Detail Placeholder
struct EmptyDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let colors = themeManager.colors
        VStack(spacing: 20) {
            Image(systemName: "book.pages")
                .font(.system(size: 64))
                .foregroundStyle(colors.accent.opacity(0.5))
            Text("Select a chapter to read")
                .font(.title3)
                .foregroundStyle(colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background.ignoresSafeArea())
    }
}
