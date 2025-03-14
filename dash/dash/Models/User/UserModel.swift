import SwiftData
import Foundation

@Model
final class UserModel {
    var id: String
    var email: String
    var username: String
    var name: String
    var password: String
    var role: UserRole
    var dateCreated: Date
    
    init(id: String = UUID().uuidString,
         email: String,
         username: String,
         name: String,
         password: String,
         role: UserRole) {
        self.id = id
        self.email = email
        self.username = username
        self.name = name
        self.password = password
        self.role = role
        self.dateCreated = Date()
    }
} 