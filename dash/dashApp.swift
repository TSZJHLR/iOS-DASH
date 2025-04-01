import SwiftUI
import SwiftData

@main
struct dashApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var appState = AppState()
    
    let container: ModelContainer
    
    init() {
        // Configure SwiftData container with persistent storage
        let schema = Schema([UserModel.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false // This ensures data persists
        )
        
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(authViewModel)
                .environmentObject(settingsManager)
                .environmentObject(appState)
                .preferredColorScheme(settingsManager.selectedTheme.colorScheme)
        }
        .modelContainer(container) // Use our configured container
    }
}
