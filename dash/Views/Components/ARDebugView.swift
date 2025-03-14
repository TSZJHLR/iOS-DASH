import SwiftUI
import ARKit

struct ARDebugView: View {
    @ObservedObject var scanner: ScannerViewModel
    
    var body: some View {
        VStack {
            // Device Capabilities Section
            deviceCapabilitiesSection
            
            // Tracking Status Section
            trackingStatusSection
            
            // Debug Controls Section
            debugControlsSection
            
            // Performance Metrics Section
            performanceMetricsSection
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var deviceCapabilitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Device Capabilities")
                .font(.headline)
            
            capabilityRow("World Tracking", 
                         isSupported: ARWorldTrackingConfiguration.isSupported)
            capabilityRow("Scene Reconstruction", 
                         isSupported: ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh))
            capabilityRow("Face Tracking", 
                         isSupported: ARFaceTrackingConfiguration.isSupported)
            capabilityRow("Camera Access", 
                         isSupported: scanner.cameraAuthorized)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var trackingStatusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tracking Status")
                .font(.headline)
            
            Text(scanner.trackingState)
                .foregroundColor(trackingStateColor)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var debugControlsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Debug Controls")
                .font(.headline)
            
            HStack {
                Toggle("Debug Mode", isOn: $scanner.debugMode)
                    .onChange(of: scanner.debugMode) { oldValue, newValue in
                        scanner.toggleDebugMode()
                    }
                
                Spacer()
                
                Button(action: {
                    scanner.toggleCamera()
                }) {
                    HStack {
                        Image(systemName: scanner.selectedCamera == .back ? "camera.rotate" : "camera")
                        Text(scanner.selectedCamera == .back ? "Front" : "Back")
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var performanceMetricsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Performance Metrics")
                .font(.headline)
            
            if scanner.debugMode {
                Group {
                    metricRow("Mesh Points", value: "\(scanner.meshPoints.count)")
                    metricRow("Has Mesh", value: scanner.hasMesh ? "Yes" : "No")
                    if scanner.showAlert && !scanner.alertMessage.isEmpty {
                        Text("⚠️ \(scanner.alertMessage)")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            } else {
                Text("Enable debug mode to see metrics")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private func capabilityRow(_ title: String, isSupported: Bool) -> some View {
        HStack {
            Image(systemName: isSupported ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isSupported ? .green : .red)
            Text(title)
            Spacer()
            Text(isSupported ? "Supported" : "Not Supported")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
    
    private func metricRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
    
    private var trackingStateColor: Color {
        switch scanner.trackingState {
        case let state where state.contains("❌"): return .red
        case let state where state.contains("⚠️"): return .orange
        case let state where state.contains("✅"): return .green
        default: return .primary
        }
    }
}

#Preview {
    ARDebugView(scanner: ScannerViewModel())
} 