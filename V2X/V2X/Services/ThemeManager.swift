// ThemeManager.swift
// V2X

import SwiftUI
import Combine

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var selectedTheme: MoodTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "v2x_theme")
        }
    }

    @Published var isAnimatingThemeChange = false

    var currentTheme: MoodTheme { selectedTheme }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "v2x_theme") ?? "Neon"
        self.selectedTheme = MoodTheme(rawValue: saved) ?? .neon
    }

    func setTheme(_ theme: MoodTheme) {
        withAnimation(.easeInOut(duration: 0.5)) {
            isAnimatingThemeChange = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.selectedTheme = theme
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.isAnimatingThemeChange = false
        }

        HapticManager.shared.triggerImpact(.light)
    }
}
