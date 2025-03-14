import SwiftUI
import SwiftData

@MainActor
class UserDataManager: ObservableObject {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    convenience init() {
        guard let context = try? ModelContainer(for: UserModel.self).mainContext else {
            fatalError("Could not initialize ModelContainer")
        }
        self.init(modelContext: context)
    }
    
    func addUser(_ user: User) async {
        let userModel = UserModel(
            email: user.email,
            username: user.username,
            name: user.name,
            password: user.password,
            role: user.role
        )
        modelContext.insert(userModel)
        do {
            try modelContext.save()
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    func updateUser(_ user: User) async {
        let users = try? modelContext.fetch(FetchDescriptor<UserModel>())
        if let existingUser = users?.first(where: { $0.id == user.id }) {
            existingUser.email = user.email
            existingUser.name = user.name
            existingUser.password = user.password
            existingUser.role = user.role
            do {
                try modelContext.save()
            } catch {
                print("Failed to update user: \(error)")
            }
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
            }
        } catch {
            print("Failed to delete user: \(error)")
        }
    }
    
    func getAllUsers() async -> [User] {
        guard let userModels = try? modelContext.fetch(FetchDescriptor<UserModel>()) else {
            return []
        }
        
        return userModels.map { model in
            User(
                id: model.id,
                email: model.email,
                username: model.username,
                name: model.name,
                password: model.password,
                role: model.role
            )
        }
    }
    
    func verifyUser(username: String, password: String) async -> User? {
        guard let userModels = try? modelContext.fetch(FetchDescriptor<UserModel>()) else {
            return nil
        }
        
        let matchingUser = userModels.first { model in
            model.username.lowercased() == username.lowercased() && 
            model.password == password
        }
        
        return matchingUser.map { model in
            User(
                id: model.id,
                email: model.email,
                username: model.username,
                name: model.name,
                password: model.password,
                role: model.role
            )
        }
    }
}