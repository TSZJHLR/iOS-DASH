import SwiftUI
import SceneKit
import ARKit

struct ARLearningView: View {
    @StateObject private var scanner = ScannerViewModel()
    @State private var selectedTopic = 0
    @State private var showingQuiz = false
    
    let topics = [
        "Renewable Energy Basics",
        "Solar Panel Technology",
        "Wind Turbine Mechanics",
        "Hydroelectric Power"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // AR View with Camera
                ZStack {
                    LearningARContainer(scanner: scanner)
                    if scanner.cameraAuthorized {
                        ARLearningViewContainer(scanner: scanner)
                            .frame(height: 300)
                            .cornerRadius(12)
                    } else {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("Camera access required")
                                .foregroundColor(.gray)
                        }
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
                
                // Topic Selection
                Picker("Select Topic", selection: $selectedTopic) {
                    ForEach(0..<topics.count, id: \.self) { index in
                        Text(topics[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Learning Content
                VStack(alignment: .leading, spacing: 15) {
                    // Topic Title
                    Text(topics[selectedTopic])
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Interactive Elements
                    learningModules
                    
                    // Quiz Button
                    Button(action: {
                        showingQuiz = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Take Quiz")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("AR Learning")
        .sheet(isPresented: $showingQuiz) {
            QuizView(topic: topics[selectedTopic])
        }
        .alert("Camera Access", isPresented: $scanner.showAlert) {
            Button("Settings", action: openSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(scanner.alertMessage)
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private var learningModules: some View {
        VStack(spacing: 15) {
            moduleCard(
                title: "Introduction",
                description: "Learn the basic concepts and terminology",
                icon: "book.fill"
            )
            
            moduleCard(
                title: "Interactive 3D Models",
                description: "Explore components in 3D space",
                icon: "cube.fill"
            )
            
            moduleCard(
                title: "Real-world Applications",
                description: "See how the technology is used",
                icon: "globe"
            )
        }
        .padding(.horizontal)
    }
    
    private func moduleCard(title: String, description: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct ARLearningViewContainer: UIViewRepresentable {
    let scanner: ScannerViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        return scanner.sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update view if needed
    }
}

struct LearningARContainer: UIViewRepresentable {
    let scanner: ScannerViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = scanner.sceneView
        
        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Enable mesh reconstruction if supported
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        // Configure scene view
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [.showFeaturePoints] // This helps visualize the scanning
        
        // Start AR session
        sceneView.session.run(configuration)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update scene if needed
    }
}

struct QuizView: View {
    let topic: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Quiz for \(topic)")
                    .font(.title2)
                    .padding()
                
                Text("Quiz content will be implemented here")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ARLearningView()
    }
} 