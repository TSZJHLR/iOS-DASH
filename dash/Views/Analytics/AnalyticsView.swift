import SwiftUI
import Charts
import AVFoundation

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: AnalyticsMetric = .energyConsumption
    @State private var showingScanner = false
    @State private var isScanning = false
    @State private var scanComplete = false
    @State private var recognizedDevice: IoTDevice?
    
    var body: some View {
        NavigationStack {
            mainContent
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
            Group {
                if viewModel.chartData.isEmpty || viewModel.summaryMetrics.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        timeRangeSelector
                        metricSelector
                        scanButton
                        scannedDevicesSection
                    }
                }
            }
        }
        .navigationTitle("Analytics")
        .toolbar { toolbarContent }
        .onChange(of: selectedTimeRange) { _, newValue in
            viewModel.updateData(timeRange: newValue, metric: selectedMetric)
        }
        .onChange(of: selectedMetric) { _, newValue in
            viewModel.updateData(timeRange: selectedTimeRange, metric: newValue)
        }
        .onChange(of: recognizedDevice) { _, newDevice in
            if let device = newDevice {
                viewModel.addScannedDevice(device)
            }
        }
        .fullScreenCover(isPresented: $showingScanner) {
            QRScannerView(
                isScanning: $isScanning,
                scanComplete: $scanComplete,
                recognizedDevice: $recognizedDevice,
                showingScanner: $showingScanner
            )
        }
    }
    
    private var emptyStateView: some View {
                    EmptyStateView(
                        icon: "chart.bar.xaxis",
                        title: "No Analytics Data Available",
                        message: "There's no data available for the selected metric and time range. Try selecting different options or check back later.",
                        actionTitle: "Reset Filters",
                        action: {
                            selectedTimeRange = .week
                            selectedMetric = .energyConsumption
                            viewModel.loadInitialData()
                        }
                    )
    }
    
    private var timeRangeSelector: some View {
                            Picker("Time Range", selection: $selectedTimeRange) {
                                ForEach(TimeRange.allCases) { range in
                                    Text(range.rawValue).tag(range)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
    }
                            
    private var metricSelector: some View {
                            Picker("Metric", selection: $selectedMetric) {
                                ForEach(AnalyticsMetric.allCases) { metric in
                                    Text(metric.title).tag(metric)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
    }
    
    private var scanButton: some View {
        Button(action: { showingScanner = true }) {
            HStack {
                Image(systemName: "qrcode.viewfinder")
                    .font(.title2)
                Text("Scan IoT Device")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
                            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private var scannedDevicesSection: some View {
                            VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Connected IoT Devices")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                Spacer()
                
                Text("\(viewModel.scannedDevices.count) devices")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            if viewModel.scannedDevices.isEmpty {
                Text("No devices connected")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.scannedDevices) { device in
                        DeviceInfoCard(device: device, viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Time Range", selection: $selectedTimeRange) {
                            ForEach(TimeRange.allCases) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        
                        Picker("Metric", selection: $selectedMetric) {
                            ForEach(AnalyticsMetric.allCases) { metric in
                                Text(metric.title).tag(metric)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
}

// MARK: - QR Scanner View
struct QRScannerView: View {
    @Binding var isScanning: Bool
    @Binding var scanComplete: Bool
    @Binding var recognizedDevice: IoTDevice?
    @Binding var showingScanner: Bool
    
    @State private var scanMessage = "Position QR code in the frame"
    @State private var torchIsOn = false
    @State private var cameraPermissionGranted = false
    @State private var showingPermissionAlert = false
    
    // Sample IoT devices for simulation
    private let sampleDevices = [
        IoTDevice(id: "1", name: "Smart Thermostat", type: .thermostat, manufacturer: "EcoTemp", energyRating: "A++", powerConsumption: "3.5W"),
        IoTDevice(id: "2", name: "Connected Light Bulb", type: .lightBulb, manufacturer: "LumiSmart", energyRating: "A+", powerConsumption: "7W"),
        IoTDevice(id: "3", name: "Smart Plug", type: .smartPlug, manufacturer: "PowerSense", energyRating: "A", powerConsumption: "1.2W"),
        IoTDevice(id: "4", name: "Energy Monitor", type: .energyMonitor, manufacturer: "WattWise", energyRating: "A+++", powerConsumption: "2.1W")
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Camera view
            if cameraPermissionGranted {
                CameraView(
                    isScanning: $isScanning,
                    scanMessage: $scanMessage,
                    torchIsOn: $torchIsOn,
                    onQRCodeDetected: { code in
                        handleQRCode(code)
                    }
                )
                .edgesIgnoringSafeArea(.all)
            } else {
                // Camera permission view
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Camera Access Required")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("This feature requires camera access to scan IoT device QR codes.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal)
                    
                    Button(action: {
                        requestCameraPermission()
                    }) {
                        Text("Allow Camera Access")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
            }
            
            // Torch and close buttons at the top
            VStack {
                HStack {
                    // Close button
                    Button(action: {
                        showingScanner = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // Torch button
                    if cameraPermissionGranted {
                        Button(action: {
                            toggleTorch()
                        }) {
                            Image(systemName: torchIsOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.title2)
                                .foregroundColor(torchIsOn ? .yellow : .white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                    }
                }
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .statusBarHidden()
        .onAppear {
            checkCameraPermission()
        }
        .alert("Camera Permission Required", isPresented: $showingPermissionAlert) {
            Button("Go to Settings", action: openSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please allow camera access in your device settings to use the QR scanner.")
        }
    }
    
    private func handleQRCode(_ code: String) {
        // For now, we'll simulate device detection with sample devices
        // In a real app, this would parse the QR code data
        if let device = sampleDevices.randomElement() {
            recognizedDevice = device
            scanMessage = "Device added: \(device.name)"
            
            // Reset scanning after a brief pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                scanMessage = "Position QR code in the frame"
            }
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionGranted = granted
                    if !granted {
                        showingPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            cameraPermissionGranted = false
            showingPermissionAlert = true
        @unknown default:
            cameraPermissionGranted = false
            showingPermissionAlert = true
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                cameraPermissionGranted = granted
                if !granted {
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if torchIsOn {
                    device.torchMode = .off
                } else {
                    try device.setTorchModeOn(level: 1.0)
                }
                device.unlockForConfiguration()
                torchIsOn.toggle()
            } catch {
                print("Torch could not be used")
            }
        }
    }
    
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

// Camera view using UIKit
struct CameraView: UIViewRepresentable {
    @Binding var isScanning: Bool
    @Binding var scanMessage: String
    @Binding var torchIsOn: Bool
    let onQRCodeDetected: (String) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        // Set up camera preview layer
        if let captureSession = context.coordinator.captureSession {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            // Add scanning frame
            let frameView = createScanningFrame()
            view.addSubview(frameView)
            
            // Add scanning message label
            let messageLabel = createMessageLabel()
            view.addSubview(messageLabel)
            
            // Set up constraints
            NSLayoutConstraint.activate([
                frameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                frameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                frameView.widthAnchor.constraint(equalToConstant: 280),
                frameView.heightAnchor.constraint(equalToConstant: 280),
                
                messageLabel.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 20),
                messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ])
            
            // Start running the session
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update preview layer frame
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.layer.bounds
        }
        
        // Update message label
        if let messageLabel = uiView.subviews.last as? UILabel {
            messageLabel.text = scanMessage
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createScanningFrame() -> UIView {
        let frameView = UIView(frame: .zero)
        frameView.translatesAutoresizingMaskIntoConstraints = false
        frameView.layer.borderColor = UIColor.white.cgColor
        frameView.layer.borderWidth = 3
        frameView.layer.cornerRadius = 12
        
        // Add corner indicators
        let corners = [
            ("arrow.down.left", CGPoint(x: -25, y: -25)),
            ("arrow.down.right", CGPoint(x: 305, y: -25)),
            ("arrow.up.left", CGPoint(x: -25, y: 305)),
            ("arrow.up.right", CGPoint(x: 305, y: 305))
        ]
        
        for (imageName, point) in corners {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(systemName: imageName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            imageView.contentMode = .scaleAspectFit
            frameView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 30),
                imageView.heightAnchor.constraint(equalToConstant: 30),
                imageView.leadingAnchor.constraint(equalTo: frameView.leadingAnchor, constant: point.x),
                imageView.topAnchor.constraint(equalTo: frameView.topAnchor, constant: point.y)
            ])
        }
        
        return frameView
    }
    
    private func createMessageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = scanMessage
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.padding = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return label
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CameraView
        var captureSession: AVCaptureSession?
        
        init(_ parent: CameraView) {
            self.parent = parent
            super.init()
            setupCaptureSession()
        }
        
        private func setupCaptureSession() {
            let captureSession = AVCaptureSession()
            
            // Begin configuration
            captureSession.beginConfiguration()
            
            // Set quality level
            if captureSession.canSetSessionPreset(.high) {
                captureSession.sessionPreset = .high
            }
            
            // Setup video input
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
                  let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
                print("Failed to create video input")
                return
            }
            
            guard captureSession.canAddInput(videoInput) else {
                print("Cannot add video input")
                return
            }
            
            captureSession.addInput(videoInput)
            
            // Setup metadata output
            let metadataOutput = AVCaptureMetadataOutput()
            
            guard captureSession.canAddOutput(metadataOutput) else {
                print("Cannot add metadata output")
                return
            }
            
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Check if QR code scanning is supported
            guard metadataOutput.availableMetadataObjectTypes.contains(.qr) else {
                print("QR code scanning not supported")
                return
            }
            
            metadataOutput.metadataObjectTypes = [.qr]
            
            // Set the scanning rect to match the frame view
            let scanRect = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
            metadataOutput.rectOfInterest = scanRect
            
            // Commit configuration
            captureSession.commitConfiguration()
            
            self.captureSession = captureSession
            
            // Start running the session
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard self.parent.isScanning else { return }
            
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let stringValue = metadataObject.stringValue {
                // Temporarily disable scanning while processing
                self.parent.isScanning = false
                
                // Process the QR code
                self.parent.onQRCodeDetected(stringValue)
                
                // Re-enable scanning after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.parent.isScanning = true
                }
            }
        }
    }
}

// Extension to add padding to UILabel
extension UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    var padding: UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets ?? .zero
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect.inset(by: padding))
    }
    
    override open var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                     height: size.height + padding.top + padding.bottom)
    }
}

// MARK: - Device Info Card
struct DeviceInfoCard: View {
    let device: IoTDevice
    @ObservedObject var viewModel: AnalyticsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with device info
            HStack {
                Image(systemName: device.type.iconName)
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(device.name)
                        .font(.headline)
                    Text(device.manufacturer)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Connected")
                    .font(.caption)
                    .padding(6)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(6)
            }
            
            Divider()
            
            // Device-specific metrics
            deviceSpecificMetrics
            
            Divider()
            
            // Action buttons
            HStack {
                NavigationLink(destination: IoTDeviceStatsView(device: device, viewModel: viewModel)) {
                    Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Device type specific action button
                deviceActionButton
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var deviceSpecificMetrics: some View {
        switch device.type {
        case .thermostat:
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    MetricItem(title: "Current Temp", value: "22°C", icon: "thermometer", color: .orange)
                    MetricItem(title: "Target Temp", value: "21°C", icon: "thermometer.sun", color: .blue)
                }
                HStack(spacing: 20) {
                    MetricItem(title: "Humidity", value: "45%", icon: "humidity", color: .cyan)
                    MetricItem(title: "Mode", value: "Auto", icon: "gear", color: .gray)
                }
            }
            
        case .lightBulb:
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    MetricItem(title: "Brightness", value: "75%", icon: "sun.max", color: .yellow)
                    MetricItem(title: "Color Temp", value: "2700K", icon: "light.max", color: .orange)
                }
                HStack(spacing: 20) {
                    MetricItem(title: "Status", value: "On", icon: "power", color: .green)
                    MetricItem(title: "Schedule", value: "Active", icon: "clock", color: .blue)
                }
            }
            
        case .smartPlug:
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    MetricItem(title: "Power Draw", value: device.powerConsumption, icon: "bolt", color: .orange)
                    MetricItem(title: "Daily Usage", value: "2.4 kWh", icon: "chart.bar", color: .blue)
                }
                HStack(spacing: 20) {
                    MetricItem(title: "Status", value: "Active", icon: "power", color: .green)
                    MetricItem(title: "Voltage", value: "120V", icon: "bolt.circle", color: .red)
                }
            }
            
        case .energyMonitor:
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    MetricItem(title: "Total Power", value: "1.2 kW", icon: "bolt", color: .orange)
                    MetricItem(title: "Grid Usage", value: "85%", icon: "chart.bar", color: .blue)
                }
                HStack(spacing: 20) {
                    MetricItem(title: "Peak Time", value: "2-4 PM", icon: "clock", color: .purple)
                    MetricItem(title: "Efficiency", value: device.energyRating, icon: "leaf", color: .green)
                }
            }
        }
    }
    
    @ViewBuilder
    private var deviceActionButton: some View {
        switch device.type {
        case .thermostat:
            Button(action: {}) {
                Label("Adjust", systemImage: "thermometer.sun")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
        case .lightBulb:
            Button(action: {}) {
                Label("Control", systemImage: "lightbulb.fill")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
        case .smartPlug:
            Button(action: {}) {
                Label("Toggle", systemImage: "power")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
        case .energyMonitor:
            Button(action: {}) {
                Label("Monitor", systemImage: "waveform.path.ecg")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}

// Helper view for device metrics
struct MetricItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 14))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - IoT Device Model
struct IoTDevice: Identifiable, Equatable {
    let id: String
    let name: String
    let type: DeviceType
    let manufacturer: String
    let energyRating: String
    let powerConsumption: String
    
    static func == (lhs: IoTDevice, rhs: IoTDevice) -> Bool {
        lhs.id == rhs.id
    }
}

enum DeviceType: Equatable {
    case thermostat
    case lightBulb
    case smartPlug
    case energyMonitor
    
    var iconName: String {
        switch self {
        case .thermostat:
            return "thermometer"
        case .lightBulb:
            return "lightbulb.fill"
        case .smartPlug:
            return "powerplug.fill"
        case .energyMonitor:
            return "chart.bar.fill"
        }
    }
}

// MARK: - Supporting Views
struct MetricCard: View {
    let metric: SummaryMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: metric.icon)
                    .foregroundColor(metric.color)
                Text(metric.title)
                    .font(.subheadline)
            }
            
            Text(metric.value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(metric.change)
                .font(.caption)
                .foregroundColor(metric.trend == .up ? .green : .red)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ChartView: View {
    let data: [ChartData]
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(Color.blue.gradient)
                
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(Color.blue.opacity(0.1))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5))
        }
    }
}

struct StatRow: View {
    let stat: DetailedStat
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stat.title)
                    .font(.subheadline)
                Text(stat.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(stat.value)
                .font(.headline)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - View Model
class AnalyticsViewModel: ObservableObject {
    @Published var summaryMetrics: [SummaryMetric] = []
    @Published var chartData: [ChartData] = []
    @Published var detailedStats: [DetailedStat] = []
    @Published var scannedDevices: [IoTDevice] = []
    
    init() {
        loadInitialData()
    }
    
    func updateData(timeRange: TimeRange, metric: AnalyticsMetric) {
        // Update data based on selected time range and metric
        loadSummaryMetrics(timeRange: timeRange, metric: metric)
        loadChartData(timeRange: timeRange, metric: metric)
        loadDetailedStats(timeRange: timeRange, metric: metric)
    }
    
    func loadInitialData() {
        loadSummaryMetrics(timeRange: .week, metric: .energyConsumption)
        loadChartData(timeRange: .week, metric: .energyConsumption)
        loadDetailedStats(timeRange: .week, metric: .energyConsumption)
    }
    
    private func loadSummaryMetrics(timeRange: TimeRange, metric: AnalyticsMetric) {
        // Sample data - replace with real data source
        summaryMetrics = [
            SummaryMetric(
                id: UUID(),
                title: "Energy Saved",
                value: "156 kWh",
                change: "+12% from last \(timeRange.rawValue)",
                trend: .up,
                icon: "bolt.fill",
                color: .green
            ),
            SummaryMetric(
                id: UUID(),
                title: "Carbon Reduction",
                value: "45 kg",
                change: "+15% from last \(timeRange.rawValue)",
                trend: .up,
                icon: "leaf.fill",
                color: .blue
            ),
            SummaryMetric(
                id: UUID(),
                title: "Learning Impact",
                value: "89%",
                change: "+8% from last \(timeRange.rawValue)",
                trend: .up,
                icon: "brain.head.profile",
                color: .orange
            ),
            SummaryMetric(
                id: UUID(),
                title: "Scanned Devices",
                value: "23",
                change: "+5 from last \(timeRange.rawValue)",
                trend: .up,
                icon: "qrcode.viewfinder",
                color: .purple
            )
        ]
    }
    
    private func loadChartData(timeRange: TimeRange, metric: AnalyticsMetric) {
        // Sample data - replace with real data source
        let dates = generateDates(for: timeRange)
        let (minValue, maxValue) = getValueRange(for: metric)
        
        chartData = dates.enumerated().map { index, date in
            ChartData(
                date: date,
                value: Double.random(in: minValue...maxValue)
            )
        }
    }
    
    private func generateDates(for timeRange: TimeRange) -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        var dates: [Date] = []
        
        let numberOfPoints: Int
        let component: Calendar.Component
        
        switch timeRange {
        case .day:
            numberOfPoints = 24
            component = .hour
        case .week:
            numberOfPoints = 7
            component = .day
        case .month:
            numberOfPoints = 30
            component = .day
        case .year:
            numberOfPoints = 12
            component = .month
        }
        
        for i in 0..<numberOfPoints {
            if let date = calendar.date(byAdding: component, value: -i, to: now) {
                dates.append(date)
            }
        }
        
        return dates.reversed()
    }
    
    private func loadDetailedStats(timeRange: TimeRange, metric: AnalyticsMetric) {
        switch metric {
        case .energyConsumption:
            detailedStats = [
                DetailedStat(
                    id: UUID(),
                    title: "Peak Usage Hours",
                    subtitle: "Highest consumption period",
                    value: "2-4 PM"
                ),
                DetailedStat(
                    id: UUID(),
                    title: "Device Efficiency",
                    subtitle: "Average energy rating",
                    value: "A+ (92%)"
                ),
                DetailedStat(
                    id: UUID(),
                    title: "Cost Savings",
                    subtitle: "Based on optimizations",
                    value: "$45.20/month"
                )
            ]
        case .renewableImpact:
            detailedStats = [
                DetailedStat(
                    id: UUID(),
                    title: "Solar Generation",
                    subtitle: "Daily average",
                    value: "12.5 kWh"
                ),
                DetailedStat(
                    id: UUID(),
                    title: "Grid Independence",
                    subtitle: "Renewable usage ratio",
                    value: "65%"
                ),
                DetailedStat(
                    id: UUID(),
                    title: "CO2 Offset",
                    subtitle: "Environmental impact",
                    value: "120kg this month"
                )
            ]
        case .learningProgress:
            detailedStats = [
                DetailedStat(
                    id: UUID(),
                    title: "Concepts Mastered",
                    subtitle: "Through AR interactions",
                    value: "15/20"
                ),
                DetailedStat(
                    id: UUID(),
                    title: "Practice Time",
                    subtitle: "In AR environment",
                    value: "8.5 hours"
                ),
                DetailedStat(
                    id: UUID(),
                    title: "Knowledge Retention",
                    subtitle: "Post-assessment score",
                    value: "92%"
                )
            ]
        case .sustainabilityScore:
            detailedStats = [
                DetailedStat(
                    id: UUID(),
                    title: "Overall Rating",
                    subtitle: "Building efficiency",
                    value: "85/100"
                ),
                DetailedStat(
                    id: UUID(),
                    title: "Improvement Areas",
                    subtitle: "Suggested optimizations",
                    value: "3 identified"
                ),
                DetailedStat(
                    id: UUID(),
                    title: "SDG 7 Alignment",
                    subtitle: "Goal progress",
                    value: "On Track"
                )
            ]
        }
    }
    
    private func getValueRange(for metric: AnalyticsMetric) -> (Double, Double) {
        switch metric {
        case .energyConsumption:
            return (50, 150) // kWh range
        case .renewableImpact:
            return (30, 80)  // Percentage range
        case .learningProgress:
            return (60, 100) // Score range
        case .sustainabilityScore:
            return (40, 100) // Rating range
        }
    }
    
    func addScannedDevice(_ device: IoTDevice) {
        // Only add if device isn't already in the list
        if !scannedDevices.contains(where: { $0.id == device.id }) {
            scannedDevices.append(device)
        }
    }
}

// MARK: - Models
enum TimeRange: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var id: String { rawValue }
}

enum AnalyticsMetric: String, CaseIterable, Identifiable {
    case energyConsumption = "Energy Usage"
    case renewableImpact = "Renewable Impact"
    case learningProgress = "Energy Education"
    case sustainabilityScore = "Sustainability Score"
    
    var id: String { rawValue }
    var title: String { rawValue }
}

enum Trend {
    case up, down
}

struct SummaryMetric: Identifiable {
    let id: UUID
    let title: String
    let value: String
    let change: String
    let trend: Trend
    let icon: String
    let color: Color
}

struct ChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct DetailedStat: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let value: String
}

