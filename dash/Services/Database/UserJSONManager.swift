import Foundation
import CryptoKit
import SwiftData

class UserJSONManager {
    private let fileManager = FileManager.default
    private let documentsPath: String
    private let usersFilePath: String
    
    // Cache users to avoid frequent disk reads
    private var cachedUsers: [UserModel]?
    
    // Simple encryption key (in production, use more secure key management)
    private let encryptionKey: SymmetricKey
    
    init() {
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        usersFilePath = (documentsPath as NSString).appendingPathComponent("users.json")
        
        // Generate a more secure key using a password
        let password = "YourSecretKey12345".data(using: .utf8)!
        let hashedPassword = SHA256.hash(data: password)
        self.encryptionKey = SymmetricKey(data: hashedPassword)
        
        print("UserJSONManager initialized")
        print("Users file path: \(usersFilePath)")
        
        // Create users file if it doesn't exist
        if !fileManager.fileExists(atPath: usersFilePath) {
            print("Users file doesn't exist, creating default users")
            createDefaultUsers()
        } else {
            print("Users file already exists")
            
            // Check if the file is valid
            do {
                let _ = try loadUsersFromDisk()
            } catch {
                print("Error reading existing users file: \(error)")
                print("Recreating users file with default users")
                createDefaultUsers()
            }
        }
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
    private func saveUsersToDisk(_ users: [UserModel]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(users)
        let encryptedData = try encrypt(data)
        try encryptedData.write(to: URL(fileURLWithPath: usersFilePath), options: .atomic)
        
        // Update cache
        self.cachedUsers = users
    }
    
    // Load users from file
    private func loadUsersFromDisk() throws -> [UserModel] {
        let encryptedData = try Data(contentsOf: URL(fileURLWithPath: usersFilePath))
        let decryptedData = try decrypt(encryptedData)
        let decoder = JSONDecoder()
        return try decoder.decode([UserModel].self, from: decryptedData)
    }
    
    // Public method to get all users with caching
    func loadUsers() -> [UserModel] {
        // Return cached users if available
        if let cachedUsers = self.cachedUsers {
            return cachedUsers
        }
        
        do {
            let users = try loadUsersFromDisk()
            self.cachedUsers = users
            print("Loaded \(users.count) users from file")
            return users
        } catch {
            print("Error loading users: \(error)")
            return []
        }
    }
    
    // Add new user
    func addUser(_ user: UserModel) {
        var users = loadUsers()
        users.append(user)
        do {
            try saveUsersToDisk(users)
        } catch {
            print("Error saving user: \(error)")
        }
    }
    
    // Update existing user
    func updateUser(_ user: UserModel) {
        var users = loadUsers()
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            do {
                try saveUsersToDisk(users)
            } catch {
                print("Error updating user: \(error)")
            }
        }
    }
    
    // Delete user
    func deleteUser(id: String) {
        var users = loadUsers()
        users.removeAll(where: { $0.id == id })
        do {
            try saveUsersToDisk(users)
        } catch {
            print("Error deleting user: \(error)")
        }
    }
    
    // Verify credentials
    func verifyUser(username: String, password: String) -> UserModel? {
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
    func getAllUsers() -> [UserModel] {
        return loadUsers()
    }
    
    // Check if username exists
    func usernameExists(_ username: String) -> Bool {
        let users = loadUsers()
        return users.contains(where: { $0.username.lowercased() == username.lowercased() })
    }
    
    // Create default users
    func createDefaultUsers() {
        print("Creating default users...")
        
        let defaultUsers: [UserModel] = [
            // Admin user
            UserModel(
                id: UUID().uuidString,
                email: "admin@dashapp.com",
                username: "admin",
                name: "Admin User",
                password: "admin123",
                role: .admin
            ),
            
            // Student user
            UserModel(
                id: UUID().uuidString,
                email: "student@dashapp.com",
                username: "student",
                name: "Student User",
                password: "student123",
                role: .student
            ),
            
            // Teacher user
            UserModel(
                id: UUID().uuidString,
                email: "teacher@dashapp.com",
                username: "teacher",
                name: "Teacher User",
                password: "teacher123",
                role: .teacher
            ),
            
            // Professional user
            UserModel(
                id: UUID().uuidString,
                email: "professional@dashapp.com",
                username: "professional",
                name: "Professional User",
                password: "pro123",
                role: .professional
            )
        ]
        
        do {
            try saveUsersToDisk(defaultUsers)
            print("Default users created successfully")
        } catch {
            print("Error creating default users: \(error)")
        }
    }
    
    // Clear cache (useful when testing)
    func clearCache() {
        self.cachedUsers = nil
    }
}
