import SwiftUI

struct BookListView: View {
    var testament: Testament? = nil   // nil = show all books grouped

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var viewModel: BibleViewModel
    @State private var searchText = ""
    @State private var showThemePicker = false

    private var books: [BookInfo] {
        let base = testament.map { BibleCatalog.books(for: $0) } ?? BibleCatalog.books
        guard !searchText.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var groupedByTestament: [(Testament, [BookInfo])] {
        guard testament == nil else { return [] }
        return Testament.allCases.compactMap { t in
            let filtered = books.filter { $0.testament == t }
            return filtered.isEmpty ? nil : (t, filtered)
        }
    }

    var body: some View {
        let colors = themeManager.colors
        let theme = themeManager.currentTheme

        ZStack {
            colors.background.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    if testament != nil {
                        // Single testament: flat list
                        BookGridSection(books: books, theme: theme, colors: colors)
                    } else {
                        // All books: grouped
                        ForEach(groupedByTestament, id: \.0) { group in
                            Section {
                                BookGridSection(books: group.1, theme: theme, colors: colors)
                            } header: {
                                TestamentSectionHeader(testament: group.0, colors: colors)
                            }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic),
                       prompt: "Search books")
        }
        .navigationTitle(testament?.rawValue ?? "Books")
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
}

// MARK: - Section Header
struct TestamentSectionHeader: View {
    let testament: Testament
    let colors: ThemeColors

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: testament.icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(colors.accent)
            Text(testament.rawValue.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(2)
                .foregroundStyle(colors.secondaryText)
            Spacer()
            Text("\(testament.bookCount) books")
                .font(.system(size: 11))
                .foregroundStyle(colors.secondaryText.opacity(0.6))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(colors.background.opacity(0.95))
    }
}

// MARK: - Book Grid Section
struct BookGridSection: View {
    let books: [BookInfo]
    let theme: AppTheme
    let colors: ThemeColors

    private let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 200), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(books) { book in
                BookCard(book: book, theme: theme, colors: colors)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Book Card
struct BookCard: View {
    let book: BookInfo
    let theme: AppTheme
    let colors: ThemeColors

    @EnvironmentObject var viewModel: BibleViewModel
    @State private var isPressed = false

    var body: some View {
        NavigationLink {
            ChapterListView(book: book)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(book.abbreviation)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(accentColor.opacity(0.12))
                        )
                    Spacer()
                    Text("\(book.id)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(colors.secondaryText.opacity(0.5))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(book.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text("\(book.chapterCount) ch.")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.secondaryText)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .themedSurface(theme, cornerRadius: 14)
            .scaleEffect(isPressed ? 0.95 : 1.0)
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