// MARK: - IoT Device Detail View
struct IoTDeviceDetailView: View {
    let device: IoTDevice
    @ObservedObject var viewModel: AnalyticsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeRange: TimeRange = .week
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Device Header
                deviceHeader
                
                // Time Range Selector
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Device-specific Analytics Cards
                deviceAnalyticsCards
                
                // Device Stats Grid
                deviceStatsGrid
                
                // Energy Usage Chart
                energyUsageSection
                
                // Device Analytics
                deviceAnalyticsSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(device.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        // Add export action
                    }) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        // Add settings action
                    }) {
                        Label("Device Settings", systemImage: "gear")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onChange(of: selectedTimeRange) { _, newValue in
            // Update device-specific analytics when time range changes
            updateDeviceAnalytics()
        }
    }
    
    private var deviceHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: device.type.iconName)
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text(device.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(device.manufacturer)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("Connected", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text("Last updated: Just now")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private var deviceAnalyticsCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            // Device-specific metrics based on device type
            ForEach(getDeviceSpecificMetrics()) { metric in
                MetricCard(metric: metric)
            }
        }
        .padding()
    }
    
    private func getDeviceSpecificMetrics() -> [SummaryMetric] {
        switch device.type {
        case .thermostat:
            return [
                SummaryMetric(
                    id: UUID(),
                    title: "Temperature Control",
                    value: "22°C",
                    change: "-2°C from last \(selectedTimeRange.rawValue)",
                    trend: .down,
                    icon: "thermometer",
                    color: .orange
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Energy Saved",
                    value: "45 kWh",
                    change: "+15% from last \(selectedTimeRange.rawValue)",
                    trend: .up,
                    icon: "leaf.fill",
                    color: .green
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Runtime",
                    value: "6.5 hrs",
                    change: "-1.2 hrs from last \(selectedTimeRange.rawValue)",
                    trend: .down,
                    icon: "clock.fill",
                    color: .blue
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Cost Savings",
                    value: "$12.50",
                    change: "+$2.30 from last \(selectedTimeRange.rawValue)",
                    trend: .up,
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
            ]
            
        case .lightBulb:
            return [
                SummaryMetric(
                    id: UUID(),
                    title: "Brightness Level",
                    value: "75%",
                    change: "+5% from last \(selectedTimeRange.rawValue)",
                    trend: .up,
                    icon: "sun.max.fill",
                    color: .yellow
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Energy Saved",
                    value: "12 kWh",
                    change: "+8% from last \(selectedTimeRange.rawValue)",
                    trend: .up,
                    icon: "leaf.fill",
                    color: .green
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Usage Time",
                    value: "4.2 hrs",
                    change: "-0.8 hrs from last \(selectedTimeRange.rawValue)",
                    trend: .down,
                    icon: "clock.fill",
                    color: .blue
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Lifespan",
                    value: "95%",
                    change: "-2% from last \(selectedTimeRange.rawValue)",
                    trend: .down,
                    icon: "hourglass",
                    color: .purple
                )
            ]
            
        case .smartPlug:
            return [
                SummaryMetric(
                    id: UUID(),
                    title: "Power Draw",
                    value: "120W",
                    change: "-15W from last \(selectedTimeRange.rawValue)",
                    trend: .down,
                    icon: "bolt.fill",
                    color: .orange
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Energy Saved",
                    value: "35 kWh",
                    change: "+10% from last \(selectedTimeRange.rawValue)",
                    trend: .up,
                    icon: "leaf.fill",
                    color: .green
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Active Time",
                    value: "8.5 hrs",
                    change: "-1.5 hrs from last \(selectedTimeRange.rawValue)",
                    trend: .down,
                    icon: "clock.fill",
                    color: .blue
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Cost Impact",
                    value: "$8.20",
                    change: "-$1.50 from last \(selectedTimeRange.rawValue)",
                    trend: .down,
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
            ]
            
        case .energyMonitor:
            return [
                SummaryMetric(
                    id: UUID(),
                    title: "Total Energy",
                    value: "450 kWh",
                    change: "-25 kWh from last \(selectedTimeRange.rawValue)",
                    trend: .down,
                    icon: "chart.bar.fill",
                    color: .blue
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Peak Usage",
                    value: "3.2 kW",
                    change: "-0.4 kW from last \(selectedTimeRange.rawValue)",
                    trend: .down,
                    icon: "waveform.path.ecg",
                    color: .red
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Efficiency",
                    value: "92%",
                    change: "+3% from last \(selectedTimeRange.rawValue)",
                    trend: .up,
                    icon: "gauge",
                    color: .green
                ),
                SummaryMetric(
                    id: UUID(),
                    title: "Cost Tracking",
                    value: "$85.30",
                    change: "-$12.40 from last \(selectedTimeRange.rawValue)",
                    trend: .down,
                    icon: "dollarsign.circle.fill",
                    color: .purple
                )
            ]
        }
    }
    
    private func updateDeviceAnalytics() {
        // This would update the device-specific analytics based on the selected time range
        // For now, we're using static data, but in a real app, this would fetch new data
    }
    
    private var deviceStatsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            StatCard(title: "Energy Rating", value: device.energyRating, icon: "leaf.fill")
            StatCard(title: "Power Usage", value: device.powerConsumption, icon: "bolt.fill")
            StatCard(title: "Uptime", value: "99.8%", icon: "clock.fill")
            StatCard(title: "Efficiency", value: "95%", icon: "chart.line.uptrend.xyaxis")
        }
        .padding()
    }
    
    private var energyUsageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Energy Usage")
                .font(.headline)
                .padding(.horizontal)
            
            ChartView(data: generateDeviceChartData())
                .frame(height: 200)
                .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Peak Usage")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("2-4 PM")
                        .font(.body)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Daily Average")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("1.2 kWh")
                        .font(.body)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private var deviceAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Device Analytics")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(generateDeviceStats()) { stat in
                StatRow(stat: stat)
            }
        }
        .padding()
    }
    
    private func generateDeviceChartData() -> [ChartData] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<24).map { hour in
            let date = calendar.date(byAdding: .hour, value: -hour, to: now) ?? now
            return ChartData(date: date, value: Double.random(in: 10...50))
        }.reversed()
    }
    
    private func generateDeviceStats() -> [DetailedStat] {
        [
            DetailedStat(id: UUID(), title: "Peak Usage Time", subtitle: "Most active period", value: "2-4 PM"),
            DetailedStat(id: UUID(), title: "Energy Efficiency", subtitle: "Performance rating", value: "95%"),
            DetailedStat(id: UUID(), title: "Cost Impact", subtitle: "Monthly average", value: "$12.50"),
            DetailedStat(id: UUID(), title: "Carbon Footprint", subtitle: "Monthly reduction", value: "2.5 kg")
        ]
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Previews
#Preview("Analytics View") {
    AnalyticsView()
        .environmentObject(AnalyticsViewModel())
}

// Add new IoTDeviceStatsView
struct IoTDeviceStatsView: View {
    let device: IoTDevice
    @ObservedObject var viewModel: AnalyticsViewModel
    @State private var selectedTimeRange: TimeRange = .week
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time Range Selector
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Summary Cards Section
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(viewModel.summaryMetrics) { metric in
                        MetricCard(metric: metric)
                    }
                }
                .padding()
                
                // Chart Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Energy Usage Trends")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ChartView(data: viewModel.chartData)
                        .frame(height: 300)
                        .padding()
                }
                
                // Detailed Stats Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Detailed Statistics")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.detailedStats) { stat in
                        StatRow(stat: stat)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Device Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        // Add export action
                    }) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        // Add settings action
                    }) {
                        Label("Device Settings", systemImage: "gear")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onChange(of: selectedTimeRange) { _, newValue in
            viewModel.updateData(timeRange: newValue, metric: .energyConsumption)
        }
    }
}
