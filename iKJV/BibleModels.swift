import Foundation

// MARK: - Testament
enum Testament: String, CaseIterable, Identifiable, Codable {
    case old = "Old Testament"
    case new = "New Testament"

    var id: String { rawValue }

    var shortName: String {
        switch self {
        case .old: return "OT"
        case .new: return "NT"
        }
    }

    var bookCount: Int {
        switch self {
        case .old: return 39
        case .new: return 27
        }
    }

    var icon: String {
        switch self {
        case .old: return "scroll.fill"
        case .new: return "book.closed.fill"
        }
    }
}

// MARK: - Book Info
struct BookInfo: Identifiable, Hashable {
    let id: Int          // canonical order 1–66
    let name: String
    let abbreviation: String
    let testament: Testament
    let chapterCount: Int

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: BookInfo, rhs: BookInfo) -> Bool { lhs.id == rhs.id }
}

// MARK: - Verse
struct BibleVerse: Identifiable, Hashable {
    let id: String        // "Genesis-1-1"
    let book: String
    let chapter: Int
    let verse: Int
    let text: String

    init(book: String, chapter: Int, verse: Int, text: String) {
        self.id      = "\(book)-\(chapter)-\(verse)"
        self.book    = book
        self.chapter = chapter
        self.verse   = verse
        self.text    = text
    }
}

// MARK: - Navigation Value (iPhone NavigationStack)
struct ChapterRef: Hashable {
    let book: BookInfo
    let chapter: Int
}

// MARK: - Reading State
struct ReadingLocation: Codable, Equatable {
    var bookName: String
    var chapter: Int
    var verse: Int

    static let defaultLocation = ReadingLocation(bookName: "Genesis", chapter: 1, verse: 1)
}

