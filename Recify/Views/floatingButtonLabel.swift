//
//  floatingButtonLabel.swift
//  Recify
//
//  Created by Macbook on 2026-02-07.
//

import SwiftUI

struct floatingButtonLabel: View {
    
    let title : String
    let image : String
    let isSelected : Bool
    
    var body: some View {
        Label(title, systemImage: image)
            .padding()
            .background( isSelected ? .pink : .pink.opacity(0.3))
            .foregroundColor(isSelected ? .white : .pink)
            .cornerRadius(15)
        
    }
}

#Preview {
    floatingButtonLabel(title: "all", image: "leaf", isSelected: false)
}
