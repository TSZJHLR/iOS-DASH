import SwiftUI
import SceneKit
import ModelIO
import SceneKit.ModelIO

struct ModelExportView: View {
    @State private var selectedFormat = ExportFormat.usdz
    @State private var isExporting = false
    @State private var exportProgress: Float = 0.0
    @State private var showingExportOptions = false
    @ObservedObject var scanner: ScannerViewModel
    
    enum ExportFormat: String, CaseIterable {
        case usdz = "USDZ"
        case obj = "OBJ"
        case ply = "PLY"
        case stl = "STL"
    }
    
    var body: some View {
        List {
            Section(header: Text("Export Settings")) {
                Picker("Format", selection: $selectedFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                
                if isExporting {
                    ProgressView(value: exportProgress) {
                        Text("Exporting Model...")
                    }
                    .progressViewStyle(.linear)
                }
            }
            
            Section(header: Text("Model Information")) {
                HStack {
                    Label("Vertices", systemImage: "point.3.connected.trianglepath.dotted")
                    Spacer()
                    Text("\(scanner.meshPoints.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("File Size", systemImage: "doc")
                    Spacer()
                    Text(estimatedFileSize)
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button(action: {
                    showingExportOptions = true
                }) {
                    HStack {
                        Text("Export Model")
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .disabled(isExporting || scanner.meshPoints.isEmpty)
            }
        }
        .navigationTitle("Export Model")
        .sheet(isPresented: $showingExportOptions) {
            exportOptionsSheet
        }
    }
    
    private var exportOptionsSheet: some View {
        NavigationView {
            List {
                Section(header: Text("Export Options")) {
                    Toggle("Optimize Mesh", isOn: .constant(true))
                    Toggle("Generate Normals", isOn: .constant(true))
                }
                
                Section(header: Text("Quality Settings")) {
                    Picker("Mesh Detail", selection: .constant(1)) {
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                }
                
                Section {
                    Button(action: {
                        showingExportOptions = false
                        exportModel()
                    }) {
                        Text("Start Export")
                    }
                }
            }
            .navigationTitle("Export Options")
            .navigationBarItems(trailing: Button("Cancel") {
                showingExportOptions = false
            })
        }
    }
    
    private var estimatedFileSize: String {
        let bytesPerVertex = 32 // Approximate bytes per vertex (position + normal)
        let totalBytes = scanner.meshPoints.count * bytesPerVertex
        
        if totalBytes < 1024 {
            return "\(totalBytes) B"
        } else if totalBytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(totalBytes) / 1024.0)
        } else {
            return String(format: "%.1f MB", Double(totalBytes) / (1024.0 * 1024.0))
        }
    }
    
    private func exportModel() {
        isExporting = true
        exportProgress = 0.0
        
        scanner.exportFormat = ScannerViewModel.ExportFormat(rawValue: selectedFormat.rawValue)!
        scanner.exportMesh()
        
        // Simulated export progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            exportProgress += 0.05
            if exportProgress >= 1.0 {
                timer.invalidate()
                isExporting = false
            }
        }
    }
}

#Preview {
    ModelExportView(scanner: ScannerViewModel())
} 