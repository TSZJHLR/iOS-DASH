import SwiftUI

struct TeamMemberPopupCard: View {
    let member: TeamMember
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with close button
            HStack {
                Spacer()
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // Profile Image
            Image(systemName: member.image)
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .frame(width: 120, height: 120)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            // Name and Role
            VStack(spacing: 4) {
                Text(member.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(member.role)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Description
            Text(member.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Academic Info
            VStack(spacing: 8) {
                Text("Academic Information")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Student ID")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(member.academicInfo.studentId)
                            .font(.subheadline)
                    }
                    
                    VStack(spacing: 4) {
                        Text("University ID")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(member.academicInfo.universityId)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Contact Info
            Link(destination: URL(string: "https://\(member.contactInfo.github)")!) {
                HStack {
                    Image(systemName: "link")
                    Text("GitHub Profile")
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 400))
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
    }
} 