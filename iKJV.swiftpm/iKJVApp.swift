import SwiftUI

@main
struct iKJVApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var viewModel = BibleViewModel()
    @StateObject private var downloadManager = BibleDownloadManager()

    // Persists across launches — once dismissed, never shown again
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                // Show onboarding on first launch if Bible not yet downloaded
                if !hasSeenOnboarding && !BibleLoader.jsonLoaded {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                } else {
                    ContentView()
                }
            }
            .environmentObject(themeManager)
            .environmentObject(viewModel)
            .environmentObject(downloadManager)
            .preferredColorScheme(.dark)
        }
    }
}
