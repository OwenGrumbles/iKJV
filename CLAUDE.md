# CLAUDE.md — iKJV Project Specification

This file tells Claude how to work on this project. Read it before making any change.

---

## Project Overview

**iKJV** is a SwiftUI KJV Bible reader for iPhone and iPad.
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Minimum deployment**: iOS 17.0 / iPadOS 17.0
- **Enhanced on**: iOS 26+ (Liquid Glass)
- **Platforms**: iPhone + iPad (universal)
- **Bundle ID**: `com.owengrumbles.iKJV`
- **Package**: `Package.swift` at repo root (works in Swift Playgrounds on iPad AND Xcode on Mac)
- **Xcode project**: `iKJV.xcodeproj` (also present for Mac builds)

---

## File Map

```
iKJV/
├── iKJVApp.swift            Entry point. Injects all @StateObject env objects.
│                            Shows OnboardingView on first launch if Bible not downloaded.
├── ContentView.swift        Root layout. iPad = NavigationSplitView. iPhone = NavigationStack.
├── OnboardingView.swift     First-launch screen. Explains download requirement. Shows progress.
├── HomeView.swift           iPhone home. Testament cards + download status card.
├── BookListView.swift       Grid of book cards. NavigationLink(value: BookInfo).
├── ChapterListView.swift    Chapter number grid. NavigationLink(value: ChapterRef).
├── VerseReaderView.swift    Verse reader. Font size control. Copy/share per verse.
├── ThemePickerView.swift    Sheet. Shows all 4 themes with live KJV preview.
├── AppTheme.swift           Theme enum + ThemeColors struct + glass/surface modifiers.
├── ThemeManager.swift       ObservableObject. Persists theme to UserDefaults.
├── BibleModels.swift        BookInfo, BibleVerse, Testament, ChapterRef, ReadingLocation.
├── BibleViewModel.swift     Navigation state. Loads verses. Persists last location.
├── KJVBibleData.swift       Hardcoded KJV text for key chapters (always available offline).
├── BibleDataLoader.swift    Loads kjv.json from Documents → Bundle → KJVData fallback.
├── BibleDownloadManager.swift  Downloads full KJV (~4MB) from CDN. Saves to Documents.
└── BibleDownloadView.swift  Sheet UI for the download flow with progress bar.

scripts/
└── generate_kjv.py          Python script (alternative to in-app download, for Mac users).
```

---

## Architecture Rules

### Navigation — DO NOT BREAK THIS

**iPad** uses `NavigationSplitView` with `List(selection:)` bindings:
```swift
// CORRECT for iPad
List(selection: $viewModel.selectedBook) {
    ForEach(books) { book in
        SidebarBookRow(book: book, colors: colors).tag(book)
    }
}
```
Never use `NavigationLink` in the iPad sidebar — it does not populate the content column.

**iPhone** uses `NavigationStack` with `NavigationLink(value:)` + `.navigationDestination`:
```swift
// CORRECT for iPhone
NavigationStack {
    HomeView()
        .navigationDestination(for: Testament.self) { ... }
        .navigationDestination(for: BookInfo.self)  { ... }
        .navigationDestination(for: ChapterRef.self){ ... }
}
// In child views:
NavigationLink(value: book) { BookCardLabel(...) }
NavigationLink(value: ChapterRef(book: book, chapter: n)) { ChapterCellLabel(...) }
```
Never use the old `NavigationLink { destination } label: { }` pattern on iPhone — it breaks SwiftUI's navigation state.

### Environment Objects
Every view that needs these must declare them:
```swift
@EnvironmentObject var themeManager: ThemeManager
@EnvironmentObject var viewModel: BibleViewModel
@EnvironmentObject var downloadManager: BibleDownloadManager
```
All three are injected at the root in `iKJVApp.swift`.

### Data Flow
```
BibleDownloadManager  →  saves Documents/kjv.json  →  calls BibleLoader.reload()
BibleDataLoader       →  checks Documents → Bundle → KJVData (hardcoded)
BibleViewModel        →  calls BibleLoader.verses(book:chapter:)
Views                 →  read from viewModel.currentVerses
```

---

## Theme Specification

All themes are dark. Never add a light mode. Never use system `.primary` / `.secondary` colors — always use `ThemeColors` properties.

### VS Code Red
| Role | Hex | Usage |
|------|-----|-------|
| `background` | `#1E1E1E` | Page/screen background |
| `surface` | `#252526` | Cards, rows, panels |
| `surfaceHighlight` | `#2D2D30` | Hover / selected surface |
| `primaryText` | `#D4D4D4` | Body text, titles |
| `secondaryText` | `#808080` | Labels, captions, metadata |
| `accent` | `#F44747` | Primary actions, OT highlight |
| `accentSecondary` | `#569CD6` | NT highlight, secondary actions |
| `highlight` | `#CE9178` | String-like emphasis |
| `verseNumber` | `#4FC1FF` | Verse number column |
| `borderColor` | `#404040` | Card borders, dividers |

