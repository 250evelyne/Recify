//
//  TabBarView.swift
//  Recify
//
//  Created by mac on 2026-02-09.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Discover")
                }
                .tag(0)
            
         
            CommunityFeedView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.3.fill" : "person.3")
                    Text("Feed")
                }
                .tag(3)
            
            addNewRecipe()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "plus.circle.fill" : "plus.circle.dashed")
                    Text("Create")
                }.tag(4)
            
            MessagesListView()
                .tabItem {
                    Image(systemName: selectedTab == 5 ? "bubble.left.and.bubble.right.fill" : "bubble.left.and.bubble.right")
                    Text("Messages")
                }
                .tag(5)
            
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 7 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(7)
            
            
        }
        .accentColor(.pink)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}

