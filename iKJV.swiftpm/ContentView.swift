import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var viewModel: BibleViewModel

    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - iPad: 3-column NavigationSplitView with List(selection:)
    var iPadLayout: some View {
        NavigationSplitView {
            BookSidebarView()
        } content: {
            if let book = viewModel.selectedBook {
                ChapterGridContent(book: book)
            } else {
                iPadWelcome
            }
        } detail: {
            if let book = viewModel.selectedBook,
               let chapter = viewModel.selectedChapter {
                VerseReaderView(book: book, chapter: chapter)
            } else {
                EmptyDetailView()
            }
        }
        .background(themeManager.colors.background.ignoresSafeArea())
    }

    var iPadWelcome: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.pages.fill")
                .font(.system(size: 52))
                .foregroundStyle(themeManager.colors.accent.opacity(0.4))
            Text("Select a book from the sidebar")
                .font(.title2)
                .foregroundStyle(themeManager.colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.colors.background.ignoresSafeArea())
    }

    // MARK: - iPhone: NavigationStack + navigationDestination
    var iPhoneLayout: some View {
        NavigationStack {
            HomeView()
                .navigationDestination(for: Testament.self) { testament in
                    BookListView(testament: testament)
                }
                .navigationDestination(for: BookInfo.self) { book in
                    ChapterListView(book: book)
                }
                .navigationDestination(for: ChapterRef.self) { ref in
                    VerseReaderView(book: ref.book, chapter: ref.chapter)
                }
        }
        .background(themeManager.colors.background.ignoresSafeArea())
    }
}

// MARK: - iPad Sidebar: Books with List(selection:)
struct BookSidebarView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var viewModel: BibleViewModel
    @State private var showThemePicker = false
    @State private var searchText = ""

    private var filtered: [BookInfo] {
        guard !searchText.isEmpty else { return BibleCatalog.books }
        return BibleCatalog.books.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        let colors = themeManager.colors
        let theme = themeManager.currentTheme

        List(selection: $viewModel.selectedBook) {
            ForEach(Testament.allCases) { testament in
                Section {
                    ForEach(filtered.filter { $0.testament == testament }) { book in
                        SidebarBookRow(book: book, colors: colors).tag(book)
                    }
                } header: {
                    Label(testament.rawValue, systemImage: testament.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(colors.accent)
                        .textCase(nil)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(colors.background)
        .listStyle(.sidebar)
        .searchable(text: $searchText, prompt: "Search books")
        .navigationTitle("iKJV")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showThemePicker = true } label: {
                    Image(systemName: theme.icon).foregroundStyle(colors.accent)
                }
            }
        }
        .sheet(isPresented: $showThemePicker) { ThemePickerView() }
    }
}

// MARK: - Sidebar Book Row
struct SidebarBookRow: View {
    let book: BookInfo
    let colors: ThemeColors

    var body: some View {
        HStack {
            Text(book.abbreviation)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(book.testament == .old ? colors.accent : colors.accentSecondary)
                .frame(width: 34, alignment: .leading)
            Text(book.name)
                .font(.system(size: 15))
                .foregroundStyle(colors.primaryText)
            Spacer()
            Text("\(book.chapterCount)")
                .font(.system(size: 11))
                .foregroundStyle(colors.secondaryText.opacity(0.5))
        }
        .listRowBackground(colors.surface.opacity(0.4))
    }
}

// MARK: - iPad Middle Column: Chapter grid
struct ChapterGridContent: View {
    let book: BookInfo
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var viewModel: BibleViewModel

    private let columns = [GridItem(.adaptive(minimum: 58, maximum: 70), spacing: 10)]

    var body: some View {
        let colors = themeManager.colors

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Text(book.abbreviation)
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundStyle(accent(colors))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(accent(colors).opacity(0.15)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(book.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(colors.primaryText)
                        Text("\(book.chapterCount) chapters · \(book.testament.rawValue)")
                            .font(.system(size: 12)).foregroundStyle(colors.secondaryText)
                    }
                }
                .padding(.horizontal, 16).padding(.top, 16)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(1...book.chapterCount, id: \.self) { chap in
                        iPadChapterCell(chapter: chap, book: book, colors: colors)
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 24)
            }
        }
        .background(colors.background.ignoresSafeArea())
        .navigationTitle(book.name)
    }

    private func accent(_ c: ThemeColors) -> Color {
        book.testament == .old ? c.accent : c.accentSecondary
    }
}

// MARK: - iPad Chapter Cell
struct iPadChapterCell: View {
    let chapter: Int
    let book: BookInfo
    let colors: ThemeColors
    @EnvironmentObject var viewModel: BibleViewModel

    var isSelected: Bool {
        viewModel.selectedChapter == chapter && viewModel.selectedBook == book
    }

    var body: some View {
        Button {
            viewModel.selectBook(book)
            viewModel.selectChapter(chapter)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? accent.opacity(0.25) : colors.surface)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(isSelected ? accent : colors.borderColor.opacity(0.4),
                                      lineWidth: isSelected ? 1.5 : 0.5))
                VStack(spacing: 3) {
                    Text("\(chapter)")
                        .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(isSelected ? accent : colors.primaryText)
                    if BibleLoader.hasContent(book: book.name, chapter: chapter) {
                        Circle().fill(accent.opacity(0.5)).frame(width: 4, height: 4)
                    }
                }
            }
            .frame(width: 58, height: 58)
        }
        .buttonStyle(.plain)
    }

    private var accent: Color {
        book.testament == .old ? colors.accent : colors.accentSecondary
    }
}

// MARK: - Empty Detail Placeholder
struct EmptyDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let colors = themeManager.colors
        VStack(spacing: 16) {
            Image(systemName: "book.pages")
                .font(.system(size: 56))
                .foregroundStyle(colors.accent.opacity(0.3))
            Text("Select a chapter to read")
                .font(.title3).foregroundStyle(colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background.ignoresSafeArea())
    }
}
