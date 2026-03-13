import Foundation

// MARK: - KJV Bible Loader
// Priority order:
//   1. Documents/kjv.json  (user-downloaded via in-app button)
//   2. Bundle/kjv.json     (manually added to Xcode project)
//   3. KJVData.swift       (hardcoded key chapters — always available)

struct BibleLoader {

    private static var cache: [String: [Int: [Int: String]]]? = nil
    private static var loaded = false

    // MARK: - Public API

    static func verses(book: String, chapter: Int) -> [BibleVerse] {
        if let v = lookupFromJSON(book: book, chapter: chapter), !v.isEmpty { return v }
        return KJVData.verses(book: book, chapter: chapter)
    }

    static func hasContent(book: String, chapter: Int) -> Bool {
        loadJSONIfNeeded()
        if cache != nil { return lookupFromJSON(book: book, chapter: chapter) != nil }
        return KJVData.hasContent(book: book, chapter: chapter)
    }

    static var jsonLoaded: Bool {
        loadJSONIfNeeded()
        return cache != nil
    }

    /// Call after downloading kjv.json to reload the cache.
    static func reload() {
        cache = nil
        loaded = false
        loadJSONIfNeeded()
    }

    // MARK: - Loading

    private static func loadJSONIfNeeded() {
        guard !loaded else { return }
        loaded = true

        // 1. Documents directory (downloaded in-app)
        let docsURL = BibleDownloadManager.kjvDocumentsURL
        if let data = try? Data(contentsOf: docsURL) {
            buildCache(from: data)
            if cache != nil { return }
        }

        // 2. App Bundle (added manually in Xcode)
        if let bundleURL = Bundle.main.url(forResource: "kjv", withExtension: "json"),
           let data = try? Data(contentsOf: bundleURL) {
            buildCache(from: data)
        }
    }

    private static func buildCache(from data: Data) {
        // Try flat format: [{"b":"Genesis","c":1,"v":1,"t":"..."}]
        if let rawVerses = try? JSONDecoder().decode([RawVerse].self, from: data) {
            var built: [String: [Int: [Int: String]]] = [:]
            for rv in rawVerses {
                built[rv.b, default: [:]][rv.c, default: [:]][rv.v] = rv.t
            }
            cache = built
            return
        }

        // Try thiagobodruk format: [{"name":"Genesis","chapters":[["v1","v2"],...]},...]
        if let books = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] {
            let names = BibleDownloadManager.canonicalBookNames
            var built: [String: [Int: [Int: String]]] = [:]
            for (bi, bookData) in books.enumerated() {
                guard bi < names.count,
                      let chapters = bookData["chapters"] as? [[String]] else { continue }
                let bookName = names[bi]
                for (ci, verses) in chapters.enumerated() {
                    for (vi, text) in verses.enumerated() {
                        built[bookName, default: [:]][ci + 1, default: [:]][vi + 1] =
                            text.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
            }
            if !built.isEmpty { cache = built }
        }
    }

    private static func lookupFromJSON(book: String, chapter: Int) -> [BibleVerse]? {
        loadJSONIfNeeded()
        guard let chapterData = cache?[book]?[chapter] else { return nil }
        return chapterData.sorted { $0.key < $1.key }
            .map { BibleVerse(book: book, chapter: chapter, verse: $0.key, text: $0.value) }
    }
}

// MARK: - Flat JSON verse
private struct RawVerse: Codable {
    let b: String; let c: Int; let v: Int; let t: String
}
