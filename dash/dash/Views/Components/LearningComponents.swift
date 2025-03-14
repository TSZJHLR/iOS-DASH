import SwiftUI

struct LearningModule {
    let title: String
    let description: String
    let duration: String
    let difficulty: LearningDifficulty
    let progress: Double
}

enum LearningDifficulty {
    case beginner
    case intermediate
    case advanced
}

struct LearningModuleCard: View {
    let module: LearningModule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(module.title)
                .font(.headline)
            
            Text(module.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "clock")
                Text(module.duration)
                
                Spacer()
                
                Text(difficultyText)
                    .foregroundColor(difficultyColor)
            }
            .font(.caption)
            
            ProgressView(value: module.progress)
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var difficultyText: String {
        switch module.difficulty {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
    
    private var difficultyColor: Color {
        switch module.difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

struct LearningProgressView: View {
    let completedModules: Int
    let totalModules: Int
    let averageScore: Int
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                progressStat(
                    value: "\(completedModules)/\(totalModules)",
                    label: "Modules Completed",
                    icon: "checkmark.circle.fill",
                    color: .blue
                )
                
                Divider()
                
                progressStat(
                    value: "\(averageScore)%",
                    label: "Average Score",
                    icon: "star.fill",
                    color: .yellow
                )
            }
            
            ProgressView(value: Double(completedModules), total: Double(totalModules))
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func progressStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct Tutorial {
    let title: String
    let description: String
    let duration: String
    let difficulty: LearningDifficulty
    let icon: String
}

struct TutorialCard: View {
    let tutorial: Tutorial
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: tutorial.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(tutorial.title)
                    .font(.headline)
            }
            
            Text(tutorial.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "clock")
                Text(tutorial.duration)
                
                Spacer()
                
                Text(difficultyText)
                    .foregroundColor(difficultyColor)
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var difficultyText: String {
        switch tutorial.difficulty {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
    
    private var difficultyColor: Color {
        switch tutorial.difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
} 