### Dracula
| Role | Hex | Usage |
|------|-----|-------|
| `background` | `#282A36` | Page/screen background |
| `surface` | `#44475A` | Cards, rows, panels |
| `surfaceHighlight` | `#6272A4` | Hover / selected surface |
| `primaryText` | `#F8F8F2` | Body text, titles |
| `secondaryText` | `#6272A4` | Labels, captions |
| `accent` | `#FF79C6` | Primary actions, OT highlight |
| `accentSecondary` | `#BD93F9` | NT highlight, secondary actions |
| `highlight` | `#50FA7B` | Positive states, success |
| `verseNumber` | `#FFB86C` | Verse number column |
| `borderColor` | `#6272A4` | Card borders |

### Catppuccin Mocha
| Role | Hex | Usage |
|------|-----|-------|
| `background` | `#1E1E2E` | Page/screen background |
| `surface` | `#313244` | Cards, rows, panels |
| `surfaceHighlight` | `#45475A` | Hover / selected surface |
| `primaryText` | `#CDD6F4` | Body text, titles |
| `secondaryText` | `#A6ADC8` | Labels, captions |
| `accent` | `#CBA6F7` | Mauve — OT highlight |
| `accentSecondary` | `#89B4FA` | Blue — NT highlight |
| `highlight` | `#FAB387` | Peach — positive states |
| `verseNumber` | `#F38BA8` | Red — verse number column |
| `borderColor` | `#585B70` | Card borders |

### Gruvbox Dark
| Role | Hex | Usage |
|------|-----|-------|
| `background` | `#282828` | Page/screen background |
| `surface` | `#3C3836` | Cards, rows, panels |
| `surfaceHighlight` | `#504945` | Hover / selected surface |
| `primaryText` | `#EBDBB2` | Cream — body text, titles |
| `secondaryText` | `#A89984` | Labels, captions |
| `accent` | `#FB4934` | Red — OT highlight |
| `accentSecondary` | `#FABD2F` | Yellow — NT highlight |
| `highlight` | `#B8BB26` | Green — positive states |
| `verseNumber` | `#83A598` | Aqua — verse number column |
| `borderColor` | `#665C54` | Card borders |

### Theme Rules
- **OT accent = `colors.accent`** (the warm/bold color)
- **NT accent = `colors.accentSecondary`** (the cool/secondary color)
- Never hardcode hex values in views — always reference `ThemeColors` properties
- Theme is always accessed via `@EnvironmentObject var themeManager: ThemeManager`
- Access colors with `themeManager.currentTheme.colors` or `themeManager.colors`
- Theme persists to `UserDefaults` key `"iKJV_selectedTheme"`

---

## UI / UX Principles

### Layout
- Use `ScrollView` + `LazyVGrid` / `LazyVStack` for all scrollable lists
- Cards use `RoundedRectangle(cornerRadius: 14–18)` — never square corners
- Minimum tap target: 44×44 pt
- Card padding: `14–18` pt horizontal+vertical
- Section labels: `.font(.system(size: 11, weight: .bold)).tracking(3).textCase(.uppercase)`
- Screen padding: `20` pt horizontal

### Typography
- App title: `.system(size: 36–42, weight: .black, design: .rounded)`
- Section headings: `.system(size: 18–22, weight: .bold)`
- Body / verse text: `.system(size: viewModel.fontSize)` — user-adjustable 12–32 pt
- Verse numbers: `.system(size: fontSize - 5, weight: .bold, design: .monospaced)`
- Labels/captions: `.system(size: 11–13)`
- Tracking for allcaps labels: `3`
- Line spacing for verse text: `fontSize * 0.35`

### Animation
- Spring: `.spring(response: 0.35, dampingFraction: 0.8)` for UI transitions
- Press scale: `0.92–0.96` with `.spring(response: 0.2)` for cards/buttons
- Screen enter: opacity 0→1 + offset y 20→0, delayed by 0.1–0.35s per element
- Theme change: `.spring(response: 0.35, dampingFraction: 0.8)` wrapped in `withAnimation`

### Interaction
- Cards use `simultaneousGesture(DragGesture(minimumDistance: 0))` for press-scale effect
  alongside `NavigationLink(value:)` — never replace the NavigationLink with a Button
