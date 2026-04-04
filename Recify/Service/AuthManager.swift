//
//  FeedViewModel.swift
//  Recify
//
//  Created by netblen on 03-03-2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: FirebaseAuth.User?
    @Published var userProfile: User?
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            self.isAuthenticated = true
            loadUserProfile(userId: user.uid)
            print(" User already logged in: \(user.email ?? "")")
        }
    }
    
    func loadUserProfile(userId: String) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print(" Error loading profile: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data() {
                self.userProfile = User(
                    id: userId,
                    email: data["email"] as? String ?? "",
                    userName: data["userName"] as? String ?? "",
                    favorites: data["favorites"] as? [String] ?? [],
                    avatar: data["avatar"] as? String ?? "tomatoAvatar"
                )
                print(" Profile loaded: \(self.userProfile?.userName ?? "")")
                
                DispatchQueue.main.async {
                    FirebaseViewModel.shared.refreshData()
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        print(" Attempting login for: \(email)")
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(" Login error: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            if let user = result?.user {
                print("Login successful: \(user.email ?? "")")
                self.currentUser = user
                self.isAuthenticated = true
                self.loadUserProfile(userId: user.uid)
            }
            completion(true)
        }
    }
    
    func signUp(email: String, password: String, userName: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            guard let user = result?.user else { return }
            
            let userData: [String: Any] = [
                "uid": user.uid,
                "email": email,
                "userName": userName,
                "avatar": "tomatoAvatar",
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            self.db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.loadUserProfile(userId: user.uid)
                    completion(true)
                }
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.currentUser = nil
        self.userProfile = nil
        self.isAuthenticated = false
        print(" User signed out")
    }
    
        
    func updateAvatarLocally(newAvatar: String) {
        self.userProfile?.avatar = newAvatar
        
        guard let uid = currentUser?.uid else { return }
        db.collection("users").document(uid).updateData([
            "avatar": newAvatar
        ]) { error in
            if let error = error {
                print("Error syncing avatar to cloud: \(error.localizedDescription)")
            }
        }
    }
}
