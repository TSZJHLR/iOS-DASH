import SwiftUI
import ARKit
import SceneKit

struct ScanningWorkspaceView: View {
    @StateObject private var scanner = ScannerViewModel()
    @State private var selectedTab = 0
    @State private var showExportOptions = false
    @State private var exportFormat = "USDZ"
    @State private var exportName = "Scan_\(Date().timeIntervalSince1970)"
    @State private var showingExportSuccess = false
    
    private let exportFormats = ["USDZ", "OBJ", "STL", "PLY"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            Picker("Mode", selection: $selectedTab) {
                Text("3Scanning").tag(0)
                Text("Point Cloud").tag(1)
                Text("Export").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Content based on selected tab
            TabView(selection: $selectedTab) {
                // 3D Scanning Tab
                scanningView
                    .tag(0)
                
                // Point Cloud Tab
                pointCloudView
                    .tag(1)
                
                // Export Tab
                exportView
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("Scanning Workspace")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Toggle scanning
                    scanner.toggleScanning()
                }) {
                    Image(systemName: scanner.isScanning ? "stop.circle" : "record.circle")
                        .foregroundColor(scanner.isScanning ? .red : .green)
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showExportOptions) {
            exportOptionsView
        }
        .alert("Export Successful", isPresented: $showingExportSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your 3D model has been exported successfully.")
        }
        .environmentObject(scanner)
    }
    
