#!/usr/bin/env python3
"""
generate_kjv.py — Downloads the complete KJV Bible and produces iKJV/kjv.json

Usage:
    python3 scripts/generate_kjv.py

Output:
    iKJV/kjv.json  (bundled with the Xcode project)

Sources tried (all public domain / open license):
    1. github.com/thiagobodruk/bible  (JSON)
    2. api.esv.org fallback note
    3. getbible.net API
    4. bible-api.com
"""

import json, urllib.request, os, sys, time

OUT_PATH = os.path.join(os.path.dirname(__file__), "..", "iKJV", "kjv.json")

# ── Book metadata ────────────────────────────────────────────────────────────
BOOKS = [
    # (canonical name, id, chapter_count)
    ("Genesis",         1,  50), ("Exodus",          2,  40), ("Leviticus",       3,  27),
    ("Numbers",         4,  36), ("Deuteronomy",     5,  34), ("Joshua",          6,  24),
    ("Judges",          7,  21), ("Ruth",            8,   4), ("1 Samuel",        9,  31),
    ("2 Samuel",       10,  24), ("1 Kings",        11,  22), ("2 Kings",        12,  25),
    ("1 Chronicles",   13,  29), ("2 Chronicles",   14,  36), ("Ezra",           15,  10),
    ("Nehemiah",       16,  13), ("Esther",         17,  10), ("Job",            18,  42),
    ("Psalms",         19, 150), ("Proverbs",       20,  31), ("Ecclesiastes",   21,  12),
    ("Song of Solomon",22,   8), ("Isaiah",         23,  66), ("Jeremiah",       24,  52),
    ("Lamentations",   25,   5), ("Ezekiel",        26,  48), ("Daniel",         27,  12),
    ("Hosea",          28,  14), ("Joel",           29,   3), ("Amos",           30,   9),
    ("Obadiah",        31,   1), ("Jonah",          32,   4), ("Micah",          33,   7),
    ("Nahum",          34,   3), ("Habakkuk",       35,   3), ("Zephaniah",      36,   3),
    ("Haggai",         37,   2), ("Zechariah",      38,  14), ("Malachi",        39,   4),
    ("Matthew",        40,  28), ("Mark",           41,  16), ("Luke",           42,  24),
    ("John",           43,  21), ("Acts",           44,  28), ("Romans",         45,  16),
    ("1 Corinthians",  46,  16), ("2 Corinthians",  47,  13), ("Galatians",      48,   6),
    ("Ephesians",      49,   6), ("Philippians",    50,   4), ("Colossians",     51,   4),
    ("1 Thessalonians",52,   5), ("2 Thessalonians",53,   3), ("1 Timothy",      54,   6),
    ("2 Timothy",      55,   4), ("Titus",          56,   3), ("Philemon",       57,   1),
    ("Hebrews",        58,  13), ("James",          59,   5), ("1 Peter",        60,   5),
    ("2 Peter",        61,   3), ("1 John",         62,   5), ("2 John",         63,   1),
    ("3 John",         64,   1), ("Jude",           65,   1), ("Revelation",     66,  22),
]

def fetch_json(url, retries=3):
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "iKJV/1.0"})
            with urllib.request.urlopen(req, timeout=15) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(2 ** attempt)
            else:
                raise e

def try_thiagobodruk():
    """
    Fetch from thiagobodruk/bible GitHub raw (KJV JSON).
    Format: [{name, chapters: [[verse_text,...],...]}, ...]
    """
    print("Trying thiagobodruk/bible …")
    url = "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_kjv.json"
    data = fetch_json(url)
    verses = []
    for book_idx, book_data in enumerate(data):
        if book_idx >= len(BOOKS):
            break
        book_name = BOOKS[book_idx][0]
        for chap_idx, chapter in enumerate(book_data.get("chapters", [])):
            for verse_idx, text in enumerate(chapter):
                verses.append({
                    "b": book_name,
                    "c": chap_idx + 1,
                    "v": verse_idx + 1,
                    "t": text.strip()
                })
    return verses

