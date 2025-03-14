import SwiftUI
import SceneKit

struct RenewableEnergyView: View {
    @State private var selectedEnergyType: EnergyType = .solar
    @State private var showingInfo = false
    @StateObject private var scanner = ScannerViewModel()
    
    enum EnergyType: String, CaseIterable {
        case solar = "Solar"
        case wind = "Wind"
        case hydro = "Hydro"
        case biomass = "Biomass"
        
        var description: String {
            switch self {
            case .solar:
                return "Solar power harnesses energy from the sun using photovoltaic cells"
            case .wind:
                return "Wind turbines convert kinetic energy from moving air into electricity"
            case .hydro:
                return "Hydropower captures energy from flowing water to generate power"
            case .biomass:
                return "Biomass converts organic materials into usable energy"
            }
        }
        
        var icon: String {
            switch self {
            case .solar: return "sun.max.fill"
            case .wind: return "wind"
            case .hydro: return "drop.fill"
            case .biomass: return "leaf.fill"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Energy Type Selector
                Picker("Energy Type", selection: $selectedEnergyType) {
                    ForEach(EnergyType.allCases, id: \.self) { type in
                        Label(type.rawValue, systemImage: type.icon).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 3D Visualization
                ARSceneView(scanner: scanner)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // Energy Information
                VStack(spacing: 20) {
                    // Description Card
                    VStack(alignment: .leading, spacing: 10) {
                        Label(selectedEnergyType.rawValue, systemImage: selectedEnergyType.icon)
                            .font(.headline)
                        
                        Text(selectedEnergyType.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Statistics Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        statsCard(title: "Power Output", value: "245 kWh", icon: "bolt.circle.fill")
                        statsCard(title: "Efficiency", value: "87%", icon: "chart.line.uptrend.xyaxis")
                        statsCard(title: "CO2 Saved", value: "180 kg", icon: "leaf.circle.fill")
                        statsCard(title: "Cost Savings", value: "$127.50", icon: "dollarsign.circle.fill")
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Renewable Energy")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    energyInfoView
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
    }
    
    private func statsCard(title: String, value: String, icon: String) -> some View {
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
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var energyInfoView: some View {
        List {
            Section(header: Text("About \(selectedEnergyType.rawValue) Energy")) {
                Text(selectedEnergyType.description)
                    .padding(.vertical, 8)
            }
            
            Section(header: Text("Environmental Impact")) {
                impactRow(title: "CO2 Reduction", value: "180 kg/month")
                impactRow(title: "Trees Equivalent", value: "12 trees")
                impactRow(title: "Water Saved", value: "1,200 gallons")
            }
            
            Section(header: Text("Economic Benefits")) {
                impactRow(title: "Monthly Savings", value: "$127.50")
                impactRow(title: "ROI Period", value: "5-7 years")
                impactRow(title: "Maintenance Cost", value: "Low")
            }
        }
        .navigationTitle("\(selectedEnergyType.rawValue) Energy Info")
    }
    
    private func impactRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        RenewableEnergyView()
    }
} 