    // MARK: - Scanning View
    private var scanningView: some View {
        VStack(spacing: 16) {
            // AR View for scanning
            ZStack {
                ScanningARViewContainer(scanner: scanner)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // Scanning status overlay
                if scanner.isScanning {
                    VStack {
                        Spacer()
                        HStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .opacity(scanner.pulseOpacity)
                                .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: scanner.pulseOpacity)
                            
                            Text("Recording")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                            
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        .padding(.leading, 8)
                    }
                }
            }
            
            // Scanning instructions
            VStack(alignment: .leading, spacing: 12) {
                Text("Scanning Instructions")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    instructionRow(icon: "arrow.left.and.right.circle", text: "Move slowly around the object")
                    instructionRow(icon: "light.max", text: "Ensure good lighting conditions")
                    instructionRow(icon: "camera.viewfinder", text: "Keep the object in frame")
                    instructionRow(icon: "hand.raised", text: "Avoid fast movements")
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Scanning controls
            HStack(spacing: 20) {
                Button(action: {
                    scanner.resetScanning()
                }) {
                    VStack {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                        Text("Reset")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    scanner.toggleScanning()
                }) {
                    VStack {
                        Image(systemName: scanner.isScanning ? "stop.circle" : "record.circle")
                            .font(.title2)
                        Text(scanner.isScanning ? "Stop" : "Start")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(scanner.isScanning ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                    .foregroundColor(scanner.isScanning ? .red : .green)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    selectedTab = 1 // Switch to point cloud view
                }) {
                    VStack {
                        Image(systemName: "point.3.connected.trianglepath.dotted")
                            .font(.title2)
                        Text("View")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.purple.opacity(0.1))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Point Cloud View
    private var pointCloudView: some View {
        VStack(spacing: 16) {
            // Point cloud visualization
            ZStack {
                PointCloudContainer(scanner: scanner)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                // Point count overlay
                VStack {
                    Spacer()
                    HStack {
                        Text("Points: \(scanner.pointCount)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                        
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    .padding(.leading, 8)
                }
            }
            
            // Point cloud controls
            VStack(alignment: .leading, spacing: 12) {
                Text("Visualization Controls")
                    .font(.headline)
                
                // Point size slider
                HStack {
                    Text("Point Size")
                        .font(.subheadline)
                    Slider(value: $scanner.pointSize, in: 1...10, step: 1)
                    Text("\(Int(scanner.pointSize))")
                        .frame(width: 30)
                }
                
                // Point density slider
                HStack {
                    Text("Density")
                        .font(.subheadline)
                    Slider(value: $scanner.pointDensity, in: 1...10, step: 1)
                    Text("\(Int(scanner.pointDensity))")
                        .frame(width: 30)
                }
                
                // Color mode picker
                HStack {
                    Text("Color Mode")
                        .font(.subheadline)
                    Picker("", selection: $scanner.colorMode) {
                        Text("RGB").tag(0)
                        Text("Depth").tag(1)
                        Text("Confidence").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Point cloud action buttons
            HStack(spacing: 20) {
                Button(action: {
                    scanner.resetVisualization()
                }) {
                    VStack {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                        Text("Reset")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    scanner.optimizePointCloud()
                }) {
                    VStack {
                        Image(systemName: "wand.and.stars")
                            .font(.title2)
                        Text("Optimize")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    selectedTab = 2 // Switch to export view
                }) {
                    VStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                        Text("Export")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Export View
    private var exportView: some View {
        VStack(spacing: 16) {
            // Model preview
            ZStack {
                ModelPreviewContainer(scanner: scanner)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Export options
            VStack(alignment: .leading, spacing: 12) {
                Text("Export Options")
                    .font(.headline)
                
                // File name
                HStack {
                    Text("File Name")
                        .font(.subheadline)
                    TextField("Enter file name", text: $exportName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Format picker
                HStack {
                    Text("Format")
                        .font(.subheadline)
                    Picker("", selection: $exportFormat) {
                        ForEach(exportFormats, id: \.self) { format in
                            Text(format).tag(format)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Quality picker
                HStack {
                    Text("Quality")
                        .font(.subheadline)
                    Picker("", selection: $scanner.exportQuality) {
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Export action buttons
            HStack(spacing: 20) {
                Button(action: {
                    scanner.processForExport()
                }) {
                    VStack {
                        Image(systemName: "wand.and.stars")
                            .font(.title2)
                        Text("Process")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    showExportOptions = true
                }) {
                    VStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                        Text("Export")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    scanner.shareModel()
                }) {
                    VStack {
                        Image(systemName: "square.and.arrow.up.on.square")
                            .font(.title2)
                        Text("Share")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.purple.opacity(0.1))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Export Options Sheet
    private var exportOptionsView: some View {
        NavigationView {
            Form {
                Section(header: Text("File Details")) {
                    TextField("File Name", text: $exportName)
                    
                    Picker("Format", selection: $exportFormat) {
                        ForEach(exportFormats, id: \.self) { format in
                            Text(format).tag(format)
                        }
                    }
                }
                
                Section(header: Text("Quality Settings")) {
                    Picker("Quality", selection: $scanner.exportQuality) {
                        Text("Low - Faster export, smaller file").tag(0)
                        Text("Medium - Balanced option").tag(1)
                        Text("High - Best quality, larger file").tag(2)
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                
                Section(header: Text("Additional Options")) {
                    Toggle("Include Textures", isOn: $scanner.includeTextures)
                    Toggle("Optimize Mesh", isOn: $scanner.optimizeMesh)
                }
                
                Section {
                    Button(action: {
                        // Perform export
                        scanner.exportModel(fileName: exportName, format: exportFormat)
                        showExportOptions = false
                        showingExportSuccess = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Export Model")
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showExportOptions = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private func instructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

// MARK: - AR View Container
struct ScanningARViewContainer: UIViewRepresentable {
    var scanner: ScannerViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        return scanner.sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Updates handled by the view model
    }
}

// MARK: - Point Cloud Container
struct PointCloudContainer: UIViewRepresentable {
    var scanner: ScannerViewModel
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scanner.pointCloudScene
        scnView.allowsCameraControl = true
        scnView.backgroundColor = .black
        scnView.autoenablesDefaultLighting = true
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Updates handled by the view model
    }
}

// MARK: - Model Preview Container
struct ModelPreviewContainer: UIViewRepresentable {
    var scanner: ScannerViewModel
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scanner.processedModelScene
        scnView.allowsCameraControl = true
        scnView.backgroundColor = .black
        scnView.autoenablesDefaultLighting = true
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Updates handled by the view model
    }
}

// MARK: - Previews
#Preview("Scanning Workspace") {
    NavigationView {
        ScanningWorkspaceView()
    }
} 
