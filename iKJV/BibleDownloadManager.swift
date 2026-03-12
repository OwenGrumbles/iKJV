import Foundation
import SwiftUI

// MARK: - Download Manager
@MainActor
class BibleDownloadManager: ObservableObject {

    enum Phase: Equatable {
        case idle
        case downloading(progress: Double, detail: String)
        case saving
        case complete(verseCount: Int)
        case failed(String)
    }

    @Published var phase: Phase = .idle

    var isIdle: Bool {
        if case .idle = phase { return true }
        return false
    }
    var isComplete: Bool {
        if case .complete = phase { return true }
        return false
    }
    var isFailed: Bool {
        if case .failed = phase { return true }
        return false
    }

    // MARK: - Documents URL
    static var kjvDocumentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("kjv.json")
    }

    // MARK: - Start Download
    func downloadFullBible() async {
        phase = .downloading(progress: 0, detail: "Connecting…")

        // Sources to try in order (all single-file downloads)
        let sources: [String] = [
            "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_kjv.json",
            "https://cdn.jsdelivr.net/gh/thiagobodruk/bible@master/json/en_kjv.json"
        ]

        for urlString in sources {
            guard let url = URL(string: urlString) else { continue }
            do {
                let verses = try await fetchAndParse(url: url)
                phase = .saving
                try saveVerses(verses)
                BibleLoader.reload()
                phase = .complete(verseCount: verses.count)
                return
            } catch {
                // try next source
            }
        }

        // All sources failed — try chapter-by-chapter from bible-api.com
        do {
            let verses = try await fetchChapterByChapter()
            phase = .saving
            try saveVerses(verses)
            BibleLoader.reload()
            phase = .complete(verseCount: verses.count)
        } catch {
            phase = .failed("Download failed. Please check your internet connection and try again.\n\n\(error.localizedDescription)")
        }
    }

    func reset() { phase = .idle }

    // MARK: - Fetch Thiagobodruk Format (single JSON file)
    // Format: [{"name":"Genesis","chapters":[["verse1","verse2",...],...]},...]
    private func fetchAndParse(url: URL) async throws -> [[String: Any]] {
        phase = .downloading(progress: 0.05, detail: "Downloading Bible data…")

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        phase = .downloading(progress: 0.6, detail: "Parsing 31,102 verses…")

        return try await Task.detached(priority: .userInitiated) { [weak self] in
            guard let books = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                throw NSError(domain: "iKJV", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format"])
            }

            let bookNames = BibleDownloadManager.canonicalBookNames
            var verses: [[String: Any]] = []

            for (bookIdx, bookData) in books.enumerated() {
                guard bookIdx < bookNames.count else { break }
                let bookName = bookNames[bookIdx]
                guard let chapters = bookData["chapters"] as? [[String]] else { continue }

                for (chapIdx, chapterVerses) in chapters.enumerated() {
                    for (verseIdx, text) in chapterVerses.enumerated() {
                        verses.append([
                            "b": bookName,
                            "c": chapIdx + 1,
                            "v": verseIdx + 1,
                            "t": text.trimmingCharacters(in: .whitespacesAndNewlines)
                        ])
                    }
                }

                let progress = 0.6 + (Double(bookIdx + 1) / Double(bookNames.count)) * 0.35
                await MainActor.run {
                    self?.phase = .downloading(progress: progress, detail: "Processing \(bookName)…")
                }
            }
            return verses
        }.value
    }

    // MARK: - Fallback: chapter-by-chapter from bible-api.com
    private func fetchChapterByChapter() async throws -> [[String: Any]] {
        let books = BibleDownloadManager.canonicalBookNames
        var allVerses: [[String: Any]] = []
        let chapterCounts = BibleDownloadManager.chapterCounts
        var processed = 0
        let total = chapterCounts.values.reduce(0, +)

        for bookName in books {
            guard let chapCount = chapterCounts[bookName] else { continue }
            let encoded = bookName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? bookName

            for chap in 1...chapCount {
                let urlString = "https://bible-api.com/\(encoded)+\(chap)?translation=kjv"
                guard let url = URL(string: urlString) else { continue }

                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let verses = json["verses"] as? [[String: Any]] {
                        for v in verses {
                            if let c = v["chapter"] as? Int,
                               let verse = v["verse"] as? Int,
                               let text = v["text"] as? String {
                                allVerses.append(["b": bookName, "c": c, "v": verse,
                                                  "t": text.trimmingCharacters(in: .whitespacesAndNewlines)
                                                          .replacingOccurrences(of: "\n", with: " ")])
                            }
                        }
                    }
                } catch { /* skip chapter on error */ }

                processed += 1
                let progress = 0.05 + (Double(processed) / Double(total)) * 0.9
                phase = .downloading(progress: progress, detail: "\(bookName) \(chap)")

                try? await Task.sleep(nanoseconds: 150_000_000) // 0.15s rate-limit
            }
        }

        if allVerses.isEmpty { throw URLError(.cannotConnectToHost) }
        return allVerses
    }

    // MARK: - Save
    private func saveVerses(_ verses: [[String: Any]]) throws {
        let data = try JSONSerialization.data(withJSONObject: verses, options: [])
        try data.write(to: BibleDownloadManager.kjvDocumentsURL, options: .atomic)
    }

    // MARK: - Canonical Book Names (66 in order)
    static let canonicalBookNames: [String] = [
        "Genesis","Exodus","Leviticus","Numbers","Deuteronomy","Joshua","Judges","Ruth",
        "1 Samuel","2 Samuel","1 Kings","2 Kings","1 Chronicles","2 Chronicles","Ezra",
        "Nehemiah","Esther","Job","Psalms","Proverbs","Ecclesiastes","Song of Solomon",
        "Isaiah","Jeremiah","Lamentations","Ezekiel","Daniel","Hosea","Joel","Amos",
        "Obadiah","Jonah","Micah","Nahum","Habakkuk","Zephaniah","Haggai","Zechariah","Malachi",
        "Matthew","Mark","Luke","John","Acts","Romans","1 Corinthians","2 Corinthians",
        "Galatians","Ephesians","Philippians","Colossians","1 Thessalonians","2 Thessalonians",
        "1 Timothy","2 Timothy","Titus","Philemon","Hebrews","James","1 Peter","2 Peter",
        "1 John","2 John","3 John","Jude","Revelation"
    ]

    static let chapterCounts: [String: Int] = [
        "Genesis":50,"Exodus":40,"Leviticus":27,"Numbers":36,"Deuteronomy":34,"Joshua":24,
        "Judges":21,"Ruth":4,"1 Samuel":31,"2 Samuel":24,"1 Kings":22,"2 Kings":25,
        "1 Chronicles":29,"2 Chronicles":36,"Ezra":10,"Nehemiah":13,"Esther":10,"Job":42,
        "Psalms":150,"Proverbs":31,"Ecclesiastes":12,"Song of Solomon":8,"Isaiah":66,
        "Jeremiah":52,"Lamentations":5,"Ezekiel":48,"Daniel":12,"Hosea":14,"Joel":3,"Amos":9,
        "Obadiah":1,"Jonah":4,"Micah":7,"Nahum":3,"Habakkuk":3,"Zephaniah":3,"Haggai":2,
        "Zechariah":14,"Malachi":4,"Matthew":28,"Mark":16,"Luke":24,"John":21,"Acts":28,
        "Romans":16,"1 Corinthians":16,"2 Corinthians":13,"Galatians":6,"Ephesians":6,
        "Philippians":4,"Colossians":4,"1 Thessalonians":5,"2 Thessalonians":3,"1 Timothy":6,
        "2 Timothy":4,"Titus":3,"Philemon":1,"Hebrews":13,"James":5,"1 Peter":5,"2 Peter":3,
        "1 John":5,"2 John":1,"3 John":1,"Jude":1,"Revelation":22
    ]
}
