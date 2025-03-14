import SwiftUI

struct UserManagementView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var users: [User] = []
    @State private var showingAddUserSheet = false
    @State private var showingEditUserSheet = false
    @State private var selectedUser: User?
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(filteredUsers) { user in
                        UserRowView(user: user)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedUser = user
                                showingEditUserSheet = true
                            }
                    }
                    .onDelete(perform: deleteUsers)
                }
                .searchable(text: $searchText, prompt: "Search users")
                .navigationTitle("User Management")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddUserSheet = true
                        }) {
                            Label("Add User", systemImage: "person.badge.plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddUserSheet) {
            UserFormView(authViewModel: authViewModel, mode: .add, onSave: { newUser in
                authViewModel.userJSONManager.addUser(newUser)
                refreshUsers()
            })
        }
        .sheet(isPresented: $showingEditUserSheet) {
            if let user = selectedUser {
                UserFormView(authViewModel: authViewModel, mode: .edit(user), onSave: { updatedUser in
                    authViewModel.userJSONManager.updateUser(updatedUser)
                    refreshUsers()
                })
            }
        }
        .onAppear {
            refreshUsers()
        }
    }
    
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText) ||
                user.username.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func refreshUsers() {
        users = authViewModel.userJSONManager.getAllUsers()
    }
    
    private func deleteUsers(at offsets: IndexSet) {
        for index in offsets {
            let user = filteredUsers[index]
            authViewModel.userJSONManager.deleteUser(id: user.id)
        }
        refreshUsers()
    }
}

struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                Text(user.username)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(user.role.displayName)
                .font(.caption)
                .padding(5)
                .background(roleColor(for: user.role))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
    
    private func roleColor(for role: UserRole) -> Color {
        switch role {
        case .admin:
            return .red
        case .teacher:
            return .blue
        case .student:
            return .green
        case .professional:
            return .purple
        case .demo:
            return .orange
        }
    }
}

enum UserFormMode {
    case add
    case edit(User)
}

struct UserFormView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    let mode: UserFormMode
    let onSave: (User) -> Void
    
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
        let user: User
        if case .edit(let existingUser) = mode {
            user = User(
                id: existingUser.id,
                email: email,
                username: username,
                name: name,
                password: password,
                role: selectedRole
            )
        } else {
            user = User(
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

extension UserFormMode {
    var isEdit: Bool {
        if case .edit = self {
            return true
        }
        return false
    }
}

// MARK: - Previews
#Preview("User Management View") {
    UserManagementView(authViewModel: AuthViewModel())
}

#Preview("User Form View - Add") {
    UserFormView(
        authViewModel: AuthViewModel(),
        mode: .add,
        onSave: { _ in }
    )
}

#Preview("User Form View - Edit") {
    UserFormView(
        authViewModel: AuthViewModel(),
        mode: .edit(User(
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