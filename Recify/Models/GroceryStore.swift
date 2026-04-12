//
//  GroceryStore.swift
//  Recify
//
//  Created by Macbook on 2026-04-09.
//

import Foundation
import MapKit

struct GroceryStore: Identifiable, Hashable {
    let id = UUID()
    let item: MKMapItem
    
    var name: String {
        item.name ?? "Store"
    }
    
    var coordinate: CLLocationCoordinate2D {
        item.placemark.coordinate
    }
}
