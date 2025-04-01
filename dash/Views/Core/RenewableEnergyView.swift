import SwiftUI
import SceneKit

struct RenewableEnergyView: View {
    @State private var selectedEnergyType: EnergyType = .solar
    @State private var showingInfo = false
    @StateObject private var arViewModel = ARViewModel()
    
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
                // Energy type selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(EnergyType.allCases, id: \.self) { type in
                            energyTypeButton(type)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Visualization
                VStack {
                    ZStack {
                        // 3D visualization placeholder
                        energyVisualization
                            .frame(height: 300)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    // Info panel
                    VStack(alignment: .leading, spacing: 12) {
                        Text(selectedEnergyType.rawValue)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(selectedEnergyType.description)
                            .font(.body)
                        
                        // Key metrics
                        energyMetrics
                            .padding(.top, 10)
                        
                        // Learn more button
                        Button {
                            showingInfo = true
                        } label: {
                            HStack {
                                Text("Learn More")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding()
                }
            }
            .navigationTitle("Renewable Energy")
            .sheet(isPresented: $showingInfo) {
                NavigationView {
                    InfoDetailView(energyType: selectedEnergyType)
                        .navigationTitle("\(selectedEnergyType.rawValue) Energy")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingInfo = false
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func energyTypeButton(_ type: EnergyType) -> some View {
        Button {
            selectedEnergyType = type
        } label: {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(selectedEnergyType == type ? .white : .blue)
                
                Text(type.rawValue)
                    .font(.caption)
                    .bold()
                    .foregroundColor(selectedEnergyType == type ? .white : .primary)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedEnergyType == type ? Color.blue : Color.blue.opacity(0.1))
            )
        }
    }
    
    private var energyVisualization: some View {
        ZStack {
            // AR visualization placeholder
            Image(energyTypeImageName)
                .resizable()
                .scaledToFit()
                .padding()
                .background(Color(.systemGray6))
            
            // Overlay with AR instructions
            VStack {
                Spacer()
                Text("Tap to explore in AR")
                    .font(.caption)
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.bottom, 10)
            }
        }
    }
    
    private var energyTypeImageName: String {
        switch selectedEnergyType {
        case .solar: return "solar_panel"
        case .wind: return "wind_turbine"
        case .hydro: return "hydro_dam"
        case .biomass: return "biomass_plant"
        }
    }
    
    private var energyMetrics: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                metricView(
                    value: selectedEnergyType == .solar ? "4-8 hrs" : 
                           selectedEnergyType == .wind ? "30-40%" : 
                           selectedEnergyType == .hydro ? "90%" : "70%",
                    label: "Efficiency",
                    icon: "chart.bar.fill"
                )
                
                metricView(
                    value: selectedEnergyType == .solar ? "25+ yrs" : 
                           selectedEnergyType == .wind ? "20+ yrs" : 
                           selectedEnergyType == .hydro ? "50+ yrs" : "15+ yrs",
                    label: "Lifespan",
                    icon: "clock.fill"
                )
            }
            
            HStack(spacing: 20) {
                metricView(
                    value: selectedEnergyType == .solar ? "Low" : 
                           selectedEnergyType == .wind ? "Very Low" : 
                           selectedEnergyType == .hydro ? "Low" : "Medium",
                    label: "Maintenance",
                    icon: "wrench.fill"
                )
                
                metricView(
                    value: selectedEnergyType == .solar ? "Zero" : 
                           selectedEnergyType == .wind ? "Zero" : 
                           selectedEnergyType == .hydro ? "Zero" : "Low",
                    label: "Emissions",
                    icon: "leaf.fill"
                )
            }
        }
    }
    
    private func metricView(value: String, label: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct InfoDetailView: View {
    let energyType: RenewableEnergyView.EnergyType
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero image
                Image(energyTypeDetailImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Overview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Overview")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(overviewText)
                            .font(.body)
                    }
                    
                    // How it works
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How It Works")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(howItWorksText)
                            .font(.body)
                    }
                    
                    // Environmental impact
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Environmental Impact")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(environmentalImpactText)
                            .font(.body)
                    }
                }
                .padding()
            }
            .padding(.bottom, 20)
        }
    }
    
    private var energyTypeDetailImage: String {
        switch energyType {
        case .solar: return "solar_detail"
        case .wind: return "wind_detail"
        case .hydro: return "hydro_detail"
        case .biomass: return "biomass_detail"
        }
    }
    
    private var overviewText: String {
        switch energyType {
        case .solar:
            return "Solar energy is radiant light and heat from the Sun that is harnessed using technologies such as solar panels. It is an essential source of renewable energy and its technologies are broadly characterized as either passive or active solar depending on how they capture and distribute solar energy."
        case .wind:
            return "Wind power is the use of air flow through wind turbines to mechanically power generators for electric power. Wind power, as an alternative to burning fossil fuels, is plentiful, renewable, widely distributed, clean, produces no greenhouse gas emissions during operation, and uses little land."
        case .hydro:
            return "Hydropower is power derived from the energy of falling or fast-running water, which may be harnessed for useful purposes. Hydroelectric power stations capture the energy of falling water to generate electricity. A turbine converts the kinetic energy of falling water into mechanical energy."
        case .biomass:
            return "Biomass is organic material that comes from plants and animals, and it is a renewable source of energy. Biomass contains stored energy from the sun. When biomass is burned, the chemical energy in biomass is released as heat and can generate electricity with a steam turbine."
        }
    }
    
    private var howItWorksText: String {
        switch energyType {
        case .solar:
            return "Photovoltaic cells convert sunlight directly into electricity. When sunlight hits the cells, it knocks electrons loose from their atoms. As the electrons flow through the cell, they generate electricity. Solar thermal technology uses the sun's energy to heat a fluid and produce steam that is used to power electricity generation equipment."
        case .wind:
            return "Wind turbines work by capturing the kinetic energy of the wind and converting it to electricity. When the wind blows, it turns the turbine's blades, which spin a shaft connected to a generator. The generator then produces electricity, which is sent through transmission and distribution lines to homes, businesses, and other users."
        case .hydro:
            return "Hydroelectric power is produced when water stored in a reservoir is released and flows through a turbine, spinning it, which in turn activates a generator to produce electricity. The amount of electricity generated depends on the volume of water and the height from which it falls. The faster and higher the water falls, the more power is generated."
        case .biomass:
            return "Biomass is converted to energy through several processes including: combustion (burning), which is used for heating and electricity generation; biochemical conversion, which includes fermentation to produce ethanol; and thermochemical conversion, which produces fuels like synthetic oils. Direct combustion is the most common method for converting biomass to energy."
        }
    }
    
    private var environmentalImpactText: String {
        switch energyType {
        case .solar:
            return "Solar energy produces no air pollution or greenhouse gases during operation. The manufacturing process for solar panels does involve some toxic materials and emissions, but the overall environmental impact is significantly less than fossil fuels. Solar farms require space, but can be built on existing structures or marginal land."
        case .wind:
            return "Wind energy has one of the lowest environmental impacts of any energy source. It produces no air or water pollution and requires no water for cooling. The main concerns are bird and bat mortality, noise, and visual impact. However, careful siting and newer designs have helped reduce these impacts."
        case .hydro:
            return "Hydropower produces no direct waste or pollution, but dam construction can disrupt river ecosystems and wildlife habitats. Large reservoirs can lead to methane emissions from decomposing vegetation. However, well-managed hydropower can provide flood control, irrigation, and recreational benefits alongside clean electricity."
        case .biomass:
            return "While biomass is carbon-neutral when new plants replace those used for energy (absorbing the CO2 released), there are concerns about land use, competition with food production, and air pollutants from burning. Sustainable biomass requires careful management of resources and efficient conversion technologies to minimize impacts."
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        RenewableEnergyView()
    }
} 
