import SwiftUI
import SwiftData

enum UserFormMode {
    case add
    case edit(UserModel)
    
    var isEdit: Bool {
        switch self {
        case .add:
            return false
        case .edit:
            return true
        }
    }
}

struct UserFormView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    let mode: UserFormMode
    let onSave: (UserModel) -> Void
    
    @State private var email = ""
    @State private var username = ""
    @State private var name = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole = .student
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Name", text: $name)
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Password")) {
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
                Section(header: Text("Role")) {
                    Picker("Role", selection: $selectedRole) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(mode.isEdit ? "Edit User" : "Add User")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveUser()
                    }
                }
            }
            .onAppear {
                if case .edit(let user) = mode {
                    email = user.email
                    username = user.username
                    name = user.name
                    password = user.password
                    confirmPassword = user.password
                    selectedRole = user.role
                }
            }
        }
    }
    
    private func saveUser() {
        // Validate inputs
        if name.isEmpty || username.isEmpty || email.isEmpty {
            errorMessage = "All fields are required"
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }
        
        // Check if username exists (only for add mode)
        if case .add = mode {
            if authViewModel.userJSONManager.usernameExists(username) {
                errorMessage = "Username already exists"
                return
            }
        }
        
        // Create or update user
        let user: UserModel
        if case .edit(let existingUser) = mode {
            user = UserModel(
                id: existingUser.id,
                email: email,
                username: username,
                name: name,
                password: password,
                role: selectedRole
            )
        } else {
            user = UserModel(
                id: UUID().uuidString,
                email: email,
                username: username,
                name: name,
                password: password,
                role: selectedRole
            )
        }
        
        onSave(user)
        dismiss()
    }
}

#Preview("Add User") {
    UserFormView(
        authViewModel: AuthViewModel(),
        mode: UserFormMode.add,
        onSave: { _ in }
    )
}

#Preview("Edit User") {
    UserFormView(
        authViewModel: AuthViewModel(),
        mode: UserFormMode.edit(UserModel(
            id: UUID().uuidString,
            email: "john@example.com",
            username: "johndoe",
            name: "John Doe",
            password: "password123",
            role: .student
        )),
        onSave: { _ in }
    )
} 