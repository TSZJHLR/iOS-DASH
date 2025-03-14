import SwiftUI
import ARKit
import SceneKit

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingSettings = false
    @State private var selectedFeature: Feature?
    @State private var showFeatureDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Welcome section with user info
                    if let user = authViewModel.currentUser {
                        welcomeSection(user: user)
                    }
                    
                    // Quick stats section
                    statsSection()
                    
                    // Features grid
                    featuresSection()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink(destination: AboutUsView()) {
                            Image(systemName: "info.circle")
                        }
                        
                        NavigationLink(destination: SettingsView(settingsManager: settingsManager)) {
                            Image(systemName: "gear")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .sheet(isPresented: $showFeatureDetail) {
                if let feature = selectedFeature {
                    NavigationView {
                        featureDetailView(for: feature)
                            .navigationTitle(feature.rawValue)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showFeatureDetail = false
                                    }
                                }
                            }
                    }
                    .preferredColorScheme(settingsManager.selectedTheme.colorScheme)
                }
            }
        }
        .preferredColorScheme(settingsManager.selectedTheme.colorScheme)
    }
    
    private func featuresSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Features")
                .font(.title2)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(availableFeatures) { feature in
                    NavigationLink {
                        destinationView(for: feature)
                    } label: {
                        DashboardFeatureCard(feature: feature)
                    }
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    enum Feature: String, CaseIterable, Identifiable {
        case scanning = "3D Scanning"
        case arLearning = "AR Learning"
        case analytics = "Analytics"
        case renewableEnergy = "Renewable Energy"
        case reports = "Reports"
        case pointCloud = "Point Cloud"
        case modelExport = "Model Export"
        case userManagement = "User Management"
        case debugUser = "Debug User"
        case about = "About"
        case scanningWorkspace = "Scanning Workspace"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .scanning: return "camera.viewfinder"
            case .arLearning: return "brain.head.profile"
            case .analytics: return "chart.bar.fill"
            case .renewableEnergy: return "sun.max.fill"
            case .reports: return "chart.bar.doc.horizontal"
            case .pointCloud: return "point.3.connected.trianglepath.dotted"
            case .modelExport: return "square.and.arrow.up"
            case .userManagement: return "person.2.fill"
            case .debugUser: return "hammer.fill"
            case .about: return "info.circle"
            case .scanningWorkspace: return "cube.transparent.fill"
            }
        }
        
        var description: String {
            switch self {
            case .scanning: return "Scan objects and environments in 3D"
            case .arLearning: return "Learn through augmented reality"
            case .analytics: return "View your usage statistics"
            case .renewableEnergy: return "Explore renewable energy solutions"
            case .reports: return "View detailed reports and analytics"
            case .pointCloud: return "Visualize 3D point cloud data"
            case .modelExport: return "Export and share 3D models"
            case .userManagement: return "Manage user accounts and permissions"
            case .debugUser: return "Debug and test user features"
            case .about: return "Learn more about us"
            case .scanningWorkspace: return "Integrated 3D scanning, point cloud, and export"
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for feature: Feature) -> some View {
        switch feature {
        case .scanning:
            MeshCreationView()
        case .arLearning:
            ARLearningView()
        case .analytics:
            AnalyticsView()
        case .renewableEnergy:
            RenewableEnergyView()
        case .reports:
            ReportsView()
        case .pointCloud:
            PointCloudView()
        case .modelExport:
            ModelExportView(scanner: ScannerViewModel())
        case .userManagement:
            UserManagementView(authViewModel: authViewModel)
        case .debugUser:
            DemoUserView(authViewModel: authViewModel)
        case .about:
            AboutUsView()
        case .scanningWorkspace:
            ScanningWorkspaceView()
        }
    }
    
    private func welcomeSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // User avatar
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text(user.name.prefix(1).uppercased())
                        .font(.title)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading) {
                    Text("Welcome, \(user.name)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(user.role.displayName)
                        .font(.subheadline)
                        .padding(5)
                        .background(roleColor(for: user.role))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            Text("Here's what's happening today")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func statsSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Stats")
                .font(.headline)
            
            HStack {
                statCard(title: "Sessions", value: "12", icon: "chart.bar.fill", color: .blue)
                Spacer()
                statCard(title: "Progress", value: "68%", icon: "chart.pie.fill", color: .green)
                Spacer()
                statCard(title: "Tasks", value: "5", icon: "checklist", color: .orange)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80, height: 80)
        .padding(8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func featureCard(feature: Feature) -> some View {
        NavigationLink {
            destinationView(for: feature)
        } label: {
            FeatureCard(
                title: feature.rawValue,
                icon: feature.icon,
                color: .blue,
                action: {}
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func featureDetailView(for feature: Feature) -> some View {
        destinationView(for: feature)
    }
    
    private var availableFeatures: [Feature] {
        guard let userRole = authViewModel.currentUser?.role else {
            return []
        }
        
        switch userRole {
        case .admin:
            return [.scanningWorkspace, .scanning, .pointCloud, .modelExport, .userManagement, .debugUser, .about]
            
        case .student:
            return [.arLearning, .analytics, .renewableEnergy, .reports, .debugUser, .about]
            
        case .teacher:
            return [.arLearning, .analytics, .renewableEnergy, .reports, .debugUser, .about]
            
        case .professional:
            return [.scanningWorkspace, .scanning, .arLearning, .analytics, .renewableEnergy,  .analytics, .pointCloud, .modelExport, .debugUser, .about]
            
        case .demo:
            return [.scanningWorkspace, .scanning, .pointCloud, .modelExport, .userManagement, .debugUser, .about]
        }
    }
    
    private func roleColor(for role: UserRole) -> Color {
        switch role {
        case .admin:
            return .red
        case .teacher:
            return .blue
        case .student:
            return .green
        case .professional:
            return .purple
        case .demo:
            return .orange
        }
    }
}

struct DashboardFeatureCard: View {
    let feature: DashboardView.Feature
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.rawValue)
                    .font(.headline)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Navigation arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Previews
#Preview("Dashboard View") {
    DashboardView()
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsManager())
}
