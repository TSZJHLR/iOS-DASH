import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String
    let name: String
    let password: String
    let role: UserRole
}

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