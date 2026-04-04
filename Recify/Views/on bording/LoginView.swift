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
                    Text("Welcome Back")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Discover your next favorite meal.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                VStack(spacing: 16) {
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
                        HStack {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Button("Forgot?") {
                                
                            }
                            .font(.subheadline)
                            .foregroundColor(.pink)
                        }
                        
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
                }
                .padding(.horizontal, 24)
                
                Button(action: handleLogin) {
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .disabled(email.isEmpty || password.isEmpty)
                
//                Text("or continue with")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .padding(.top, 8)
//                
//                VStack(spacing: 12) {
//                    Button(action: {}) {
//                        HStack {
//                            Image(systemName: "g.circle.fill")
//                            Text("Continue with Google")
//                                .fontWeight(.semibold)
//                        }
//                        .foregroundColor(.black)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                        )
//                    }
//                    
//                    Button(action: {}) {
//                        HStack {
//                            Image(systemName: "apple.logo")
//                            Text("Continue with Apple")
//                                .fontWeight(.semibold)
//                        }
//                        .foregroundColor(.black)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                        )
//                    }
//                }
//                .padding(.horizontal, 24)
//                
                Spacer()
                
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
                .padding(.bottom, 24)
            }
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
