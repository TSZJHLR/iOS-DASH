import SwiftUI

struct TeamMemberCard: View {
    let name: String
    let role: String
    let description: String
    let imageSystemName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: imageSystemName)
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text(name)
                .font(.headline)
            
            Text(role)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct MissionStatementView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let trend: Trend
    let trendValue: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: trend == .up ? "arrow.up.right" : "arrow.down.right")
                Text(trendValue)
            }
            .foregroundColor(trend == .up ? .green : .red)
            .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct FeatureCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

struct QuickStatsCard: View {
    let title: String
    let value: String
    let trend: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(trend)
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 