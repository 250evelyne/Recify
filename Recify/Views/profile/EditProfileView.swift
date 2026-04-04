//
//  EditProfileView.swift
//  Recify
//
//  Created by eve on 2026-02-09.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var selectedAvatar: String = ""
    
    let predefinedAvatars = ["cupcakeAvatar", "orangeAvatar", "strawberryAvatar", "peachAvatar", "pancakeAvatar", "friesAvatar", "cookieAvatar", "tomatoAvatar"]
    
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        Form {
            Section {
                VStack {
                    Image(selectedAvatar.isEmpty ? "tomatoAvatar" : selectedAvatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                        .padding(.bottom, 10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(predefinedAvatars, id: \.self) { avatar in
                                Image(avatar)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedAvatar == avatar ? Color.pink : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            selectedAvatar = avatar
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)
                    }
                }
                .padding(.vertical, 5)
            } header: {
                Text("CHOOSE AN AVATAR")
            }
            
            Section {
                HStack {
                    Text("Username")
                        .foregroundColor(.gray)
                    Spacer()
                    TextField("", text: $username)
                        .multilineTextAlignment(.trailing)
                }
            } header: {
                Text("BASIC INFORMATION")
            } footer: {
                Text("Your display name across Recify")
                    .font(.caption)
            }
            
            Section {
                HStack {
                    Text("Email")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(email)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                }
            } footer: {
                Text("Email cannot be changed here. Contact support if needed.")
                    .font(.caption)
            }
            
            Section {
                SecureField("Current Password", text: $currentPassword)
                    .autocapitalization(.none)
            } header: {
                Text("CHANGE PASSWORD (OPTIONAL)")
            } footer: {
                Text("Required to change password")
                    .font(.caption)
            }
            
            Section {
                SecureField("New Password", text: $newPassword)
                    .autocapitalization(.none)
                SecureField("Confirm New Password", text: $confirmPassword)
                    .autocapitalization(.none)
            } footer: {
                Text("Leave blank to keep current password. Must be at least 6 characters.")
                    .font(.caption)
            }
            
            Section {
                Button(action: saveChanges) {
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.pink)
                    }
                }
                .disabled(isLoading || !hasChanges)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            username = authManager.userProfile?.userName ?? ""
            email = authManager.userProfile?.email ?? ""
            selectedAvatar = authManager.userProfile?.avatar ?? "avatar1"
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") || alertMessage.contains("Success") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    var hasChanges: Bool {
        let usernameChanged = username != (authManager.userProfile?.userName ?? "")
        let passwordChanged = !newPassword.isEmpty
        let avatarChanged = selectedAvatar != (authManager.userProfile?.avatar ?? "tomatoAvatar")
        
        return usernameChanged || passwordChanged || avatarChanged
    }
    
    func saveChanges() {
        guard let currentUser = Auth.auth().currentUser,
              let userId = authManager.userProfile?.id else { return }
        
        isLoading = true
        
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        let usernameChanged = trimmedUsername != authManager.userProfile?.userName
        let avatarChanged = selectedAvatar != (authManager.userProfile?.avatar ?? "tomatoAvatar")
        let passwordChanged = !newPassword.isEmpty
        
        if passwordChanged {
            if newPassword != confirmPassword { setError(message: "New passwords do not match"); return }
            if newPassword.count < 6 { setError(message: "Password must be at least 6 characters"); return }
            if currentPassword.isEmpty { setError(message: "Current password is required"); return }
        }
        
        var successMessages: [String] = []
        let db = Firestore.firestore()
        
        if usernameChanged || avatarChanged {
            let batch = db.batch()
            
            let userRef = db.collection("users").document(userId)
            batch.updateData([
                "userName": trimmedUsername,
                "avatar": selectedAvatar
            ], forDocument: userRef)
            
            db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments { postSnapshot, _ in
                if let postDocs = postSnapshot?.documents {
                    for doc in postDocs {
                        batch.updateData(["userAvatar": selectedAvatar, "userName": trimmedUsername], forDocument: doc.reference)
                    }
                }
                
                db.collectionGroup("comments").whereField("userId", isEqualTo: userId).getDocuments { commentSnapshot, _ in
                    if let commentDocs = commentSnapshot?.documents {
                        for doc in commentDocs {
                            batch.updateData(["userAvatar": selectedAvatar, "userName": trimmedUsername], forDocument: doc.reference)
                        }
                    }
                    
                    batch.commit { error in
                        if let error = error {
                            setError(message: error.localizedDescription)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            authManager.userProfile?.userName = trimmedUsername
                            authManager.userProfile?.avatar = selectedAvatar
                            authManager.loadUserProfile(userId: userId)
                            
                            if usernameChanged { successMessages.append("Username updated") }
                            if avatarChanged { successMessages.append("Profile picture updated") }
                            
                            if passwordChanged {
                                updatePassword(user: currentUser, successMessages: successMessages)
                            } else {
                                finishUpdate(messages: successMessages)
                            }
                        }
                    }
                }
            }
        } else if passwordChanged {
            updatePassword(user: currentUser, successMessages: successMessages)
        } else {
            isLoading = false
        }
    }
    
    private func setError(message: String) {
        isLoading = false
        alertTitle = "Error"
        alertMessage = message
        showAlert = true
    }
    
    func updatePassword(user: FirebaseAuth.User, successMessages: [String]) {
        guard let currentEmail = authManager.userProfile?.email else {
            isLoading = false
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: currentPassword)
        
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                self.isLoading = false
                self.alertTitle = "Authentication Failed"
                self.alertMessage = "Current password is incorrect"
                self.showAlert = true
                return
            }
            
            user.updatePassword(to: self.newPassword) { error in
                self.isLoading = false
                
                if let error = error {
                    self.alertTitle = "Password Update Failed"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                    return
                }
                
                var updatedMessages = successMessages
                updatedMessages.append("Password updated")
                self.finishUpdate(messages: updatedMessages)
            }
        }
    }
    
    func finishUpdate(messages: [String]) {
        self.isLoading = false
        self.alertTitle = "Success"
        self.alertMessage = messages.isEmpty ? "Profile updated successfully!" : messages.joined(separator: "\n")
        self.showAlert = true
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditProfileView()
                .environmentObject(AuthManager())
        }
    }
}
