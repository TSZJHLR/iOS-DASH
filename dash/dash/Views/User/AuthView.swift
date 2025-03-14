import SwiftUI

struct AuthView: View {
    // shared authentication state
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.presentationMode) var presentationMode
    // binding to control sheet presentation
    @Binding var isPresented: Bool
    // state variables for form inputs
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    
    // Add validation state
    @State private var showInvalidRoleAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // welcome header
                Text("Welcome")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // show either password reset or login/signup form
                if authViewModel.showForgotPassword {
                    ForgotPasswordView(email: $email)
                } else {
                    Group {
                        // additional fields for signup
                        if authViewModel.authMode == .signup {
                            // email field with email keyboard
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            TextField("Full Name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            // Updated role picker to include admin
                            Picker("Role", selection: $authViewModel.selectedRole) {
                                ForEach(UserRole.allCases, id: \.self) { role in
                                    Text(role.displayName).tag(role)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.vertical)
                        }
                        
                        // common fields for both login and signup
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                        
                        // secure field hides password input
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        // confirmation password for signup only
                        if authViewModel.authMode == .signup {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                if let error = authViewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // show loading indicator or action buttons
                if authViewModel.isLoading {
                    ProgressView()
                } else {
                    if !authViewModel.showForgotPassword {
                        // main action button (login/signup)
                        Button(action: {
                            Task {
                                if authViewModel.authMode == .login {
                                    await authViewModel.login(username: username, password: password)
                                } else {
                                    await authViewModel.signup(email: email, username: username, password: password, name: name)
                                }
                                if authViewModel.isAuthenticated {
                                    isPresented = false
                                }
                            }
                        }) {
                            Text(authViewModel.authMode == .login ? "Login" : "Sign Up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        // forgot password link
                        if authViewModel.authMode == .login {
                            Button(action: {
                                authViewModel.showForgotPassword = true
                            }) {
                                Text("Forgot Password?")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        // toggle between login and signup
                        Button(action: {
                            authViewModel.authMode = authViewModel.authMode == .login ? .signup : .login
                            authViewModel.error = nil
                        }) {
                            Text(authViewModel.authMode == .login ? "Need an account? Sign Up" : "Already have an account? Login")
                                .foregroundColor(.blue)
                        }
                        
                        .padding(.top, 20)
                    }
                }
            }
            .padding()
            // dynamic navigation title based on current mode
            .navigationTitle(authViewModel.showForgotPassword ? "Reset Password" : (authViewModel.authMode == .login ? "Sign In" : "Create Account"))
            // dismiss button in navigation bar
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Invalid Role Selection", isPresented: $showInvalidRoleAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Administrator accounts cannot be created through signup. Please contact system administration.")
            }
        }
        .preferredColorScheme(settingsManager.selectedTheme.colorScheme)
    }
}

// separate view for password reset functionality
struct ForgotPasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var email: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your email to reset your password")
                .multilineTextAlignment(.center)
            
            // email input for password reset
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            // reset password action button
            Button(action: {
                authViewModel.resetPassword(email: email)
            }) {
                Text("Reset Password")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // return to login view
            Button(action: {
                authViewModel.showForgotPassword = false
            }) {
                Text("Back to Login")
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AuthView(isPresented: .constant(true))
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsManager())
} 
