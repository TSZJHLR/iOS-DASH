import SwiftUI

struct ReportsView: View {
    @StateObject private var viewModel = ReportsViewModel()
    @State private var selectedReportType: ReportType = .energyEducation
    @State private var showingExportOptions = false
    @State private var selectedDateRange: DateRange = .lastWeek
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.reportItems.isEmpty {
                    EmptyStateView(
                        icon: "doc.text.magnifyingglass",
                        title: "No Reports Available",
                        message: "There are no reports available for the selected filters. Try changing your report type or date range.",
                        actionTitle: "Reset Filters",
                        action: {
                            selectedReportType = .energyEducation
                            selectedDateRange = .lastWeek
                            viewModel.loadInitialReport()
                        }
                    )
                } else {
                    List {
                        // Report Type Selection
                        Section(header: Text("Report Type")) {
                            Picker("Report Type", selection: $selectedReportType) {
                                ForEach(ReportType.allCases) { type in
                                    Text(type.title).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.vertical, 8)
                        }
                        
                        // Date Range Selection
                        Section(header: Text("Date Range")) {
                            Picker("Date Range", selection: $selectedDateRange) {
                                ForEach(DateRange.allCases) { range in
                                    Text(range.title).tag(range)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        // Report Preview
                        Section(header: Text("Preview")) {
                            ForEach(viewModel.reportItems) { item in
                                ReportItemRow(item: item)
                            }
                        }
                        
                        // Export Options
                        Section {
                            Button(action: { showingExportOptions = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Export Report")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reports")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Report Type", selection: $selectedReportType) {
                            ForEach(ReportType.allCases) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        
                        Picker("Date Range", selection: $selectedDateRange) {
                            ForEach(DateRange.allCases) { range in
                                Text(range.title).tag(range)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showingExportOptions) {
                ExportOptionsSheet(
                    reportType: selectedReportType,
                    dateRange: selectedDateRange,
                    onExport: viewModel.exportReport
                )
            }
            .onChange(of: selectedReportType) { _, newValue in
                viewModel.updateReport(type: newValue, dateRange: selectedDateRange)
            }
            .onChange(of: selectedDateRange) { _, newValue in
                viewModel.updateReport(type: selectedReportType, dateRange: newValue)
            }
        }
    }
}

// MARK: - Supporting Views
struct ReportItemRow: View {
    let item: ReportItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: item.icon)
                    .foregroundColor(item.color)
                Text(item.title)
                    .font(.headline)
            }
            
            if !item.subtitle.isEmpty {
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !item.details.isEmpty {
                Text(item.details)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let progress = item.progress {
                ProgressView(value: progress)
                    .tint(item.color)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExportOptionsSheet: View {
    let reportType: ReportType
    let dateRange: DateRange
    let onExport: (ExportFormat) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Export Format")) {
                    ForEach(ExportFormat.allCases) { format in
                        Button(action: {
                            onExport(format)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: format.icon)
                                Text(format.title)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Section(header: Text("Report Details")) {
                    LabeledContent("Type", value: reportType.title)
                    LabeledContent("Period", value: dateRange.title)
                }
            }
            .navigationTitle("Export Report")
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

// MARK: - View Model
class ReportsViewModel: ObservableObject {
    @Published var reportItems: [ReportItem] = []
    
    init() {
        loadInitialReport()
    }
    
    func updateReport(type: ReportType, dateRange: DateRange) {
        switch type {
        case .energyEducation:
            loadLearningReport(dateRange: dateRange)
        case .deviceAnalysis:
            loadTechnicalReport(dateRange: dateRange)
        case .sustainabilityMetrics:
            loadUsageReport(dateRange: dateRange)
        }
    }
    
    func loadInitialReport() {
        loadLearningReport(dateRange: .lastWeek)
    }
    
    private func loadLearningReport(dateRange: DateRange) {
        reportItems = [
            ReportItem(
                id: UUID(),
                title: "Renewable Energy Concepts",
                subtitle: "Interactive AR Learning Progress",
                details: "15 of 20 energy concepts mastered",
                progress: 0.75,
                icon: "brain.head.profile",
                color: .blue
            ),
            ReportItem(
                id: UUID(),
                title: "Practical Applications",
                subtitle: "Hands-on Energy Experiments",
                details: "8 experiments completed this \(dateRange.title.lowercased())",
                progress: nil,
                icon: "bolt.fill",
                color: .green
            ),
            ReportItem(
                id: UUID(),
                title: "Sustainability Knowledge",
                subtitle: "Clean Energy Understanding",
                details: "Advanced Level Achieved",
                progress: 0.85,
                icon: "leaf.fill",
                color: .orange
            )
        ]
    }
    
    private func loadTechnicalReport(dateRange: DateRange) {
        reportItems = [
            ReportItem(
                id: UUID(),
                title: "Device Energy Efficiency",
                subtitle: "Scanned Device Analysis",
                details: "Average Rating: A (92/100)",
                progress: 0.92,
                icon: "gauge",
                color: .purple
            ),
            ReportItem(
                id: UUID(),
                title: "Power Consumption",
                subtitle: "Device-specific metrics",
                details: "Total: 245 kWh, Peak: 3.2 kW",
                progress: nil,
                icon: "chart.bar.fill",
                color: .blue
            ),
            ReportItem(
                id: UUID(),
                title: "Optimization Potential",
                subtitle: "Energy Saving Opportunities",
                details: "Estimated 15% reduction possible",
                progress: 0.85,
                icon: "arrow.up.forward",
                color: .green
            )
        ]
    }
    
    private func loadUsageReport(dateRange: DateRange) {
        reportItems = [
            ReportItem(
                id: UUID(),
                title: "Carbon Footprint",
                subtitle: "Environmental Impact",
                details: "45% reduction from baseline",
                progress: 0.45,
                icon: "leaf.fill",
                color: .blue
            ),
            ReportItem(
                id: UUID(),
                title: "Renewable Usage",
                subtitle: "Clean Energy Ratio",
                details: "65% from renewable sources",
                progress: 0.65,
                icon: "sun.max.fill",
                color: .orange
            ),
            ReportItem(
                id: UUID(),
                title: "SDG 7 Progress",
                subtitle: "Goal Alignment",
                details: "On track for 2030 targets",
                progress: 0.78,
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
        ]
    }
    
    func exportReport(format: ExportFormat) {
        // Implementation for exporting energy and sustainability reports
        switch format {
        case .pdf:
            generatePDFReport()
        case .csv:
            exportCSVData()
        case .json:
            exportJSONData()
        }
    }
    
    private func generatePDFReport() {
        // Generate detailed PDF report with energy metrics and educational progress
        print("Generating PDF report with energy metrics and learning progress...")
    }
    
    private func exportCSVData() {
        // Export raw data for analysis
        print("Exporting energy consumption and learning data in CSV format...")
    }
    
    private func exportJSONData() {
        // Export structured data for integration with other systems
        print("Exporting JSON data for energy management systems...")
    }
}

// MARK: - Models
enum ReportType: String, CaseIterable, Identifiable {
    case energyEducation = "Energy Education"
    case deviceAnalysis = "Device Analysis"
    case sustainabilityMetrics = "Sustainability Metrics"
    
    var id: String { rawValue }
    var title: String { rawValue }
}

enum DateRange: String, CaseIterable, Identifiable {
    case today = "Today"
    case lastWeek = "Last 7 Days"
    case lastMonth = "Last 30 Days"
    case custom = "Custom Range"
    
    var id: String { rawValue }
    var title: String { rawValue }
}

enum ExportFormat: String, CaseIterable, Identifiable {
    case pdf = "PDF Document"
    case csv = "CSV Spreadsheet"
    case json = "JSON Data"
    
    var id: String { rawValue }
    var title: String { rawValue }
    
    var icon: String {
        switch self {
        case .pdf: return "doc.fill"
        case .csv: return "tablecells"
        case .json: return "curlybraces"
        }
    }
}

struct ReportItem: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let details: String
    let progress: Double?
    let icon: String
    let color: Color
}

// MARK: - Previews
#Preview("Reports View") {
    ReportsView()
}

#Preview("Report Item Row") {
    ReportItemRow(item: ReportItem(
        id: UUID(),
        title: "Energy Education Progress",
        subtitle: "Interactive Learning",
        details: "15 of 20 concepts mastered",
        progress: 0.75,
        icon: "brain.head.profile",
        color: .blue
    ))
    .padding()
} 