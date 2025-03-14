import SwiftUI
import SwiftData

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?
    @Published var authMode: AuthMode = .login
    @Published var showForgotPassword = false
    @Published var selectedRole: UserRole = .student
    @Published var showSplash = true
    
    // Hardcoded credentials that will always work
    private let hardcodedCredentials: [String: (password: String, role: UserRole)] = [
        "admin": ("admin123", .admin),
        "student": ("student123", .student),
        "teacher": ("teacher123", .teacher),
        "professional": ("pro123", .professional)
    ]
    
    let userJSONManager: UserJSONManager
    
    init() {
        self.userJSONManager = UserJSONManager()
        
        // Add default users
        // Default users are now created in the UserJSONManager init
    }
    
    enum AuthMode {
        case login
        case signup
    }
    
    func login(username: String, password: String) async {
        isLoading = true
        showSplash = false
        
        print("Login attempt for username: \(username)")
        
        // First check hardcoded credentials
        if let (storedPassword, role) = hardcodedCredentials[username.lowercased()], 
           storedPassword == password {
            print("Login successful using hardcoded credentials for: \(username)")
            
            // Create a user object from hardcoded credentials
            let user = User(
                id: UUID().uuidString,
                email: "\(username)@dashapp.com",
                username: username.lowercased(),
                name: username.capitalized,
                password: password,
                role: role
            )
            
            isAuthenticated = true
            currentUser = user
            isLoading = false
            return
        }
        
        // Then check database for users
        if let user = userJSONManager.verifyUser(username: username, password: password) {
            print("Login successful for: \(username)")
            isAuthenticated = true
            currentUser = user
            isLoading = false
        } else {
            print("Login failed for: \(username)")
            error = "Invalid credentials"
            isLoading = false
        }
    }
    
    func signup(email: String, username: String, password: String, name: String) async {
        isLoading = true
        
        // Check if username exists
        if userJSONManager.usernameExists(username) {
            error = "Username already exists"
            isLoading = false
            return
        }
        
        let newUser = User(
            id: UUID().uuidString,
            email: email,
            username: username,
            name: name,
            password: password,
            role: selectedRole
        )
        
        userJSONManager.addUser(newUser)
        
        isAuthenticated = true
        currentUser = newUser
        isLoading = false
    }
    
    func resetPassword(email: String) {
        isLoading = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            isLoading = false
            showForgotPassword = false
        }
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
        showSplash = true
    }
    
    func createDemoUser() {
        let demoUser = User(
            id: UUID().uuidString,
            email: "demo@dashapp.com",
            username: "demo",
            name: "Demo User",
            password: "demo123",
            role: .demo
        )
        
        isAuthenticated = true
        currentUser = demoUser
    }
} 
