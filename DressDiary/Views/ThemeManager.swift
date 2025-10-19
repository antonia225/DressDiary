import UIKit

enum ThemeManager {
    static func ensureStoredTheme() -> String {
        let defaults = UserDefaults.standard
        if let stored = defaults.string(forKey: "preferredTheme"), !stored.isEmpty {
            return stored
        }
        let fallback = CppBridge.getDarkMode() ? "dark" : "light"
        defaults.set(fallback, forKey: "preferredTheme")
        return fallback
    }

    static func currentSystemTheme() -> String {
        if let style = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .compactMap({ $0.windows.first?.traitCollection.userInterfaceStyle })
            .first {
            return style == .dark ? "dark" : "light"
        }
        return UITraitCollection.current.userInterfaceStyle == .dark ? "dark" : "light"
    }

    static func applyTheme(selectedTheme: String, syncWithSystem: Bool) {
        let themeToApply = syncWithSystem ? currentSystemTheme() : selectedTheme
        let isDark = (themeToApply == "dark")

        if !syncWithSystem {
            UserDefaults.standard.set(themeToApply, forKey: "preferredTheme")
        }

        CppBridge.setDarkMode(isDark)
        updateWindowsStyle(syncWithSystem ? .unspecified : (isDark ? .dark : .light))
    }

    static func updateWindowsStyle(_ style: UIUserInterfaceStyle) {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .forEach { scene in
                scene.windows.forEach { $0.overrideUserInterfaceStyle = style }
            }
    }
}
