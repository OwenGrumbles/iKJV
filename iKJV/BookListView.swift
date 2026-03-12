import SwiftUI

struct BookListView: View {
    var testament: Testament? = nil

    @EnvironmentObject var themeManager: ThemeManager
    @State private var searchText = ""
    @State private var showThemePicker = false

    private var books: [BookInfo] {
        let base = testament.map { BibleCatalog.books(for: $0) } ?? BibleCatalog.books
        guard !searchText.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        let colors = themeManager.colors
        let theme = themeManager.currentTheme

        ZStack {
            colors.background.ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    if testament != nil {
                        BookGridSection(books: books, theme: theme, colors: colors)
                    } else {
                        ForEach(Testament.allCases) { t in
                            let filtered = books.filter { $0.testament == t }
                            if !filtered.isEmpty {
                                Section {
                                    BookGridSection(books: filtered, theme: theme, colors: colors)
                                } header: {
                                    HStack(spacing: 8) {
                                        Image(systemName: t.icon)
                                            .font(.system(size: 12)).foregroundStyle(colors.accent)
                                        Text(t.rawValue.uppercased())
                                            .font(.system(size: 11, weight: .bold)).tracking(2)
                                            .foregroundStyle(colors.secondaryText)
                                        Spacer()
                                        Text("\(t.bookCount) books")
                                            .font(.system(size: 11))
                                            .foregroundStyle(colors.secondaryText.opacity(0.5))
                                    }
                                    .padding(.horizontal, 20).padding(.vertical, 10)
                                    .background(colors.background.opacity(0.95))
                                }
                            }
                        }
                    }
                }
                .padding(.top, 8).padding(.bottom, 40)
            }
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .automatic),
                        prompt: "Search books")
        }
        .navigationTitle(testament?.rawValue ?? "Books")
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
}

// MARK: - Book Grid Section
struct BookGridSection: View {
    let books: [BookInfo]
    let theme: AppTheme
    let colors: ThemeColors
    private let columns = [GridItem(.adaptive(minimum: 140, maximum: 200), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(books) { book in
                NavigationLink(value: book) {
                    BookCardLabel(book: book, theme: theme, colors: colors)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }
}

// MARK: - Book Card
struct BookCardLabel: View {
    let book: BookInfo
    let theme: AppTheme
    let colors: ThemeColors
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(book.abbreviation)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(accent)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(accent.opacity(0.12)))
                Spacer()
                Text("\(book.id)")
                    .font(.system(size: 10)).foregroundStyle(colors.secondaryText.opacity(0.4))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(book.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(colors.primaryText)
                    .lineLimit(2).multilineTextAlignment(.leading)
                Text("\(book.chapterCount) ch.")
                    .font(.system(size: 11)).foregroundStyle(colors.secondaryText)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .themedSurface(theme, cornerRadius: 14)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in isPressed = true }
            .onEnded   { _ in isPressed = false })
    }

    private var accent: Color {
        book.testament == .old ? colors.accent : colors.accentSecondary
    }
}
