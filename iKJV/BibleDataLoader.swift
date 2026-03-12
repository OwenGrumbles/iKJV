import Foundation

// MARK: - JSON-based KJV loader
// The app loads from a bundled `kjv.json` file when available,
// falling back to the hardcoded KJVData for key chapters.
//
// kjv.json format (flat array):
// [{"b":"Genesis","c":1,"v":1,"t":"In the beginning..."},...]

struct BibleLoader {

    // Cached verse lookup: [book: [chapter: [verse: text]]]
    private static var cache: [String: [Int: [Int: String]]]? = nil
    private static var loaded = false

    // MARK: - Public API
    static func verses(book: String, chapter: Int) -> [BibleVerse] {
        if let jsonVerses = lookupFromJSON(book: book, chapter: chapter), !jsonVerses.isEmpty {
            return jsonVerses
        }
        // Fall back to hardcoded data
        return KJVData.verses(book: book, chapter: chapter)
    }

    static func hasContent(book: String, chapter: Int) -> Bool {
        if jsonLoaded {
            return lookupFromJSON(book: book, chapter: chapter) != nil
        }
        return KJVData.hasContent(book: book, chapter: chapter)
    }

    static var jsonLoaded: Bool {
        loadJSONIfNeeded()
        return cache != nil
    }

    // MARK: - JSON Loading
    private static func loadJSONIfNeeded() {
        guard !loaded else { return }
        loaded = true

        guard let url = Bundle.main.url(forResource: "kjv", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }

        do {
            let rawVerses = try JSONDecoder().decode([RawVerse].self, from: data)
            var built: [String: [Int: [Int: String]]] = [:]
            for rv in rawVerses {
                if built[rv.b] == nil { built[rv.b] = [:] }
                if built[rv.b]![rv.c] == nil { built[rv.b]![rv.c] = [:] }
                built[rv.b]![rv.c]![rv.v] = rv.t
            }
            cache = built
        } catch {
            // JSON malformed — fall back to hardcoded
        }
    }

    private static func lookupFromJSON(book: String, chapter: Int) -> [BibleVerse]? {
        loadJSONIfNeeded()
        guard let bookData = cache?[book],
              let chapterData = bookData[chapter] else { return nil }
        return chapterData
            .sorted { $0.key < $1.key }
            .map { BibleVerse(book: book, chapter: chapter, verse: $0.key, text: $0.value) }
    }
}

// MARK: - JSON Verse Codable
private struct RawVerse: Codable {
    let b: String   // book
    let c: Int      // chapter
    let v: Int      // verse
    let t: String   // text
}
