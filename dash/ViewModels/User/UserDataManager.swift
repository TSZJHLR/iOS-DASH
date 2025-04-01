import SwiftUI
import SwiftData

@MainActor
class UserDataManager: ObservableObject {
    let modelContext: ModelContext
    
    // Cache for users to avoid frequent database queries
    private var userCache: [String: UserModel] = [:]
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    convenience init() {
        guard let context = try? ModelContainer(for: UserModel.self).mainContext else {
            fatalError("Could not initialize ModelContainer")
        }
        self.init(modelContext: context)
    }
    
    func addUser(_ user: UserModel) async {
        modelContext.insert(user)
        do {
            try modelContext.save()
            // Update cache
            userCache[user.id] = user
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    func updateUser(_ user: UserModel) async {
        do {
            // Use a more efficient query with a predicate
            let descriptor = FetchDescriptor<UserModel>(
                predicate: #Predicate<UserModel> { $0.id == user.id }
            )
            
            if let existingUser = try modelContext.fetch(descriptor).first {
                existingUser.email = user.email
                existingUser.name = user.name
                existingUser.password = user.password
                existingUser.role = user.role
                try modelContext.save()
                
                // Update cache
                userCache[user.id] = existingUser
            }
        } catch {
            print("Failed to update user: \(error)")
        }
    }
    
    func deleteUser(id: String) async {
        let descriptor = FetchDescriptor<UserModel>(
            predicate: #Predicate<UserModel> { $0.id == id }
        )
        
        do {
            if let userToDelete = try modelContext.fetch(descriptor).first {
                modelContext.delete(userToDelete)
                try modelContext.save()
                
                // Remove from cache
                userCache.removeValue(forKey: id)
            }
        } catch {
            print("Failed to delete user: \(error)")
        }
    }
    
    func getAllUsers() async -> [UserModel] {
        do {
            let users = try modelContext.fetch(FetchDescriptor<UserModel>())
            
            // Update cache
            for user in users {
                userCache[user.id] = user
            }
            
            return users
        } catch {
            print("Failed to fetch users: \(error)")
            return []
        }
    }
    
    func getUserById(id: String) async -> UserModel? {
        // Check cache first
        if let cachedUser = userCache[id] {
            return cachedUser
        }
        
        // If not in cache, fetch from database
        let descriptor = FetchDescriptor<UserModel>(
            predicate: #Predicate<UserModel> { $0.id == id }
        )
        
        do {
            let user = try modelContext.fetch(descriptor).first
            
            // Update cache if found
            if let user = user {
                userCache[id] = user
            }
            
            return user
        } catch {
            print("Failed to fetch user by ID: \(error)")
            return nil
        }
    }
    
    func verifyUser(username: String, password: String) async -> UserModel? {
        // Fetch all users and filter manually since complex string operations
        // aren't supported in SwiftData predicates yet
        do {
            let users = try modelContext.fetch(FetchDescriptor<UserModel>())
            
            let matchedUser = users.first { user in
                user.username.lowercased() == username.lowercased() && 
                user.password == password
            }
            
            // Update cache if found
            if let matchedUser = matchedUser {
                userCache[matchedUser.id] = matchedUser
            }
            
            return matchedUser
        } catch {
            print("Failed to verify user: \(error)")
            return nil
        }
    }
    
    // Clear cache (useful for testing)
    func clearCache() {
        userCache.removeAll()
    }
}