import ARKit
import RealityKit
import UIKit

class ARViewModel: NSObject, ObservableObject, ARSessionDelegate {
    @Published var lastCapture: UIImage?
    private var depthMapCounter = 0
    
    // Hold a reference to the current ARSession
    var session: ARSession?
    
    // Called when a new frame is captured
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // This method is called for each new frame
    }
    
    // Save depth map data to Documents directory
    func saveDepthMap() {
        guard let session = session, let currentFrame = session.currentFrame else {
            print("No current frame available")
            return
        }
        
        // Save color image
        if let colorImage = captureColorImage(from: currentFrame) {
            self.lastCapture = colorImage
        }
        
        // Capture and save depth data if available
        if let depthMap = currentFrame.sceneDepth?.depthMap {
            saveDepthData(depthMap: depthMap)
        } else {
            print("No depth data available")
        }
    }
    
    // Capture color image from the current frame
    private func captureColorImage(from frame: ARFrame) -> UIImage? {
        let pixelBuffer = frame.capturedImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("Failed to create CGImage")
            return nil
        }
        
        let image = UIImage(cgImage: cgImage)
        
        // Save RGB image to file
        if let data = image.jpegData(compressionQuality: 0.8) {
            let fileName = "scan_\(depthMapCounter)_color.jpg"
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                print("Saved color image to \(fileURL.path)")
            } catch {
                print("Failed to save color image: \(error)")
            }
        }
        
        return image
    }
    
    // Save depth data to a file
    private func saveDepthData(depthMap: CVPixelBuffer) {
        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap) else {
            print("Failed to get base address of depth map")
            return
        }
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
        let bufferSize = bytesPerRow * height
        
        let fileName = "scan_\(depthMapCounter)_depth.bin"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            let data = Data(bytes: baseAddress, count: bufferSize)
            try data.write(to: fileURL)
            print("Saved depth data (\(width)x\(height)) to \(fileURL.path)")
            
            // Create metadata file with dimensions info
            let metadataFileName = "scan_\(depthMapCounter)_metadata.json"
            let metadataURL = getDocumentsDirectory().appendingPathComponent(metadataFileName)
            
            let metadata: [String: Any] = [
                "width": width,
                "height": height,
                "bytesPerRow": bytesPerRow,
                "timestamp": Date().timeIntervalSince1970
            ]
            
            if let metadataData = try? JSONSerialization.data(withJSONObject: metadata) {
                try metadataData.write(to: metadataURL)
                print("Saved metadata to \(metadataURL.path)")
            }
            
            depthMapCounter += 1
        } catch {
            print("Failed to save depth data: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
} 