- Context menus on verse rows: "Copy Verse" + "Share"
- Long-press context menu preferred over swipe actions for reading context

### iPad-specific
- `NavigationSplitView` with `.balanced` style
- Sidebar width: 240–320 pt
- Three columns: Books (sidebar) → Chapters (content) → Verses (detail)
- All orientations supported (portrait + landscape)

### iPhone-specific
- `NavigationStack` from root
- Full-screen navigation (no modals for primary content)
- Floating chapter nav bar at bottom of `VerseReaderView`

---

## Liquid Glass (iOS 26+)

Always gate behind `#available(iOS 26.0, *)`. Provide a material fallback.

```swift
// CORRECT pattern
if #available(iOS 26.0, *) {
    content
        .tint(theme.colors.glassAccent)
        .glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius))
} else {
    content
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(theme.colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(theme.colors.borderColor, lineWidth: 1)
                )
        )
}
```

Use the `.themedGlass(_:cornerRadius:)` modifier (defined in `AppTheme.swift`) for glass cards.
Use the `.themedSurface(_:cornerRadius:)` modifier for regular surface cards (works on all iOS).

Do NOT call `.glassEffect()` without an `#available` check.

---

## Bible Data

### Hardcoded chapters (always available, KJVBibleData.swift)
Genesis 1–3 · Psalm 1, 23, 91 · Isaiah 53 · Matthew 5–6 · John 1, 3, 15 · Romans 8 · 1 Corinthians 13 · Revelation 1, 21, 22

### Full Bible (user-downloaded)
- Saved to: `Documents/kjv.json`
- Format: `[{"b":"Genesis","c":1,"v":1,"t":"In the beginning..."},...]`
- Also supports thiagobodruk format: `[{"name":"Genesis","chapters":[["v1","v2",...],...]},...]`
- Download source: `https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_kjv.json`
- ~31,102 verses, ~4 MB

### Loading priority (BibleDataLoader.swift)
1. `Documents/kjv.json` (user-downloaded via in-app button)
2. `Bundle/kjv.json` (manually added in Xcode — optional)
3. `KJVData` hardcoded Swift dictionary (always present)

### Adding new hardcoded chapters
Add to `KJVData.data` dictionary in `KJVBibleData.swift`.
Format: `"BookName": [chapterInt: [verseInt: "KJV text here."]]`
The KJV Bible is in the public domain (first published 1611).

---

## Code Quality Rules

### Do
- Use `ThemeColors` properties — never hardcode colors in views
- Use `BibleLoader.verses(book:chapter:)` — never call `KJVData` directly from views
- Use `@EnvironmentObject` for `ThemeManager`, `BibleViewModel`, `BibleDownloadManager`
- Use `NavigationLink(value:)` + `.navigationDestination` on iPhone
- Use `List(selection:)` bindings on iPad
- Keep views focused — extract subviews if a body exceeds ~80 lines
- Use `LazyVGrid` / `LazyVStack` for all scrollable content lists
- Gate all iOS 26 APIs with `#available(iOS 26.0, *)`
- Use `.themedSurface()` / `.themedGlass()` for consistent card styling

### Don't
- Don't hardcode hex colors — use `colors.accent`, `colors.surface`, etc.
- Don't use `NavigationLink { destination } label: { }` (old style) — breaks navigation state
- Don't use `NavigationLink` inside `NavigationSplitView` sidebar/content columns
- Don't call `.glassEffect()` without `#available(iOS 26.0, *)`
- Don't add a light mode — the app is always dark
- Don't use `.primary` / `.secondary` / `.accentColor` system colors in views
- Don't store mutable Bible data in `@State` — use `BibleViewModel`
- Don't add unnecessary abstraction — if something is used once, keep it inline
- Don't skip updating `project.pbxproj` when adding new Swift files

---

## When Adding a New Swift File

1. Create the file in `iKJV/`
2. Add a `PBXFileReference` entry in `project.pbxproj`
3. Add a `PBXBuildFile` entry in `project.pbxproj`
4. Add the `FileRef` to the `PBXGroup` children list
5. Add the `BuildFile` to the `PBXSourcesBuildPhase` files list
6. `Package.swift` auto-includes all `.swift` files in `iKJV/` — no change needed

UUID convention for pbxproj: use `BB000100000000000000XXXX` for FileRef and `AA000100000000000000XXXX` for BuildFile, incrementing `XXXX`.

---

## Git

- **Active branch**: `claude/bible-app-themes-dBJst`
- **Never push to** `main` or `master` without explicit instruction
- Commit messages: concise summary line + bullet points for major changes
- Always append `https://claude.ai/code/session_0111fodHo4RSsbMtzEDymFiZ` to commit messages
