import SwiftUI
import SwiftData

struct UserRowView: View {
    let user: UserModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                Text(user.username)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(user.role.displayName)
                .font(.caption)
                .padding(5)
                .background(roleColor(for: user.role))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
    
    private func roleColor(for role: UserRole) -> Color {
        switch role {
        case .admin:
            return .red
        case .teacher:
            return .blue
        case .student:
            return .green
        case .professional:
            return .purple
        case .demo:
            return .orange
        }
    }
}

#Preview {
    UserRowView(user: UserModel(
        id: UUID().uuidString,
        email: "test@example.com",
        username: "testuser",
        name: "Test User",
        password: "password",
        role: .student
    ))
} 