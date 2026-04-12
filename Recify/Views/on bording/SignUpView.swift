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
        ScrollView {
            VStack(spacing: 0) {
                
                // MARK: - Header
                ZStack {
                    LinearGradient(
                        colors: [Color.pink.opacity(0.7), Color(red: 0.6, green: 0.8, blue: 1.0).opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea(edges: .top)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.white)
                        
                        Text("Recify")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Join our cooking community")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.vertical, 48)
                }
                .frame(maxWidth: .infinity)
                
                // MARK: - Form Card
                VStack(spacing: 20) {
                    
                    Text("Create Account")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    
                    // Username
                    CustomField(
                        icon: "person",
                        placeholder: "Username",
                        text: $userName,
                        isSecure: false
                    )
                    
                    // Email
                    CustomField(
                        icon: "envelope",
                        placeholder: "Email Address",
                        text: $email,
                        isSecure: false,
                        keyboardType: .emailAddress
                    )
                    
                    // Password
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.pink)
                                .frame(width: 20)
                            if showPassword {
                                TextField("Password", text: $password)
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Confirm Password
                    CustomField(
                        icon: "lock.fill",
                        placeholder: "Confirm Password",
                        text: $confirmPassword,
                        isSecure: true
                    )
                    
                    // Password match indicator
                    if !confirmPassword.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(password == confirmPassword ? .green : .red)
                            Text(password == confirmPassword ? "Passwords match" : "Passwords don't match")
                                .font(.caption)
                                .foregroundColor(password == confirmPassword ? .green : .red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Sign Up Button
                    Button(action: handleSignUp) {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            isFormValid && !isLoading
                            ? LinearGradient(colors: [.pink, .pink.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.4)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(14)
                        .shadow(color: isFormValid ? .pink.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(!isFormValid || isLoading)
                    .padding(.top, 8)
                    
                    // Login link
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
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Success!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Account created successfully! Please log in.")
        }
    }
    
    var isFormValid: Bool {
        !userName.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 6
    }
    
    func handleSignUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return
        }
        isLoading = true
        authManager.signUp(email: email, password: password, userName: userName) { success in
            isLoading = false
            if success {
                showSuccess = true
            } else {
                errorMessage = authManager.errorMessage
                showError = true
            }
        }
    }
}

// MARK: - Reusable Custom Field
struct CustomField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .frame(width: 20)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .keyboardType(keyboardType)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