// MARK: - All Books Catalog
struct BibleCatalog {
    static let books: [BookInfo] = [
        // ─── Old Testament ───────────────────────────────────────────────────
        BookInfo(id:  1, name: "Genesis",         abbreviation: "Gen",  testament: .old, chapterCount: 50),
        BookInfo(id:  2, name: "Exodus",          abbreviation: "Exo",  testament: .old, chapterCount: 40),
        BookInfo(id:  3, name: "Leviticus",       abbreviation: "Lev",  testament: .old, chapterCount: 27),
        BookInfo(id:  4, name: "Numbers",         abbreviation: "Num",  testament: .old, chapterCount: 36),
        BookInfo(id:  5, name: "Deuteronomy",     abbreviation: "Deu",  testament: .old, chapterCount: 34),
        BookInfo(id:  6, name: "Joshua",          abbreviation: "Jos",  testament: .old, chapterCount: 24),
        BookInfo(id:  7, name: "Judges",          abbreviation: "Jdg",  testament: .old, chapterCount: 21),
        BookInfo(id:  8, name: "Ruth",            abbreviation: "Rut",  testament: .old, chapterCount: 4),
        BookInfo(id:  9, name: "1 Samuel",        abbreviation: "1Sa",  testament: .old, chapterCount: 31),
        BookInfo(id: 10, name: "2 Samuel",        abbreviation: "2Sa",  testament: .old, chapterCount: 24),
        BookInfo(id: 11, name: "1 Kings",         abbreviation: "1Ki",  testament: .old, chapterCount: 22),
        BookInfo(id: 12, name: "2 Kings",         abbreviation: "2Ki",  testament: .old, chapterCount: 25),
        BookInfo(id: 13, name: "1 Chronicles",    abbreviation: "1Ch",  testament: .old, chapterCount: 29),
        BookInfo(id: 14, name: "2 Chronicles",    abbreviation: "2Ch",  testament: .old, chapterCount: 36),
        BookInfo(id: 15, name: "Ezra",            abbreviation: "Ezr",  testament: .old, chapterCount: 10),
        BookInfo(id: 16, name: "Nehemiah",        abbreviation: "Neh",  testament: .old, chapterCount: 13),
        BookInfo(id: 17, name: "Esther",          abbreviation: "Est",  testament: .old, chapterCount: 10),
        BookInfo(id: 18, name: "Job",             abbreviation: "Job",  testament: .old, chapterCount: 42),
        BookInfo(id: 19, name: "Psalms",          abbreviation: "Psa",  testament: .old, chapterCount: 150),
        BookInfo(id: 20, name: "Proverbs",        abbreviation: "Pro",  testament: .old, chapterCount: 31),
        BookInfo(id: 21, name: "Ecclesiastes",    abbreviation: "Ecc",  testament: .old, chapterCount: 12),
        BookInfo(id: 22, name: "Song of Solomon", abbreviation: "SoS",  testament: .old, chapterCount: 8),
        BookInfo(id: 23, name: "Isaiah",          abbreviation: "Isa",  testament: .old, chapterCount: 66),
        BookInfo(id: 24, name: "Jeremiah",        abbreviation: "Jer",  testament: .old, chapterCount: 52),
        BookInfo(id: 25, name: "Lamentations",    abbreviation: "Lam",  testament: .old, chapterCount: 5),
        BookInfo(id: 26, name: "Ezekiel",         abbreviation: "Eze",  testament: .old, chapterCount: 48),
        BookInfo(id: 27, name: "Daniel",          abbreviation: "Dan",  testament: .old, chapterCount: 12),
        BookInfo(id: 28, name: "Hosea",           abbreviation: "Hos",  testament: .old, chapterCount: 14),
        BookInfo(id: 29, name: "Joel",            abbreviation: "Joe",  testament: .old, chapterCount: 3),
        BookInfo(id: 30, name: "Amos",            abbreviation: "Amo",  testament: .old, chapterCount: 9),
        BookInfo(id: 31, name: "Obadiah",         abbreviation: "Oba",  testament: .old, chapterCount: 1),
        BookInfo(id: 32, name: "Jonah",           abbreviation: "Jon",  testament: .old, chapterCount: 4),
        BookInfo(id: 33, name: "Micah",           abbreviation: "Mic",  testament: .old, chapterCount: 7),
        BookInfo(id: 34, name: "Nahum",           abbreviation: "Nah",  testament: .old, chapterCount: 3),
        BookInfo(id: 35, name: "Habakkuk",        abbreviation: "Hab",  testament: .old, chapterCount: 3),
        BookInfo(id: 36, name: "Zephaniah",       abbreviation: "Zep",  testament: .old, chapterCount: 3),
        BookInfo(id: 37, name: "Haggai",          abbreviation: "Hag",  testament: .old, chapterCount: 2),
        BookInfo(id: 38, name: "Zechariah",       abbreviation: "Zec",  testament: .old, chapterCount: 14),
        BookInfo(id: 39, name: "Malachi",         abbreviation: "Mal",  testament: .old, chapterCount: 4),
        // ─── New Testament ───────────────────────────────────────────────────
        BookInfo(id: 40, name: "Matthew",         abbreviation: "Mat",  testament: .new, chapterCount: 28),
        BookInfo(id: 41, name: "Mark",            abbreviation: "Mar",  testament: .new, chapterCount: 16),
        BookInfo(id: 42, name: "Luke",            abbreviation: "Luk",  testament: .new, chapterCount: 24),
        BookInfo(id: 43, name: "John",            abbreviation: "Joh",  testament: .new, chapterCount: 21),
        BookInfo(id: 44, name: "Acts",            abbreviation: "Act",  testament: .new, chapterCount: 28),
        BookInfo(id: 45, name: "Romans",          abbreviation: "Rom",  testament: .new, chapterCount: 16),
        BookInfo(id: 46, name: "1 Corinthians",   abbreviation: "1Co",  testament: .new, chapterCount: 16),
        BookInfo(id: 47, name: "2 Corinthians",   abbreviation: "2Co",  testament: .new, chapterCount: 13),
        BookInfo(id: 48, name: "Galatians",       abbreviation: "Gal",  testament: .new, chapterCount: 6),
        BookInfo(id: 49, name: "Ephesians",       abbreviation: "Eph",  testament: .new, chapterCount: 6),
        BookInfo(id: 50, name: "Philippians",     abbreviation: "Php",  testament: .new, chapterCount: 4),
        BookInfo(id: 51, name: "Colossians",      abbreviation: "Col",  testament: .new, chapterCount: 4),
        BookInfo(id: 52, name: "1 Thessalonians", abbreviation: "1Th",  testament: .new, chapterCount: 5),
        BookInfo(id: 53, name: "2 Thessalonians", abbreviation: "2Th",  testament: .new, chapterCount: 3),
        BookInfo(id: 54, name: "1 Timothy",       abbreviation: "1Ti",  testament: .new, chapterCount: 6),
        BookInfo(id: 55, name: "2 Timothy",       abbreviation: "2Ti",  testament: .new, chapterCount: 4),
        BookInfo(id: 56, name: "Titus",           abbreviation: "Tit",  testament: .new, chapterCount: 3),
        BookInfo(id: 57, name: "Philemon",        abbreviation: "Phm",  testament: .new, chapterCount: 1),
        BookInfo(id: 58, name: "Hebrews",         abbreviation: "Heb",  testament: .new, chapterCount: 13),
        BookInfo(id: 59, name: "James",           abbreviation: "Jam",  testament: .new, chapterCount: 5),
        BookInfo(id: 60, name: "1 Peter",         abbreviation: "1Pe",  testament: .new, chapterCount: 5),
        BookInfo(id: 61, name: "2 Peter",         abbreviation: "2Pe",  testament: .new, chapterCount: 3),
        BookInfo(id: 62, name: "1 John",          abbreviation: "1Jo",  testament: .new, chapterCount: 5),
        BookInfo(id: 63, name: "2 John",          abbreviation: "2Jo",  testament: .new, chapterCount: 1),
        BookInfo(id: 64, name: "3 John",          abbreviation: "3Jo",  testament: .new, chapterCount: 1),
        BookInfo(id: 65, name: "Jude",            abbreviation: "Jud",  testament: .new, chapterCount: 1),
        BookInfo(id: 66, name: "Revelation",      abbreviation: "Rev",  testament: .new, chapterCount: 22),
    ]

    static func book(named name: String) -> BookInfo? {
        books.first { $0.name == name }
    }

    static func books(for testament: Testament) -> [BookInfo] {
        books.filter { $0.testament == testament }
    }
}