def try_getbible():
    """
    Fetch book by book from getbible.net (kjv translation).
    Format: {book: {chapter: {verse: {text:...}}}}
    """
    print("Trying getbible.net …")
    verses = []
    base = "https://getbible.net/json?passage={book}&v=kjv&json=1"
    book_abbrevs = [
        "Gen","Exod","Lev","Num","Deut","Josh","Judg","Ruth","1Sam","2Sam",
        "1Kgs","2Kgs","1Chr","2Chr","Ezra","Neh","Esth","Job","Ps","Prov",
        "Eccl","Song","Isa","Jer","Lam","Ezek","Dan","Hos","Joel","Amos",
        "Obad","Jonah","Mic","Nah","Hab","Zeph","Hag","Zech","Mal",
        "Matt","Mark","Luke","John","Acts","Rom","1Cor","2Cor","Gal",
        "Eph","Phil","Col","1Thess","2Thess","1Tim","2Tim","Titus","Phlm",
        "Heb","Jas","1Pet","2Pet","1John","2John","3John","Jude","Rev"
    ]
    for i, (book_name, book_id, _) in enumerate(BOOKS):
        abbr = book_abbrevs[i] if i < len(book_abbrevs) else book_name.replace(" ", "")
        url = base.format(book=abbr)
        try:
            data = fetch_json(url)
            # getbible wraps in callback; the json=1 should return raw
            if isinstance(data, dict):
                for chap_key, chap_data in data.items():
                    chap_num = int(chap_key)
                    if isinstance(chap_data, dict):
                        for verse_key, verse_data in chap_data.items():
                            verse_num = int(verse_key)
                            text = verse_data.get("text", "").strip() if isinstance(verse_data, dict) else str(verse_data).strip()
                            verses.append({"b": book_name, "c": chap_num, "v": verse_num, "t": text})
            print(f"  {book_name}: ok")
            time.sleep(0.3)
        except Exception as e:
            print(f"  {book_name}: {e}")
    return verses

def try_bible_api():
    """
    Fetch chapter by chapter from bible-api.com (KJV).
    Slow but reliable.
    """
    print("Trying bible-api.com (this may take a while) …")
    verses = []
    base = "https://bible-api.com/{book}+{chapter}?translation=kjv"
    for book_name, _, chapter_count in BOOKS:
        for chap in range(1, chapter_count + 1):
            bk = book_name.replace(" ", "+")
            url = base.format(book=bk, chapter=chap)
            try:
                data = fetch_json(url)
                for v in data.get("verses", []):
                    verses.append({
                        "b": book_name,
                        "c": v["chapter"],
                        "v": v["verse"],
                        "t": v["text"].strip().replace("\n", " ")
                    })
                print(f"  {book_name} {chap}", end="\r", flush=True)
                time.sleep(0.2)
            except Exception as e:
                print(f"\n  Error {book_name} {chap}: {e}")
        print(f"  {book_name}: done          ")
    return verses

def main():
    verses = []

    # Try sources in order of preference
    for fn in [try_thiagobodruk, try_bible_api, try_getbible]:
        try:
            verses = fn()
            if len(verses) > 30000:
                print(f"Got {len(verses)} verses. Writing {OUT_PATH} …")
                break
        except Exception as e:
            print(f"Source failed: {e}")

    if len(verses) < 100:
        print("ERROR: Could not fetch Bible data. Check your internet connection.")
        sys.exit(1)

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(verses, f, ensure_ascii=False, separators=(",", ":"))

    size_kb = os.path.getsize(OUT_PATH) // 1024
    print(f"Done! {len(verses)} verses written to {OUT_PATH} ({size_kb} KB)")
    print("Now build the Xcode project — the full Bible will be bundled automatically.")

if __name__ == "__main__":
    main()
