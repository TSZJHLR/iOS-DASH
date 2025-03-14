import SwiftUI
import SceneKit
import ARKit

struct ARSceneView: View {
    @ObservedObject var scanner: ScannerViewModel
    @State private var showingCameraPermissionAlert = false
    
    var body: some View {
        ZStack {
            SharedARContainer(scanner: scanner)
                .onAppear {
                    checkCameraPermission()
                }
            
            if !scanner.cameraAuthorized {
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Camera Access Required")
                        .font(.headline)
                        .padding(.top, 8)
                    Text("Please enable camera access in Settings to use AR features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Open Settings") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
            }
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            scanner.cameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    scanner.cameraAuthorized = granted
                    if !granted {
                        showingCameraPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            scanner.cameraAuthorized = false
            showingCameraPermissionAlert = true
        @unknown default:
            scanner.cameraAuthorized = false
            showingCameraPermissionAlert = true
        }
    }
}

#Preview {
    ARSceneView(scanner: ScannerViewModel())
        .frame(height: 300)
} 