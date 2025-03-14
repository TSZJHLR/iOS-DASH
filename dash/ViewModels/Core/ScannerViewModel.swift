import SwiftUI
import SceneKit
import ModelIO
import AVFoundation
import ARKit
import Metal
import RealityKit

class ScannerViewModel: NSObject, ObservableObject, ARSessionDelegate, ARSCNViewDelegate {
    @Published var isScanning = false
    @Published var hasMesh = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var meshPoints: [SIMD3<Float>] = []
    @Published var exportFormat: ExportFormat = .usdz
    @Published var cameraAuthorized = false
    @Published var trackingState: String = "Initializing..."
    @Published var debugMode: Bool = false
    @Published var selectedCamera: CameraPosition = .back
    
    let sceneView: ARSCNView
    private var scannedGeometry: MeshGeometry?
    private var debugOptions: ARSCNDebugOptions = []
    private var meshAnchors: [ARMeshAnchor] = []
    private var session: ARSession { sceneView.session }
    
    // MARK: - Debug Properties
    @Published var meshPointCount = 0
    @Published var frameRate: Double = 0
    @Published var deviceSupportsLiDAR: Bool
    @Published var worldTrackingSupported: Bool
    @Published var sceneReconstructionSupported: Bool
    
    // MARK: - Enums
    enum ExportFormat: String, CaseIterable {
        case usdz = "USDZ"
        case ply = "PLY"
        case stl = "STL"
        case obj = "OBJ"
    }
    
    enum CameraPosition {
        case front
        case back
    }
    
    enum TrackingQuality {
        case notAvailable
        case limited(reason: String)
        case normal
    }
    
    struct MeshGeometry {
        var vertices: [SIMD3<Float>]
        var normals: [SIMD3<Float>]
        var indices: [UInt32]
    }
    
    // MARK: - Point Cloud Methods
    @Published var pointSize: Double = 3.0
    @Published var pointDensity: Double = 5.0
    @Published var colorMode: Int = 0 // 0: RGB, 1: Depth, 2: Confidence
    @Published var pointCount: Int = 0
    @Published var pulseOpacity: Double = 0.5
    
    // MARK: - Export Methods
    @Published var exportQuality: Int = 1 // 0: Low, 1: Medium, 2: High
    @Published var includeTextures: Bool = true
    @Published var optimizeMesh: Bool = true
    
    // Scenes for different views
    var pointCloudScene = SCNScene()
    var processedModelScene = SCNScene()
    
    // MARK: - Initialization
    override init() {
        self.sceneView = ARSCNView(frame: .zero)
        deviceSupportsLiDAR = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
        worldTrackingSupported = ARWorldTrackingConfiguration.isSupported
        sceneReconstructionSupported = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
        
        super.init()
        
        setupScene()
        checkCameraAuthorization()
        setupDebugOptions()
    }
    
    // MARK: - Setup Methods
    private func setupScene() {
        verifyDeviceCapabilities()
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Enable statistics for debugging
        sceneView.showsStatistics = true
        sceneView.debugOptions = debugOptions
        
        // Setup point cloud scene
        setupPointCloudScene()
        
        // Setup processed model scene
        setupProcessedModelScene()
    }
    
    private func verifyDeviceCapabilities() {
        print("🔍 Checking device capabilities...")
        print("✓ ARWorldTrackingConfiguration supported: \(ARWorldTrackingConfiguration.isSupported)")
        print("✓ Scene reconstruction supported: \(ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh))")
        print("✓ Face tracking supported: \(ARFaceTrackingConfiguration.isSupported)")
        
        if !ARWorldTrackingConfiguration.isSupported {
            alertMessage = "AR World Tracking not supported on this device"
            showAlert = true
        }
    }
    
    private func setupDebugOptions() {
        debugOptions = [
            .showWorldOrigin,
            .showFeaturePoints,
            .showCameras
        ]
        updateDebugOptions()
    }
    
    private func setupPointCloudScene() {
        pointCloudScene = SCNScene()
        
        // Add a camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 5)
        pointCloudScene.rootNode.addChildNode(cameraNode)
        
        // Add ambient light
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.white
        pointCloudScene.rootNode.addChildNode(ambientLightNode)
    }
    
