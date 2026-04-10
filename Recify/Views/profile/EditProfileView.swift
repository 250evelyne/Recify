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
            selectedAvatar = authManager.userProfile?.avatar ?? "tomatoAvatar"
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
        guard let currentUser = Auth.auth().currentUser else { return }
        let userId = currentUser.uid
        isLoading = true
        
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        let usernameChanged = trimmedUsername != authManager.userProfile?.userName
        let avatarChanged = selectedAvatar != (authManager.userProfile?.avatar ?? "tomatoAvatar")
        let passwordChanged = !newPassword.isEmpty
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        let userRef = db.collection("users").document(userId)
        batch.updateData([
            "userName": trimmedUsername,
            "avatar": selectedAvatar
        ], forDocument: userRef)
        
        db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments { postSnapshot, _ in
            if let docs = postSnapshot?.documents {
                docs.forEach { batch.updateData(["userAvatar": selectedAvatar, "userName": trimmedUsername], forDocument: $0.reference) }
            }
            
            db.collectionGroup("comments").whereField("userId", isEqualTo: userId).getDocuments { commentSnapshot, _ in
                if let docs = commentSnapshot?.documents {
                    docs.forEach { batch.updateData(["userAvatar": selectedAvatar, "userName": trimmedUsername], forDocument: $0.reference) }
                }
                
                db.collectionGroup("messages").whereField("senderId", isEqualTo: userId).getDocuments { msgSnapshot, _ in
                    if let docs = msgSnapshot?.documents {
                        docs.forEach { batch.updateData(["senderImage": selectedAvatar, "senderName": trimmedUsername], forDocument: $0.reference) }
                    }
                    
                    db.collection("conversations")
                        .whereField("participants", arrayContains: userId)
                        .getDocuments { convSnapshot, _ in
                            if let docs = convSnapshot?.documents {
                                for doc in docs {
                                    batch.updateData(["participantImages.\(userId)": selectedAvatar], forDocument: doc.reference)
                                    batch.updateData(["participantNames.\(userId)": trimmedUsername], forDocument: doc.reference)
                                }
                            }
                    
                    
                            batch.commit { error in
                                if let error = error {
                                    setError(message: error.localizedDescription)
                                    return
                                }
                            }
                        
                        DispatchQueue.main.async {
                            authManager.userProfile?.userName = trimmedUsername
                            authManager.userProfile?.avatar = selectedAvatar
                            
                            var successMessages: [String] = []
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
        }
    }
    
    func updatePassword(user: FirebaseAuth.User, successMessages: [String]) {
        guard let currentEmail = authManager.userProfile?.email else {
            print("DEBUG ❌: User email missing for re-authentication")
            isLoading = false
            return
        }
        
        print("DEBUG 8️⃣: Starting Re-authentication")
        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: currentPassword)
        
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                print("DEBUG ❌: Re-authentication Failed: \(error.localizedDescription)")
                self.isLoading = false
                self.alertTitle = "Authentication Failed"
                self.alertMessage = "Current password is incorrect"
                self.showAlert = true
                return
            }
            
            print("DEBUG 9️⃣: Re-auth Success. Updating Password...")
            user.updatePassword(to: self.newPassword) { error in
                self.isLoading = false
                
                if let error = error {
                    print("DEBUG ❌: Password Update Failed: \(error.localizedDescription)")
                    self.alertTitle = "Password Update Failed"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                    return
                }
                
                print("DEBUG ✅: Password Updated Successfully")
                var updatedMessages = successMessages
                updatedMessages.append("Password updated")
                self.finishUpdate(messages: updatedMessages)
            }
        }
    }
    private func setError(message: String) {
        isLoading = false
        alertTitle = "Error"
        alertMessage = message
        showAlert = true
    }
    
    
    
    func finishUpdate(messages: [String]) {
        self.isLoading = false
        self.alertTitle = "Success"
        self.alertMessage = messages.isEmpty ? "Profile updated successfully!" : messages.joined(separator: "\n")
        self.showAlert = true
    }
}

private func updateUserContentInFirebase(userId: String, newName: String, newAvatar: String) {
    let db = Firestore.firestore()
    let batch = db.batch()
    
    db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments { snapshot, _ in
        snapshot?.documents.forEach { doc in
            batch.updateData([
                "userName": newName,
                "userAvatar": newAvatar
            ], forDocument: doc.reference)
        }
        
        db.collectionGroup("comments").whereField("userId", isEqualTo: userId).getDocuments { snapshot, _ in
            snapshot?.documents.forEach { doc in
                batch.updateData([
                    "userName": newName,
                    "userAvatar": newAvatar
                ], forDocument: doc.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("Error syncing legacy content: \(error.localizedDescription)")
                }
            }
        }
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
