import Foundation
import CryptoKit

class UserJSONManager {
    private let fileManager = FileManager.default
    private let documentsPath: String
    private let usersFilePath: String
    
    // Simple encryption key (in production, use more secure key management)
    private let encryptionKey = SymmetricKey(data: "YourSecretKey12345".data(using: .utf8)!)
    
    init() {
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        usersFilePath = (documentsPath as NSString).appendingPathComponent("users.json")
        
        print("UserJSONManager initialized")
        print("Users file path: \(usersFilePath)")
        
        // Create users file if it doesn't exist
        if !fileManager.fileExists(atPath: usersFilePath) {
            print("Users file doesn't exist, creating empty file")
            saveUsers([]) // Initialize with empty array
        } else {
            print("Users file already exists")
            
            // Check if the file is valid
            do {
                let encryptedData = try Data(contentsOf: URL(fileURLWithPath: usersFilePath))
                let _ = try decrypt(encryptedData)
            } catch {
                print("Error reading existing users file: \(error)")
                print("Recreating users file")
                saveUsers([]) // Reset with empty array if corrupted
            }
        }
        
        // Import default users immediately
        createDefaultUsers()
    }
    
    // Encrypt data
    private func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
        return sealedBox.combined!
    }
    
    // Decrypt data
    private func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: encryptionKey)
    }
    
    // Save users to file
    func saveUsers(_ users: [User]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(users)
            let encryptedData = try encrypt(data)
            try encryptedData.write(to: URL(fileURLWithPath: usersFilePath))
        } catch {
            print("Error saving users: \(error)")
        }
    }
    
    // Load users from file
    func loadUsers() -> [User] {
        do {
            let encryptedData = try Data(contentsOf: URL(fileURLWithPath: usersFilePath))
            let decryptedData = try decrypt(encryptedData)
            let decoder = JSONDecoder()
            let users = try decoder.decode([User].self, from: decryptedData)
            print("Loaded \(users.count) users from file")
            for user in users {
                print("- User: \(user.username), Role: \(user.role.rawValue)")
            }
            return users
        } catch {
            print("Error loading users: \(error)")
            return []
        }
    }
    
    // Add new user
    func addUser(_ user: User) {
        var users = loadUsers()
        users.append(user)
        saveUsers(users)
    }
    
    // Update existing user
    func updateUser(_ user: User) {
        var users = loadUsers()
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            saveUsers(users)
        }
    }
    
    // Delete user
    func deleteUser(id: String) {
        var users = loadUsers()
        users.removeAll(where: { $0.id == id })
        saveUsers(users)
    }
    
    // Verify credentials
    func verifyUser(username: String, password: String) -> User? {
        print("Attempting to verify user: \(username)")
        let users = loadUsers()
        let matchedUser = users.first { user in
            user.username.lowercased() == username.lowercased() && 
            user.password == password
        }
        
        if matchedUser != nil {
            print("User verified successfully: \(username)")
        } else {
            print("User verification failed for: \(username)")
        }
        
        return matchedUser
    }
    
    // Get all users
    func getAllUsers() -> [User] {
        return loadUsers()
    }
    
    // Check if username exists
    func usernameExists(_ username: String) -> Bool {
        let users = loadUsers()
        return users.contains(where: { $0.username.lowercased() == username.lowercased() })
    }
    
    // Create default users (always)
    func createDefaultUsers() {
        print("Creating default users...")
        
        let defaultUsers: [User] = [
            // Admin user
            User(
                id: UUID().uuidString,
                email: "admin@dashapp.com",
                username: "admin",
                name: "Admin User",
                password: "admin123",
                role: .admin
            ),
            
            // Student user
            User(
                id: UUID().uuidString,
                email: "student@dashapp.com",
                username: "student",
                name: "Student User",
                password: "student123",
                role: .student
            ),
            
            // Teacher user
            User(
                id: UUID().uuidString,
                email: "teacher@dashapp.com",
                username: "teacher",
                name: "Teacher User",
                password: "teacher123",
                role: .teacher
            ),
            
            // Professional user
            User(
                id: UUID().uuidString,
                email: "professional@dashapp.com",
                username: "professional",
                name: "Professional User",
                password: "pro123",
                role: .professional
            )
        ]
        
        saveUsers(defaultUsers)
        print("Default users created successfully")
    }
}
