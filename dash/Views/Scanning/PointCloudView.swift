import SwiftUI
import SceneKit
import ARKit

struct PointCloudView: View {
    @StateObject private var scanner = ScannerViewModel()
    @State private var isScanning = false
    @State private var scanningMode: ScanningMode = .object
    
    var body: some View {
        ZStack {
            if scanner.cameraAuthorized {
                SharedARContainer(scanner: scanner)
                    .edgesIgnoringSafeArea(.all)
            } else {
                // Camera Access Required View
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Camera Access Required")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("This feature requires camera access to create point cloud scans.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    
                    Button("Open Settings") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            
            if scanner.cameraAuthorized {
                VStack {
                    Spacer()
                    
                    // Scanning controls
                    VStack(spacing: 20) {
                        // Progress indicator
                        if isScanning {
                            ProgressView(value: Float(scanner.meshPoints.count) / 1000.0) {
                                Text("Scanning Progress")
                                    .foregroundColor(.white)
                            }
                            .progressViewStyle(.linear)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                        }
                        
                        // Control buttons
                        HStack(spacing: 30) {
                            Button(action: {
                                isScanning.toggle()
                                scanner.toggleScanning()
                            }) {
                                Label(isScanning ? "Stop Scan" : "Start Scan", 
                                      systemImage: isScanning ? "stop.fill" : "sensor")
                                    .padding()
                                    .background(isScanning ? Color.red : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            if !isScanning && !scanner.meshPoints.isEmpty {
                                Button(action: {
                                    scanner.exportMesh()
                                }) {
                                    Label("Export", systemImage: "square.and.arrow.up")
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(15)
                    .padding()
                }
            }
        }
        .navigationTitle("3D Scanner")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Scan Status", isPresented: $scanner.showAlert) {
            if !scanner.cameraAuthorized {
                Button("Settings", action: {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                })
                Button("Cancel", role: .cancel) { }
            } else {
                Button("OK", role: .cancel) { }
            }
        } message: {
            Text(scanner.alertMessage)
        }
    }
}

#Preview {
    PointCloudView()
} 