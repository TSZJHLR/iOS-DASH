import SwiftUI

class AppState: ObservableObject {
    enum NavigationDestination {
        case home
        case scanning
        case userManagement
        case settings
        case about
    }
    
    @Published var currentDestination: NavigationDestination = .home
    
    func navigateTo(_ destination: NavigationDestination) {
        self.currentDestination = destination
    }
} 