    private func setupProcessedModelScene() {
        processedModelScene = SCNScene()
        
        // Add a camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 5)
        processedModelScene.rootNode.addChildNode(cameraNode)
        
        // Add ambient light
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.white
        processedModelScene.rootNode.addChildNode(ambientLightNode)
        
        // Add directional light
        let directionalLightNode = SCNNode()
        directionalLightNode.light = SCNLight()
        directionalLightNode.light?.type = .directional
        directionalLightNode.light?.color = UIColor.white
        directionalLightNode.position = SCNVector3(5, 5, 5)
        directionalLightNode.eulerAngles = SCNVector3(-Float.pi/4, Float.pi/4, 0)
        processedModelScene.rootNode.addChildNode(directionalLightNode)
    }
    
    // MARK: - Camera Configuration
    func toggleCamera() {
        selectedCamera = selectedCamera == .back ? .front : .back
        configureCameraSession()
    }
    
    private func configureCameraSession() {
        switch selectedCamera {
        case .back:
            let configuration = ARWorldTrackingConfiguration()
            configuration.environmentTexturing = .automatic
            configuration.planeDetection = [.horizontal, .vertical]
            
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                configuration.sceneReconstruction = .mesh
            }
            
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            print("📸 Configured back camera with world tracking")
            
        case .front:
            if ARFaceTrackingConfiguration.isSupported {
                let configuration = ARFaceTrackingConfiguration()
                sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                print("🤳 Configured front camera with face tracking")
            } else {
                alertMessage = "Face tracking not supported on this device"
                showAlert = true
                selectedCamera = .back
                configureCameraSession()
            }
        }
    }
    
    // MARK: - Debug Methods
    func toggleDebugMode() {
        debugMode.toggle()
        updateDebugOptions()
        print("🐛 Debug mode: \(debugMode ? "enabled" : "disabled")")
    }
    
    private func updateDebugOptions() {
        sceneView.debugOptions = debugMode ? debugOptions : []
    }
    
    private func updateTrackingInfo(_ camera: ARCamera) {
        let quality: TrackingQuality
        switch camera.trackingState {
        case .notAvailable:
            quality = .notAvailable
        case .limited(let reason):
            let reasonStr: String
            switch reason {
            case .excessiveMotion: reasonStr = "excessive motion"
            case .insufficientFeatures: reasonStr = "insufficient features"
            case .initializing: reasonStr = "initializing"
            case .relocalizing: reasonStr = "relocalizing"
            @unknown default: reasonStr = "unknown"
            }
            quality = .limited(reason: reasonStr)
        case .normal:
            quality = .normal
        }
        
        DispatchQueue.main.async {
            switch quality {
            case .notAvailable:
                self.trackingState = "❌ Tracking not available"
            case .limited(let reason):
                self.trackingState = "⚠️ Limited tracking: \(reason)"
            case .normal:
                self.trackingState = "✅ Tracking normal"
            }
        }
    }
    
    // MARK: - Performance Monitoring
    private func updatePerformanceMetrics() {
        if let frame = sceneView.session.currentFrame {
            frameRate = Double(frame.timestamp)
        }
        meshPointCount = meshAnchors.reduce(0) { $0 + ($1.geometry.vertices.count) }
    }
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0
        }
        return 0
    }
    
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.cameraAuthorized = true
            // Configure and run session
            let configuration = ARWorldTrackingConfiguration()
            configuration.environmentTexturing = .automatic
            configuration.planeDetection = [.horizontal, .vertical]
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                configuration.sceneReconstruction = .mesh
            }
            sceneView.session.run(configuration)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraAuthorized = granted
                    if granted {
                        // Configure and run session
                        let configuration = ARWorldTrackingConfiguration()
                        configuration.environmentTexturing = .automatic
                        configuration.planeDetection = [.horizontal, .vertical]
                        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                            configuration.sceneReconstruction = .mesh
                        }
                        self?.sceneView.session.run(configuration)
                    } else {
                        self?.showCameraAccessAlert()
                    }
                }
            }
        case .denied, .restricted:
            self.cameraAuthorized = false
            showCameraAccessAlert()
        @unknown default:
            self.cameraAuthorized = false
            showCameraAccessAlert()
        }
    }
    
    private func showCameraAccessAlert() {
        alertMessage = "Camera access is required for AR features. Please enable it in Settings."
        showAlert = true
    }
    
    func toggleScanning() {
        guard cameraAuthorized else {
            showCameraAccessAlert()
            return
        }
        
        isScanning.toggle()
        if isScanning {
            meshAnchors.removeAll()
            hasMesh = false
            startScanning()
        } else {
            stopScanning()
        }
    }
    
    func resetScanning() {
        // Stop scanning if currently scanning
        if isScanning {
            stopScanning()
            isScanning = false
        }
        
        // Clear all mesh data
        meshPoints.removeAll()
        meshAnchors.removeAll()
        hasMesh = false
        
        // Reset the session
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = [.horizontal, .vertical]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        alertMessage = "Scanning reset"
        showAlert = true
    }
    
    func startScanning() {
        meshPoints.removeAll()
        hasMesh = false
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = [.horizontal, .vertical]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func stopScanning() {
        // Pause the session without arguments
        sceneView.session.pause()
        
        // Only set hasMesh to true if we actually collected some points
        if !meshPoints.isEmpty {
            hasMesh = true
            alertMessage = "Scan completed with \(meshPoints.count) points captured"
            showAlert = true
        } else {
            alertMessage = "No points were captured during scanning"
            showAlert = true
        }
    }
    
    func exportMesh() {
        guard hasMesh else {
            alertMessage = "No mesh data available to export"
            showAlert = true
            return
        }
        
        // Export mesh based on selected format
        switch exportFormat {
        case .usdz:
            exportUSDZ()
        case .ply:
            exportPLY()
        case .stl:
            exportSTL()
        case .obj:
            exportOBJ()
        }
    }
    
    private func exportUSDZ() {
        guard let meshGeometry = scannedGeometry else {
            alertMessage = "No mesh data available"
            showAlert = true
            return
        }
        
        // Create a new SCNNode with the mesh geometry
        let meshNode = SCNNode()
        let vertices = meshGeometry.vertices
        let normals = meshGeometry.normals
        let indices = meshGeometry.indices
        
        let vertexSource = SCNGeometrySource(vertices: vertices.map { SCNVector3($0.x, $0.y, $0.z) })
        let normalSource = SCNGeometrySource(normals: normals.map { SCNVector3($0.x, $0.y, $0.z) })
        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<UInt32>.size)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: indices.count / 3, bytesPerIndex: MemoryLayout<UInt32>.size)
        
        let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
        meshNode.geometry = geometry
        
        // Create a temporary USDZ file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("scan.usdz")
        
        // Create a scene and convert to MDLAsset
        let scene = SCNScene()
        scene.rootNode.addChildNode(meshNode)
        
        do {
            // Convert SCNScene to MDLAsset
            let asset = MDLAsset(scnScene: scene)
            
            // Export to USDZ
            try asset.export(to: tempURL)
            
            alertMessage = "Mesh exported successfully to: \(tempURL.path)"
            showAlert = true
        } catch {
            alertMessage = "Failed to export mesh: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func exportPLY() {
        guard let meshGeometry = scannedGeometry else {
            alertMessage = "No mesh data available"
            showAlert = true
            return
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("scan.ply")
        var plyString = "ply\nformat ascii 1.0\n"
        plyString += "element vertex \(meshGeometry.vertices.count)\n"
        plyString += "property float x\nproperty float y\nproperty float z\n"
        plyString += "property float nx\nproperty float ny\nproperty float nz\n"
        plyString += "element face \(meshGeometry.indices.count / 3)\n"
        plyString += "property list uchar int vertex_indices\nend_header\n"
        
        // Add vertices and normals
        for i in 0..<meshGeometry.vertices.count {
            let vertex = meshGeometry.vertices[i]
            let normal = meshGeometry.normals[i]
            plyString += "\(vertex.x) \(vertex.y) \(vertex.z) \(normal.x) \(normal.y) \(normal.z)\n"
        }
        
        // Add faces
        for i in stride(from: 0, to: meshGeometry.indices.count, by: 3) {
            plyString += "3 \(meshGeometry.indices[i]) \(meshGeometry.indices[i+1]) \(meshGeometry.indices[i+2])\n"
        }
        
        do {
            try plyString.write(to: tempURL, atomically: true, encoding: .utf8)
            alertMessage = "Mesh exported successfully to: \(tempURL.path)"
            showAlert = true
        } catch {
            alertMessage = "Failed to export mesh: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func exportSTL() {
        // Implementation for STL export
    }
    
    private func exportOBJ() {
        // Implementation for OBJ export
    }
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("❌ AR Session failed:")
        print("Error: \(error.localizedDescription)")
        if let arError = error as? ARError {
            print("AR Error Code: \(arError.code)")
            print("AR Error Description: \(arError.errorUserInfo)")
        }
        alertMessage = "AR Session failed: \(error.localizedDescription)"
        showAlert = true
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateTrackingInfo(camera)
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if debugMode {
            updatePerformanceMetrics()
        }
        
        // Update pulse opacity for recording indicator
        DispatchQueue.main.async {
            self.pulseOpacity = self.isScanning ? (self.pulseOpacity == 0.5 ? 1.0 : 0.5) : 0.5
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard isScanning, let meshAnchor = anchor as? ARMeshAnchor else { return }
        meshAnchors.append(meshAnchor)
        hasMesh = true
        
        if debugMode {
            updatePerformanceMetrics()
        }
        
        let geometry = meshAnchor.geometry
        // Convert mesh geometry to our format
        var vertices: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        
        // Get vertices
        let vertexPointer = geometry.vertices.buffer.contents()
        let vertexCount = geometry.vertices.count
        let vertexStride = geometry.vertices.stride
        for i in 0..<vertexCount {
            let vertex = vertexPointer.advanced(by: i * vertexStride).assumingMemoryBound(to: SIMD3<Float>.self).pointee
            vertices.append(vertex)
        }
        
        // Get normals
        let normalPointer = geometry.normals.buffer.contents()
        let normalCount = geometry.normals.count
        let normalStride = geometry.normals.stride
        for i in 0..<normalCount {
            let normal = normalPointer.advanced(by: i * normalStride).assumingMemoryBound(to: SIMD3<Float>.self).pointee
            normals.append(normal)
        }
        
        // Get face indices
        let indexPointer = geometry.faces.buffer.contents()
        let indexCount = geometry.faces.count * 3
        for i in 0..<indexCount {
            let index = indexPointer.advanced(by: i * MemoryLayout<UInt32>.size).assumingMemoryBound(to: UInt32.self).pointee
            indices.append(index)
        }
        
        // Store the mesh data
        scannedGeometry = MeshGeometry(
            vertices: vertices,
            normals: normals,
            indices: indices
        )
        
        // Update mesh points for visualization
        meshPoints = vertices
        
        // Update UI
        hasMesh = true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard isScanning, let meshAnchor = anchor as? ARMeshAnchor,
              let index = meshAnchors.firstIndex(where: { $0.identifier == meshAnchor.identifier }) else { return }
        meshAnchors[index] = meshAnchor
        
        if debugMode {
            updatePerformanceMetrics()
        }
        
        // Update mesh points for visualization
        let geometry = meshAnchor.geometry
        let vertexPointer = geometry.vertices.buffer.contents()
        let vertexCount = geometry.vertices.count
        let vertexStride = geometry.vertices.stride
        
        var vertices: [SIMD3<Float>] = []
        for i in 0..<vertexCount {
            let vertex = vertexPointer.advanced(by: i * vertexStride).assumingMemoryBound(to: SIMD3<Float>.self).pointee
            vertices.append(vertex)
        }
        
        meshPoints = vertices
    }
    
    // MARK: - Point Cloud Methods
    func updatePointCloudVisualization() {
        // This would update the point cloud visualization based on the current settings
        // For now, we'll just update the point count
        pointCount = meshPoints.count
    }
    
    func resetVisualization() {
        // Reset visualization settings
        pointSize = 3.0
        pointDensity = 5.0
        colorMode = 0
    }
    
    func optimizePointCloud() {
        // Simulate optimization by reducing the number of points
        if !meshPoints.isEmpty {
            // Remove about 20% of points randomly
            let originalCount = meshPoints.count
            meshPoints = Array(meshPoints.shuffled().prefix(Int(Double(originalCount) * 0.8)))
            pointCount = meshPoints.count
            
            alertMessage = "Optimized point cloud: Removed \(originalCount - pointCount) points"
            showAlert = true
        } else {
            alertMessage = "No points to optimize"
            showAlert = true
        }
    }
    
    // MARK: - Export Methods
    func processForExport() {
        // Process the mesh for export
        if hasMesh {
            alertMessage = "Model processed successfully"
            showAlert = true
        } else {
            alertMessage = "No mesh data available to process"
            showAlert = true
        }
    }
    
    func exportModel(fileName: String, format: String) {
        // Export the model with the given file name and format
        let formatEnum = ExportFormat.allCases.first { $0.rawValue == format } ?? .usdz
        exportFormat = formatEnum
        exportMesh()
    }
    
    func shareModel() {
        // Share the model
        alertMessage = "Sharing functionality would be implemented here"
        showAlert = true
    }
}

// MARK: - ARCamera.TrackingState.Reason Extension
private extension ARCamera.TrackingState.Reason {
    var description: String {
        switch self {
        case .initializing: return "Initializing"
        case .excessiveMotion: return "Excessive motion"
        case .insufficientFeatures: return "Insufficient features"
        case .relocalizing: return "Relocalizing"
        @unknown default: return "Unknown"
        }
    }
} 