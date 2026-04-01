//
//  SignUpView.swift
//  Recify
//
//  Created by eve on 2026-02-02.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var userName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showError = false
    @State private var showSuccess = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 50))
                    .foregroundColor(.pink)
                
                Text("Recify")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Join our cooking community.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter your username", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("example@email.com", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        if showPassword {
                            TextField("Enter your password", text: $password)
                        } else {
                            SecureField("Enter your password", text: $password)
                        }
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    SecureField("Re-enter your password", text: $confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            
            Button(action: handleSignUp) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign Up")
                        .font(.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid && !isLoading ? Color.pink : Color.gray)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .disabled(!isFormValid || isLoading)
            
            Spacer()
            
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                Button("Log In") {
                    dismiss()
                }
                .foregroundColor(.pink)
                .fontWeight(.semibold)
            }
            .font(.subheadline)
            .padding(.bottom, 24)
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Success!", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Account created successfully! Please log in with your new credentials.")
        }
    }
    
    var isFormValid: Bool {
        !userName.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 6
    }
    
    func handleSignUp() {
        print(" Form validation passed")
        print("   Username: \(userName)")
        print("   Email: \(email)")
        print("   Password length: \(password.count)")
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            print(" Passwords don't match")
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            print(" Password too short")
            return
        }
        
        isLoading = true
        print(" Starting signup process...")
        
        authManager.signUp(email: email, password: password, userName: userName) { success in
            isLoading = false
            
            if success {
                print(" Signup successful in view")
                showSuccess = true
            } else {
                print(" Signup failed in view")
                errorMessage = authManager.errorMessage
                showError = true
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView()
                .environmentObject(AuthManager())
        }
    }
}
