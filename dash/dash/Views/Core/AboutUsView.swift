import SwiftUI

struct AboutUsView: View {
    @State private var selectedTab = 0
    
    // App information
    private let appVersion = "1.0.0"
    private let appFeatures = [
        AppFeature(title: "3D Scanning", description: "Advanced scanning capabilities using ARKit for precise 3D model creation", icon: "camera.viewfinder"),
        AppFeature(title: "AR Learning", description: "Interactive augmented reality learning experiences", icon: "brain.head.profile"),
        AppFeature(title: "Analytics", description: "Comprehensive data analysis and visualization tools", icon: "chart.bar.fill"),
        AppFeature(title: "Renewable Energy", description: "Explore and learn about sustainable energy solutions", icon: "sun.max.fill")
    ]
    
    // Team information
    private let teamMembers = [
        TeamMember(
            name: "Adnan Ansari",
            role: "Front End Developer",
            image: "person.circle.fill",
            description: "Passionate about creating intuitive and responsive user interfaces",
            academicInfo: AcademicInfo(
                studentId: "22013 278",
                universityId: "036 2477"
            ),
            contactInfo: ContactInfo(
                github: "github.com/adnanansari"
            )
        ),
        TeamMember(
            name: "Monalisha Thapa Magar",
            role: "Front End Developer",
            image: "person.circle.fill",
            description: "Specializes in SwiftUI and modern iOS development",
            academicInfo: AcademicInfo(
                studentId: "22013 291",
                universityId: "036 2948"
            ),
            contactInfo: ContactInfo(
                github: "github.com/monalishamagar"
            )
        ),
        TeamMember(
            name: "Sisam Malla",
            role: "UI/UX Designer",
            image: "person.circle.fill",
            description: "Creating beautiful and user-friendly design experiences",
            academicInfo: AcademicInfo(
                studentId: "22013 268",
                universityId: "036 2562"
            ),
            contactInfo: ContactInfo(
                github: "github.com/sisammalla"
            )
        ),
        TeamMember(
            name: "Sudip Kumar Adhikari",
            role: "UI/UX Designer",
            image: "person.circle.fill",
            description: "Expert in user research and interaction design",
            academicInfo: AcademicInfo(
                studentId: "22013 265",
                universityId: "036 2552"
            ),
            contactInfo: ContactInfo(
                github: "github.com/sudipadhikari"
            )
        ),        
        TeamMember(
            name: "Sujal Ratna Tuladhar",
            role: "Back End Developer",
            image: "person.circle.fill",
            description: "Building robust and scalable server solutions",
            academicInfo: AcademicInfo(
                studentId: "22013 230",
                universityId: "036 2483"
            ),
            contactInfo: ContactInfo(
                github: "github.com/sujaltuladhar"
            )
        ),
    ]
    
    @State private var selectedMember: TeamMember?
    @State private var showingPopup = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented control
            Picker("About", selection: $selectedTab) {
                Text("About App").tag(0)
                Text("About Team").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Content based on selected tab
            if selectedTab == 0 {
                aboutAppView
            } else {
                aboutTeamView
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - About App View
    private var aboutAppView: some View {
        ScrollView {
            VStack(spacing: 30) {
                // App Logo and Version
                VStack(spacing: 16) {
                    Image(systemName: "cube.transparent.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Dash")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version \(appVersion)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Mission Statement
                VStack(alignment: .leading, spacing: 16) {
                    Text("Our Mission")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("To revolutionize learning through augmented reality and 3D technology, making education more interactive, engaging, and accessible for everyone.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Features Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Key Features")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 16) {
                        ForEach(appFeatures) { feature in
                            featureCard(feature)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Technologies Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Technologies")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        technologyBadge(name: "SwiftUI", icon: "swift")
                        technologyBadge(name: "ARKit", icon: "arkit")
                        technologyBadge(name: "SceneKit", icon: "cube.transparent")
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Footer
                Text("© 2023 Dash Team. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .padding()
        }
    }
    
    // MARK: - About Team View
    private var aboutTeamView: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Team Section Header
                    Text("Our Team")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top)
                    
                    // Batch and Group Info
                    VStack(spacing: 4) {
                        Text("BCS January 2023 • Group 28")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Lecture Group 1 • Tutorial Group 2")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 8)
                    
                    Text("Meet the amazing team behind the Dash app")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Team Members Stack
                    VStack(spacing: 16) {
                        ForEach(teamMembers) { member in
                            Button(action: {
                                selectedMember = member
                                showingPopup = true
                            }) {
                                TeamMemberRow(member: member)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Contact Section
                    VStack(spacing: 12) {
                        Text("Get in Touch")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 20) {
                            Link(destination: URL(string: "mailto:team@dashapp.com")!) {
                                Image(systemName: "envelope.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            
                            Link(destination: URL(string: "https://twitter.com/dashapp")!) {
                                Image(systemName: "link")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.bottom, 20)
            }
            .blur(radius: showingPopup ? 3 : 0)
            
            // Popup Card
            if showingPopup, let member = selectedMember {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showingPopup = false
                    }
                
                TeamMemberPopupCard(member: member, isShowing: $showingPopup)
                    .transition(.scale)
            }
        }
    }
    
    // MARK: - Helper Views
    private func featureCard(_ feature: AppFeature) -> some View {
        HStack(spacing: 16) {
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func technologyBadge(name: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Types
struct TeamMember: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let image: String // system image name
    let description: String
    let academicInfo: AcademicInfo
    let contactInfo: ContactInfo
}

struct AcademicInfo {
    let studentId: String
    let universityId: String
}

struct ContactInfo {
    let github: String
}

struct AppFeature: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

// MARK: - Previews
#Preview("About Us View") {
    NavigationView {
        AboutUsView()
    }
}
