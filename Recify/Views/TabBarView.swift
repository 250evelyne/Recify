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
            
            //gonna move this to user profile
//            PantryView()
//                .tabItem {
//                    Image(systemName: selectedTab == 2 ? "archivebox.fill" : "archivebox")
//                    Text("Pantry")
//                }
//                .tag(2)
            
            //has to be somewhere else
//            CookingModeTabView()
//                .tabItem {
//                    Image(systemName: selectedTab == 1 ? "play.circle.fill" : "play.circle")
//                    Text("Cooking")
//                }
//                .tag(1)
            
            CommunityFeedView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "person.3.fill" : "person.3")
                    Text("Feed")
                }
                .tag(2)
            
            MessagesListView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "bubble.left.and.bubble.right.fill" : "bubble.left.and.bubble.right")
                    Text("Messages")
                }
                .tag(3)
            
            //move this to home page well not sure at the moment 
//            ShoppingList()
//                .tabItem {
//                    Image(systemName: selectedTab == 4 ? "cart.fill" : "cart")
//                    Text("Shop")
//                }.tag(4)
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(4)
            
            
        }
        .accentColor(.pink)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}

