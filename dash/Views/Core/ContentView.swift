import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // call before loading
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showAuth = true
    
    var body: some View { // ui
        ZStack { // overlapping
            // Background - use a color that adapts to dark mode
            Color(UIColor.systemBackground)
                .overlay(
                    Color.blue.opacity(0.1)
                )
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) { //vertical
                // App Logo
                ZStack {
                    Circle()
                        .fill(Color(UIColor.systemBackground))
                        .shadow(radius: 10)
                        .frame(width: 150, height: 150)
                    
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                }
                
                // App Name
                Text("DASH")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Digital Augmented Study Hub")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Spacer()
                    .frame(height: 50)
                
                // Login Button
                Button(action: {
                    showAuth = true
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 220, height: 50)
                        .background(Color.blue)
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showAuth) {
            AuthView(isPresented: $showAuth)
        }
    }
    
    // Keep the Feature enum and related code for use in other views
    enum Feature: String, Identifiable, CaseIterable {
        case dashboard = "Dashboard"
        case analytics = "Analytics"
        case reports = "Reports"
        case settings = "Settings"
        case aboutUs = "About Us"
        // AR Features
        case arVisualization = "Energy Visualization"
        case arLearning = "AR Learning"
        case userManagement = "User Management"
        case demoUser = "Demo User"
        
        var id: String { rawValue }
        
        // computed property to get system icon name for each feature
        var icon: String {
            switch self {
            case .dashboard: return "square.grid.2x2"
            case .analytics: return "chart.bar"
            case .reports: return "doc.text"
            case .settings: return "gear"
            case .aboutUs: return "person.3.fill"
            case .arVisualization: return "bolt.circle"
            case .arLearning: return "book.fill"
            case .userManagement: return "person.2.fill"
            case .demoUser: return "person.fill.checkmark"
            }
        }
        
        // determine if feature requires authentication
        var requiresAuth: Bool {
            self != .aboutUs
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsManager())
} 

