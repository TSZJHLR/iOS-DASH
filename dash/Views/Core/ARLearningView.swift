import SwiftUI
import SceneKit
import ARKit

struct ARLearningView: View {
    @StateObject private var arViewModel = ARViewModel()
    @State private var selectedTopic = 0
    @State private var showingQuiz = false
    
    let topics = [
        "Renewable Energy Basics",
        "Solar Panel Technology",
        "Wind Turbine Mechanics",
        "Hydroelectric Power"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // AR View with Camera
                ZStack {
                    Color(.systemGray6)
                        .frame(height: 300)
                        .cornerRadius(12)
                    
                    VStack {
                        Image(systemName: "arkit")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("AR Learning Experience")
                            .font(.headline)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal)
                
                // Topic Selector
                Picker("Select Topic", selection: $selectedTopic) {
                    ForEach(0..<topics.count, id: \.self) { index in
                        Text(topics[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Current Topic Content
                VStack(alignment: .leading, spacing: 15) {
                    Text(topics[selectedTopic])
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    learningContent(for: selectedTopic)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Quiz Button
                Button(action: {
                    showingQuiz = true
                }) {
                    Text("Take a Quiz")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("AR Learning")
            .sheet(isPresented: $showingQuiz) {
                QuizView(topic: topics[selectedTopic])
            }
        }
    }
    
    @ViewBuilder
    func learningContent(for topicIndex: Int) -> some View {
        switch topicIndex {
        case 0:
            renewableEnergyBasics
        case 1:
            solarPanelTechnology
        case 2:
            windTurbineMechanics
        case 3:
            hydroelectricPower
        default:
            Text("Content not available")
        }
    }
    
    var renewableEnergyBasics: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Renewable energy comes from naturally replenishing sources that are sustainable and often have a lower environmental impact than fossil fuels.")
                .font(.body)
            
            HStack(spacing: 20) {
                energyTypeCard(name: "Solar", icon: "sun.max.fill", color: .orange)
                energyTypeCard(name: "Wind", icon: "wind", color: .blue)
                energyTypeCard(name: "Hydro", icon: "drop.fill", color: .cyan)
            }
            
            Text("Interactive AR learning allows you to explore each energy source in 3D, understanding how they generate power and their environmental benefits.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
    }
    
    var solarPanelTechnology: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Solar panels convert sunlight into electricity through photovoltaic cells made of semiconductor materials, typically silicon.")
                .font(.body)
            
            Image("solar_panel_diagram")
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .cornerRadius(8)
            
            Text("Key Components:")
                .font(.headline)
                .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Photovoltaic Cells: Convert light into electricity")
                Text("• Inverter: Converts DC to AC electricity")
                Text("• Mounting System: Holds panels at optimal angle")
                Text("• Battery (optional): Stores excess energy")
            }
            .font(.subheadline)
        }
    }
    
    var windTurbineMechanics: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Wind turbines harness the kinetic energy in wind, converting it to mechanical energy and then to electricity.")
                .font(.body)
            
            Image("wind_turbine_diagram")
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .cornerRadius(8)
            
            Text("How Wind Turbines Work:")
                .font(.headline)
                .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("1. Wind turns the propeller-like blades")
                Text("2. Blades spin a low-speed shaft connected to a gearbox")
                Text("3. Gearbox increases rotational speed for the generator")
                Text("4. Generator converts mechanical energy to electricity")
            }
            .font(.subheadline)
        }
    }
    
    var hydroelectricPower: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hydroelectric power uses flowing water to spin turbines connected to generators, producing electricity without consuming water.")
                .font(.body)
            
            Image("hydro_power_diagram")
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .cornerRadius(8)
            
            Text("Hydropower System Components:")
                .font(.headline)
                .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Dam: Controls water flow and creates reservoir")
                Text("• Intake: Channels water to turbines")
                Text("• Turbine: Converts water's kinetic energy to mechanical")
                Text("• Generator: Produces electricity from turbine rotation")
                Text("• Transmission: Delivers electricity to the grid")
            }
            .font(.subheadline)
        }
    }
    
    private func energyTypeCard(name: String, icon: String, color: Color) -> some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(minWidth: 70)
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct QuizView: View {
    let topic: String
    @Environment(\.presentationMode) var presentationMode
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var showingResults = false
    
    // Sample questions for demonstration
    let questions = [
        Question(text: "Which renewable energy source uses photovoltaic cells?", 
                 options: ["Wind", "Solar", "Hydro", "Geothermal"], 
                 correctAnswerIndex: 1),
        Question(text: "What is the main component that converts wind energy to electricity?", 
                 options: ["Blades", "Tower", "Generator", "Nacelle"], 
                 correctAnswerIndex: 2),
        Question(text: "Which is NOT a renewable energy source?", 
                 options: ["Solar", "Wind", "Natural Gas", "Hydropower"], 
                 correctAnswerIndex: 2),
        Question(text: "What is the main advantage of renewable energy?", 
                 options: ["Low cost", "Sustainability", "Easy to transport", "Constant output"], 
                 correctAnswerIndex: 1),
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            if showingResults {
                // Quiz Results
                VStack(spacing: 25) {
                    Image(systemName: score > questions.count / 2 ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(score > questions.count / 2 ? .green : .red)
                    
                    Text("Quiz Complete!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("You scored \(score) out of \(questions.count)")
                        .font(.title3)
                    
                    Text(score > questions.count / 2 ? "Great job!" : "Keep learning!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.top, 20)
                }
                .padding()
                
            } else {
                // Current Question
                VStack(alignment: .leading, spacing: 20) {
                    Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(questions[currentQuestionIndex].text)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 12) {
                        ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                            Button(action: {
                                checkAnswer(index)
                            }) {
                                HStack {
                                    Text(questions[currentQuestionIndex].options[index])
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(topic)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func checkAnswer(_ selectedIndex: Int) {
        if selectedIndex == questions[currentQuestionIndex].correctAnswerIndex {
            score += 1
        }
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            showingResults = true
        }
    }
}

struct Question {
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
}

// MARK: - Preview
#Preview {
    ARLearningView()
} 