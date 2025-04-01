import SwiftUI

struct TeamMemberRow: View {
    let member: TeamMember
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: member.image)
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.headline)
                
                Text(member.role)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(member.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
} 