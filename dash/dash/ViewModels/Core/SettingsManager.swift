import SwiftUI
import UIKit

class SettingsManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: Theme = .system {
        didSet {
            // This will trigger when theme changes
            applyTheme()
            NotificationCenter.default.post(name: .themeChanged, object: selectedTheme)
        }
    }
    @AppStorage("useNotifications") var useNotifications: Bool = true
    
    init() {
        // Set initial theme
        applyTheme()
        
        // Listen for theme changes
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(handleThemeChange),
                                             name: .themeChanged,
                                             object: nil)
    }
    
    @objc private func handleThemeChange(_ notification: Notification) {
        applyTheme()
    }
    
    private func applyTheme() {
        // Use the new API for iOS 15+
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = selectedTheme.uiInterfaceStyle
            }
        }
        
        // Force UI update
        objectWillChange.send()
    }
}

// Add notification name
extension Notification.Name {
    static let themeChanged = Notification.Name("themeChanged")
} 