import SwiftUI
import SceneKit
import Metal
import MetalKit
import ModelIO
import QuickLook
import ARKit

// Move ScanningMode enum outside the view
enum ScanningMode {
    case environment
    case object
    
    var instructions: String {
        switch self {
        case .environment:
            return "Move your device around to scan the environment. Keep a steady pace and maintain good lighting."
        case .object:
            return "Place the object on a flat surface. Move around it slowly to capture all sides."
        }
    }
}

struct MeshCreationView: View {
    @StateObject private var scannerViewModel = ScannerViewModel()
    @State private var showDebugView = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Scanning View
            mainScanningView
                .tabItem {
                    Label("Scan", systemImage: "camera.fill")
                }
                .tag(0)
            
            // Debug View
            ARDebugView(scanner: scannerViewModel)
                .tabItem {
                    Label("Debug", systemImage: "ladybug.fill")
                }
                .tag(1)
        }
        .alert(scannerViewModel.alertMessage, isPresented: $scannerViewModel.showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private var mainScanningView: some View {
        VStack {
            // AR View Container
            ARViewContainer(scannerViewModel: scannerViewModel)
                .edgesIgnoringSafeArea(.all)
            
            // Control Panel
            controlPanel
        }
    }
    
    private var controlPanel: some View {
        VStack(spacing: 15) {
            // Scanning Controls
            HStack {
                Button(action: {
                    scannerViewModel.toggleScanning()
                }) {
                    HStack {
                        Image(systemName: scannerViewModel.isScanning ? "stop.fill" : "record.circle")
                        Text(scannerViewModel.isScanning ? "Stop Scanning" : "Start Scanning")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(scannerViewModel.isScanning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            // Export Controls
            if scannerViewModel.hasMesh {
                VStack {
                    Picker("Export Format", selection: $scannerViewModel.exportFormat) {
                        ForEach(ScannerViewModel.ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    Button(action: {
                        scannerViewModel.exportMesh()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Mesh")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            
            // Status Information
            if !scannerViewModel.hasMesh && !scannerViewModel.isScanning {
                Text("Point device at surfaces to begin scanning")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if scannerViewModel.debugMode {
                Text(scannerViewModel.trackingState)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct ARViewContainer: UIViewRepresentable {
    let scannerViewModel: ScannerViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = scannerViewModel.sceneView
        
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

struct PointCloudOverlay: View {
    let points: [SIMD3<Float>]
    
    var body: some View {
        Canvas { context, size in
            for point in points {
                let x = CGFloat(point.x) * size.width + size.width / 2
                let y = CGFloat(point.y) * size.height + size.height / 2
                
                let rect = CGRect(x: x - 1, y: y - 1, width: 2, height: 2)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.5)))
            }
        }
    }
}

struct ExportOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var scanner: ScannerViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Export Format")) {
                    ForEach(ScannerViewModel.ExportFormat.allCases, id: \.self) { format in
                        Button(action: {
                            scanner.exportFormat = format
                            scanner.exportMesh()
                            dismiss()
                        }) {
                            HStack {
                                Text(format.rawValue)
                                Spacer()
                                Image(systemName: "arrow.right.circle")
                            }
                        }
                    }
                }
                
                Section(header: Text("Info")) {
                    Text("USDZ: Best for AR/iOS apps")
                    Text("PLY: Good for point clouds")
                    Text("STL: Best for 3D printing")
                    Text("OBJ: Universal 3D format")
                }
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MeshCreationView()
} 
