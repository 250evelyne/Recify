//
//  LoginView.swift
//  Recify
//
//  Created by mac on 2026-02-02.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showError = false
    
    var body: some View {
        NavigationView {
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
                            
                            Text("Discover your next favorite meal")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.vertical, 48)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // MARK: - Form Card
                    VStack(spacing: 20) {
                        
                        Text("Welcome Back")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        
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
                                Text("Password")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Button("Forgot?") {}
                                    .font(.subheadline)
                                    .foregroundColor(.pink)
                            }
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.pink)
                                    .frame(width: 20)
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                        .autocapitalization(.none)
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
                            .cornerRadius(12)
                        }
                        
                        // Login Button
                        Button(action: handleLogin) {
                            Text("Log In")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    email.isEmpty || password.isEmpty
                                    ? LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.4)], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [.pink, .pink.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(14)
                                .shadow(color: email.isEmpty || password.isEmpty ? .clear : .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(email.isEmpty || password.isEmpty)
                        .padding(.top, 8)
                        
                        // Sign up link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                            NavigationLink("Sign Up") {
                                SignUpView()
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
                Text(authManager.errorMessage)
            }
        }
    }
    
    func handleLogin() {
        authManager.signIn(email: email, password: password) { success in
            if !success {
                showError = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthManager())
    }
}
