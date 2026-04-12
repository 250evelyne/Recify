//
//  TransportOptions.swift
//  Recify
//
//  Created by Macbook on 2026-04-09.
//

import Foundation
import MapKit


enum TransportOption: String, CaseIterable, Hashable {
    case car
    case walking
    case transit
    
    var icon: String {
        switch self {
        case .car: return "car.fill"
        case .walking: return "figure.walk"
        case .transit: return "bus.fill"
        }
    }
    
    var mapKitType: MKDirectionsTransportType {
        switch self {
        case .car: return .automobile
        case .walking: return .walking
        case .transit: return .transit
        }
    }
}
