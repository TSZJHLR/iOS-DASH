import SwiftUI

struct SplashView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            MainView()
        } else {
            SplashScreen()
                .onAppear {
                    runAnimations()
                }
        }
    }
    
    @ViewBuilder
    private func MainView() -> some View {
        if authViewModel.isAuthenticated {
            DashboardView()
        } else {
            ContentView()
        }
    }
    
    @ViewBuilder
    private func SplashScreen() -> some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            VStack {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("DASH")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(size)
            .opacity(opacity)
        }
        .preferredColorScheme(settingsManager.selectedTheme.colorScheme)
    }
    
    @MainActor
    private func runAnimations() {
        withAnimation(.easeIn(duration: 1.2)) {
            size = 1.0
            opacity = 1.0
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)  // 2 seconds delay
            isActive = true
        }
    }
}

// MARK: - Preview
#Preview {
    SplashView()
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsManager())
}
