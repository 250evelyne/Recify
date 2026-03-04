//
//  ProfileView.swift
//  Recify
//
//  Created by mac on 2026-02-02.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showLogoutConfirm = false
    
    @StateObject private var ingredientVM = IngredientViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    
                    VStack(spacing: 12) {
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color.orange.opacity(0.6), Color.pink.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                )
                            
                            NavigationLink(destination: EditProfileView().environmentObject(authManager)) {
                                Circle()
                                    .fill(Color.pink)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "pencil")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        .padding(.top, 30)
                        
                        Text(authManager.userProfile?.userName ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(authManager.userProfile?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 30)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("MY ACTIVITY")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            NavigationLink(destination: CookingStatisticsTabView().environmentObject(authManager)) {
                                SettingsRowContent(
                                    icon: "chart.bar.fill",
                                    iconColor: .pink,
                                    title: "Cooking Statistics",
                                    subtitle: "View your progress"
                                )
                            }
                            
                            Divider().padding(.leading, 60)
                            
                            SettingsRow(
                                icon: "heart.fill",
                                iconColor: .pink,
                                title: "Favorite Recipes",
                                subtitle: "\(authManager.userProfile?.favorites.count ?? 0) saved",
                                action: {}
                            )
                            
                            Divider().padding(.leading, 60)
                            
                            NavigationLink(destination: PantryView()) {
                                SettingsRowContent(
                                    icon: "archivebox.fill",
                                    iconColor: .brown,
                                    title: "Pantry",
                                    subtitle: "View all your saved Ingredients"
                                )
                            }
                            
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("PRIVACY & SECURITY")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            SettingsToggleRow(
                                icon: "eye.slash.fill",
                                iconColor: .blue,
                                title: "Private Profile",
                                isOn: .constant(false)
                            )
                            
                            Divider().padding(.leading, 60)
                            
                            SettingsToggleRow(
                                icon: "bolt.fill",
                                iconColor: .blue,
                                title: "Show Activity Status",
                                isOn: .constant(false)
                            )
                            
                            Divider().padding(.leading, 60)
                            
                            SettingsRow(
                                icon: "nosign",
                                iconColor: .blue,
                                title: "Blocked Accounts",
                                action: {}
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SUPPORT")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "questionmark.circle.fill",
                                iconColor: .gray,
                                title: "Help Center",
                                action: {}
                            )
                            
                            Divider().padding(.leading, 60)
                            
                            SettingsRow(
                                icon: "doc.text.fill",
                                iconColor: .gray,
                                title: "Terms of Service",
                                action: {}
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                    
                    Button(action: {
                        showLogoutConfirm = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    
                    Text("Recify Version 2.4.0 (2026)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Account Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            .alert("Logout", isPresented: $showLogoutConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Logout", role: .destructive) {
                    authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}

struct SettingsRowContent: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.5)) //i just though that the coloor looked to muted and it looked disbaled
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.primary)
                    .fontWeight(.medium)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SettingsRowContent(icon: icon, iconColor: iconColor, title: title, subtitle: subtitle)
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.2))
                .cornerRadius(8)
            
            Text(title)
                .foregroundColor(.primary)
                .fontWeight(.medium)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.pink)
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthManager())
    }
}
