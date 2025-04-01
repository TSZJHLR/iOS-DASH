import SwiftData
import Foundation

enum UserRole: String, Codable, CaseIterable {
    case admin
    case teacher
    case student
    case professional
    case demo
    
    var displayName: String {
        switch self {
        case .admin: return "Administrator"
        case .teacher: return "Teacher"
        case .student: return "Student"
        case .professional: return "Professional"
        case .demo: return "Demo User"
        }
    }
}

@Model
final class UserModel: Codable {
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
    
    // Codable implementation
    enum CodingKeys: CodingKey {
        case id, email, username, name, password, role, dateCreated
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        username = try container.decode(String.self, forKey: .username)
        name = try container.decode(String.self, forKey: .name)
        password = try container.decode(String.self, forKey: .password)
        role = try container.decode(UserRole.self, forKey: .role)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(username, forKey: .username)
        try container.encode(name, forKey: .name)
        try container.encode(password, forKey: .password)
        try container.encode(role, forKey: .role)
        try container.encode(dateCreated, forKey: .dateCreated)
    }
} 