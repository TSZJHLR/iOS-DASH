import SwiftUI
import SwiftData
import CryptoKit

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: UserModel?
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
        
        // Check for saved login session
        checkForSavedSession()
    }
    
    enum AuthMode {
        case login
        case signup
    }
    
    // Validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Validate password strength
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    // Hash password for comparison (in a real app, use a proper password hashing algorithm)
    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func login(username: String, password: String) async {
        guard !username.isEmpty, !password.isEmpty else {
            error = "Username and password cannot be empty"
            return
        }
        
        isLoading = true
        showSplash = false
        error = nil
        
        print("Login attempt for username: \(username)")
        
        // First check hardcoded credentials
        if let (storedPassword, role) = hardcodedCredentials[username.lowercased()], 
           storedPassword == password {
            print("Login successful using hardcoded credentials for: \(username)")
            
            // Create a user object from hardcoded credentials
            let user = UserModel(
                id: UUID().uuidString,
                email: "\(username)@dashapp.com",
                username: username.lowercased(),
                name: username.capitalized,
                password: password,
                role: role
            )
            
            isAuthenticated = true
            currentUser = user
            saveSession(user: user)
            isLoading = false
            return
        }
        
        // Then check database for users
        if let user = userJSONManager.verifyUser(username: username, password: password) {
            print("Login successful for: \(username)")
            isAuthenticated = true
            currentUser = user
            saveSession(user: user)
            isLoading = false
        } else {
            print("Login failed for: \(username)")
            error = "Invalid credentials"
            isLoading = false
        }
    }
    
    func signup(email: String, username: String, password: String, name: String) async {
        // Validate inputs
        guard !email.isEmpty, !username.isEmpty, !password.isEmpty, !name.isEmpty else {
            error = "All fields are required"
            isLoading = false
            return
        }
        
        guard isValidEmail(email) else {
            error = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        guard isValidPassword(password) else {
            error = "Password must be at least 6 characters long"
            isLoading = false
            return
        }
        
        isLoading = true
        error = nil
        
        // Check if username exists
        if userJSONManager.usernameExists(username) {
            error = "Username already exists"
            isLoading = false
            return
        }
        
        let newUser = UserModel(
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
        saveSession(user: newUser)
        isLoading = false
    }
    
    func resetPassword(email: String) {
        guard !email.isEmpty else {
            error = "Email cannot be empty"
            return
        }
        
        guard isValidEmail(email) else {
            error = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        error = nil
        
        // In a real app, this would send a password reset email
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            isLoading = false
            showForgotPassword = false
            error = nil
        }
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
        showSplash = true
        clearSavedSession()
    }
    
    func createDemoUser() {
        let demoUser = UserModel(
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
    
    // Save user session to UserDefaults
    private func saveSession(user: UserModel) {
        let userData: [String: Any] = [
            "id": user.id,
            "username": user.username,
            "isAuthenticated": true
        ]
        UserDefaults.standard.set(userData, forKey: "userSession")
    }
    
    // Check for saved session on app launch
    private func checkForSavedSession() {
        guard let userData = UserDefaults.standard.dictionary(forKey: "userSession"),
              let isAuthenticated = userData["isAuthenticated"] as? Bool,
              isAuthenticated,
              let username = userData["username"] as? String else {
            return
        }
        
        // Find user by username
        let users = userJSONManager.loadUsers()
        if let savedUser = users.first(where: { $0.username == username }) {
            self.currentUser = savedUser
            self.isAuthenticated = true
            self.showSplash = false
        }
    }
    
    // Clear saved session on logout
    private func clearSavedSession() {
        UserDefaults.standard.removeObject(forKey: "userSession")
    }
} 
