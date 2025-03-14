import SwiftUI
import SceneKit
import ARKit

struct SharedARContainer: UIViewRepresentable {
    var scanner: ScannerViewModel
    var configuration: ARWorldTrackingConfiguration?
    
    init(scanner: ScannerViewModel, configuration: ARWorldTrackingConfiguration? = nil) {
        self.scanner = scanner
        self.configuration = configuration
    }
    
    func makeUIView(context: Context) -> ARSCNView {
        scanner.sceneView.automaticallyUpdatesLighting = true
        scanner.sceneView.autoenablesDefaultLighting = true
        
        if let config = configuration {
            if scanner.cameraAuthorized {
                scanner.sceneView.session.run(config)
            }
        } else {
            // Default configuration if none provided
            let defaultConfig = ARWorldTrackingConfiguration()
            defaultConfig.environmentTexturing = .automatic
            defaultConfig.planeDetection = [.horizontal, .vertical]
            
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                defaultConfig.sceneReconstruction = .mesh
            }
            
            if scanner.cameraAuthorized {
                scanner.sceneView.session.run(defaultConfig)
            }
        }
        
        return scanner.sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if scanner.cameraAuthorized && uiView.session.configuration == nil {
            let config = configuration ?? {
                let defaultConfig = ARWorldTrackingConfiguration()
                defaultConfig.environmentTexturing = .automatic
                defaultConfig.planeDetection = [.horizontal, .vertical]
                if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                    defaultConfig.sceneReconstruction = .mesh
                }
                return defaultConfig
            }()
            
            uiView.session.run(config)
        }
    }
} 