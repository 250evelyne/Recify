//
//  LocationManager.swift
//  Recify
//
//  Created by Macbook on 2026-03-29.
//

import Foundation
import MapKit
import CoreLocation //is responsible for all the gps related querries
import Combine

class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate {

    private let LocationManager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D? //need to be optional
    
    override init() {
        super.init()
        LocationManager.delegate = self
        LocationManager.requestWhenInUseAuthorization() //th epop up
        LocationManager.startUpdatingLocation() //assces to gps
    }
    
    //MARK: in builtt mehods ovverride
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let latestLocation = locations.last else {return}
        
        DispatchQueue.main.async {
            self.userLocation = latestLocation.coordinate
        }
    }
    
    func locationManagerDidChnageAuthorization(_ manager: CLLocationManager){
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            manager.stopUpdatingLocation()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error){
        print("Failed to find users location: \(error.localizedDescription)")
        manager.stopUpdatingLocation()
    }
    
    
}
