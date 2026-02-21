//
//  ContentView.swift
//  Recify
//
//  Created by eve on 2026-02-02.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        TabBarView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
