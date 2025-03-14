import SwiftUI
import SwiftData

struct UserManagementView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var users: [UserModel] = []
    @State private var showingAddUserSheet = false
    @State private var showingEditUserSheet = false
    @State private var selectedUser: UserModel?
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(filteredUsers, id: \.id) { user in
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
    
    private var filteredUsers: [UserModel] {
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

#Preview {
    UserManagementView(authViewModel: AuthViewModel())
} 