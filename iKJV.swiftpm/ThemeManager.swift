import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .dracula

    private let storageKey = "iKJV_selectedTheme"

    init() {
        if let saved = UserDefaults.standard.string(forKey: storageKey),
           let theme = AppTheme(rawValue: saved) {
            currentTheme = theme
        }
    }

    func setTheme(_ theme: AppTheme) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            currentTheme = theme
        }
        UserDefaults.standard.set(theme.rawValue, forKey: storageKey)
    }

    var colors: ThemeColors { currentTheme.colors }
}
