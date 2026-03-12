import SwiftUI

@main
struct iKJVApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var viewModel = BibleViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
