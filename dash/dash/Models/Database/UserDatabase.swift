import Foundation
import CryptoKit

class UserDatabase {
    private let fileManager = FileManager.default
    private let documentsPath: String
    private let usersFilePath: String
    
    // simple encryption key (in production, use more secure key management)
    private let encryptionKey = SymmetricKey(data: "YourSecretKey12345".data(using: .utf8)!)
    
    init() {
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        usersFilePath = (documentsPath as NSString).appendingPathComponent("users.json")
        
        // create users file if it doesn't exist
        if !fileManager.fileExists(atPath: usersFilePath) {
            saveUsers([]) // Initialize with empty array
        }
    }
    
    // encrypt data
    private func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
        return sealedBox.combined!
    }
    
    // decrypt data
    private func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: encryptionKey)
    }
    
    // save users to file
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
    
    // load users from file
    func loadUsers() -> [User] {
        do {
            let encryptedData = try Data(contentsOf: URL(fileURLWithPath: usersFilePath))
            let decryptedData = try decrypt(encryptedData)
            let decoder = JSONDecoder()
            return try decoder.decode([User].self, from: decryptedData)
        } catch {
            print("Error loading users: \(error)")
            return []
        }
    }
    
    // add new user
    func addUser(_ user: User) {
        var users = loadUsers()
        users.append(user)
        saveUsers(users)
    }
    
    // verify credentials
    func verifyUser(username: String, password: String) -> User? {
        let users = loadUsers()
        return users.first { user in
            user.username.lowercased() == username.lowercased() && 
            user.password == password // in production, use proper password hashing
        }
    }
} 
