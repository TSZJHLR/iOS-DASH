import SwiftUI

struct DemoUserView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var username = "testuser"
    @State private var password = "test123"
    @State private var email = "test@example.com"
    @State private var name = "Test User"
    @State private var selectedRole: UserRole = .admin
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Quick Login")) {
                    Button("Login as Admin") {
                        directLogin(role: .admin)
                    }
                    .foregroundColor(.blue)
                    
                    Button("Login as Student") {
                        directLogin(role: .student)
                    }
                    .foregroundColor(.green)
                    
                    Button("Login as Teacher") {
                        directLogin(role: .teacher)
                    }
                    .foregroundColor(.orange)
                    
                    Button("Login as Professional") {
                        directLogin(role: .professional)
                    }
                    .foregroundColor(.purple)
                }
                
                Section(header: Text("Demo Account Info")) {
                    Text("Username: demo")
                    Text("Password: demo123")
                    Text("Role: Admin")
                }
                
                if !message.isEmpty {
                    Section {
                        Text(message)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Demo Access")
        }
    }
    
    private func directLogin(role: UserRole) {
        let demoUser = UserModel(
            id: UUID().uuidString,
            email: "\(role)@dashapp.com",
            username: "\(role)",
            name: "\(role.displayName) User",
            password: "\(role)123",
            role: role
        )
        
        authViewModel.isAuthenticated = true
        authViewModel.currentUser = demoUser
        message = "Logged in as \(role.displayName)"
    }
}

// MARK: - Preview
#Preview {
    DemoUserView(authViewModel: AuthViewModel())
} 