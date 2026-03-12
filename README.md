# iKJV — King James Bible for iOS & iPadOS

A beautiful, themed KJV Bible reader built with SwiftUI.
Supports iOS 17+ and iPadOS 17+, with **Liquid Glass** effects on iOS 26+.

---

## Themes

| Theme | Background | Accent | Vibe |
|-------|-----------|--------|------|
| **VS Code Red** | `#1E1E1E` | `#F44747` | Dark editor, crimson |
| **Dracula** | `#282A36` | `#FF79C6` | Purple twilight, neon |
| **Catppuccin** | `#1E1E2E` | `#CBA6F7` | Warm mocha, pastel |
| **Gruvbox** | `#282828` | `#FB4934` | Retro earthy contrast |

---

## Getting the Full KJV Bible (Genesis → Revelation)

The app ships with key chapters pre-loaded. To bundle **all 66 books / 31,102 verses**:

```bash
# requires Python 3 and internet access
python3 scripts/generate_kjv.py
```

This downloads the complete public-domain KJV text and writes it to
`iKJV/kjv.json` — which Xcode bundles automatically on next build.

### Adding `kjv.json` to Xcode manually
If you already have a `kjv.json` in the flat format:
```json
[{"b":"Genesis","c":1,"v":1,"t":"In the beginning God created..."},...]
```
1. Drag `kjv.json` into the `iKJV` group in Xcode
2. Ensure **"Add to target: iKJV"** is checked
3. Build & run

---

## Project Structure

```
iKJV/
├── iKJVApp.swift          — App entry point
├── ContentView.swift      — iPad split / iPhone stack layout
├── HomeView.swift         — Landing screen with testament cards
├── BookListView.swift     — Searchable book grid
├── ChapterListView.swift  — Chapter number grid
├── VerseReaderView.swift  — Verse reader with font controls
├── ThemePickerView.swift  — Theme selection sheet
├── AppTheme.swift         — Theme definitions + Liquid Glass modifiers
├── ThemeManager.swift     — ObservableObject theme state
├── BibleModels.swift      — Data structures for all 66 books
├── KJVBibleData.swift     — Hardcoded KJV text for key chapters
├── BibleDataLoader.swift  — JSON loader (uses kjv.json when present)
└── BibleViewModel.swift   — Navigation and reading state
scripts/
└── generate_kjv.py        — Downloads & formats complete KJV Bible
```

---

## Liquid Glass (iOS 26+)

The app uses `#available(iOS 26.0, *)` guards to apply `.glassEffect()` on
iOS 26 while falling back to `.regularMaterial` on iOS 17–25.

---

## App Store Submission

See the **"Can You Publish to App Store?"** section in the project notes.
You will need:
- An **Apple Developer account** ($99/yr)
- Xcode on a Mac
- An **App Store Connect** listing
- A provisioning profile & signing certificate

---

*The KJV Bible is in the public domain (first published 1611, US copyright expired).*
