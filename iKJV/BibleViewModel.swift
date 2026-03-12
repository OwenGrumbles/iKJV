import SwiftUI
import Combine

class BibleViewModel: ObservableObject {
    // MARK: - Navigation State
    @Published var selectedTestament: Testament? = nil
    @Published var selectedBook: BookInfo? = nil
    @Published var selectedChapter: Int? = nil
    @Published var highlightedVerseID: String? = nil

    // MARK: - Reader State
    @Published var currentVerses: [BibleVerse] = []
    @Published var fontSize: CGFloat = 18
    @Published var isLoading: Bool = false
    @Published var searchQuery: String = ""

    // MARK: - Reading History (last location)
    private let lastLocationKey = "iKJV_lastLocation"

    var lastLocation: ReadingLocation {
        get {
            if let data = UserDefaults.standard.data(forKey: lastLocationKey),
               let loc = try? JSONDecoder().decode(ReadingLocation.self, from: data) {
                return loc
            }
            return .defaultLocation
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: lastLocationKey)
            }
        }
    }

    // MARK: - Computed
    var booksForSelectedTestament: [BookInfo] {
        guard let t = selectedTestament else { return BibleCatalog.books }
        return BibleCatalog.books(for: t)
    }

    var filteredBooks: [BookInfo] {
        let books = booksForSelectedTestament
        guard !searchQuery.isEmpty else { return books }
        return books.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    var oldTestamentBooks: [BookInfo] { BibleCatalog.books(for: .old) }
    var newTestamentBooks: [BookInfo] { BibleCatalog.books(for: .new) }

    var currentBookInfo: BookInfo? { selectedBook }

    var currentChapterHasContent: Bool {
        guard let book = selectedBook, let chapter = selectedChapter else { return false }
        return BibleLoader.hasContent(book: book.name, chapter: chapter)
    }

    var usingFullBible: Bool { BibleLoader.jsonLoaded }

    var currentReference: String {
        guard let book = selectedBook else { return "iKJV" }
        if let chapter = selectedChapter {
            return "\(book.name) \(chapter)"
        }
        return book.name
    }

    // MARK: - Navigation Actions
    func selectTestament(_ testament: Testament) {
        selectedTestament = testament
        selectedBook = nil
        selectedChapter = nil
        currentVerses = []
    }

    func selectBook(_ book: BookInfo) {
        selectedBook = book
        selectedChapter = nil
        currentVerses = []
    }

    func selectChapter(_ chapter: Int) {
        guard let book = selectedBook else { return }
        selectedChapter = chapter
        loadVerses(book: book.name, chapter: chapter)
    }

    func navigateToPrevChapter() {
        guard let book = selectedBook,
              let chapter = selectedChapter,
              chapter > 1 else { return }
        selectChapter(chapter - 1)
    }

    func navigateToNextChapter() {
        guard let book = selectedBook,
              let chapter = selectedChapter,
              chapter < book.chapterCount else { return }
        selectChapter(chapter + 1)
    }

    var canGoPrev: Bool {
        guard let chapter = selectedChapter else { return false }
        return chapter > 1
    }

    var canGoNext: Bool {
        guard let book = selectedBook, let chapter = selectedChapter else { return false }
        return chapter < book.chapterCount
    }

    // MARK: - Data Loading
    func loadVerses(book: String, chapter: Int) {
        isLoading = true
        let verses = BibleLoader.verses(book: book, chapter: chapter)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.currentVerses = verses
            self?.isLoading = false
            self?.lastLocation = ReadingLocation(bookName: book, chapter: chapter, verse: 1)
        }
    }

    func resumeLastLocation() {
        let loc = lastLocation
        if let book = BibleCatalog.book(named: loc.bookName) {
            selectedBook = book
            selectedTestament = book.testament
            selectChapter(loc.chapter)
        }
    }

    // MARK: - Font
    func increaseFontSize() { fontSize = min(fontSize + 2, 32) }
    func decreaseFontSize() { fontSize = max(fontSize - 2, 12) }
}
