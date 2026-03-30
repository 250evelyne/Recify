//
//  GroceryMapsView.swift
//  Recify
//
//  Created by Macbook on 2026-03-29.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct GroceryMapsView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var camera: MapCameraPosition = .automatic
    @State private var zoomLevel: Double = 2000
    
    @State private var searchText: String = ""
    @State private var destination : CLLocationCoordinate2D?
    @State private var route: MKRoute?
    
    @State private var isSearching: Bool = false
    @State private var errorMessage: String?
    @State private var didAutoCenter: Bool = false
    @State private var currentCenter: CLLocationCoordinate2D?
    
    //marker for mtl, for test
//    let montreal = CLLocationCoordinate2D(
//        latitude: 45.501690,
//        longitude: -73.567253
//    )
    
    var body: some View {
        ZStack{
            
            Map(position: $camera){
//                Marker("Montreal", coordinate: montreal) //for text
//                    .tint(.red)
                
                if let userLocation = locationManager.userLocation{
                    Marker("You", coordinate: userLocation)
                        .tint(.blue)
                }
                
                if let destination {
                    Marker(searchText, coordinate: destination)
                        .tint(.green)
                }
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(Color("primaryColor") ,lineWidth: 4) //see if the pink works
                }
                
            }.mapStyle(.standard)
                .onMapCameraChange {
                    context in
                    currentCenter = context.region.center
                }
            
            //TODO: make it not ugly anymore
            VStack{
                HStack(spacing: 10) {
                    TextField("Search for a store ..", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(false)//check if i wanna keep this
                        .submitLabel(.search)
                    
                    Button {
                        runSearch()
                    } label: {
                        if isSearching{
                            ProgressView()
                                .tint(.white)
                                .frame(width: 24, height: 24)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }else{
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }.disabled(isSearching || searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                }
                
                if let errorMessage {
                    Text(errorMessage) //TODO: chnage his to an alert
                        .foregroundStyle(.red)
                        .padding()
                }
                
                Spacer()
            }.padding()
                .onReceive(locationManager.$userLocation) { newValue in
                    
                    guard !didAutoCenter, route == nil, let loc = newValue else {return}
                    
                    didAutoCenter = true
                    camera = .camera(MapCamera(centerCoordinate: loc, distance: zoomLevel))
                }
            
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    VStack(spacing: 10){
                        Button {
                            zoomIn()
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color("myBrown"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button {
                            zoomOut()
                        } label: {
                            Image(systemName: "minus")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color("myBrown"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button {
                            goTOUserLocation()
                        } label: {
                            Image(systemName: "target") //idk might change the icon
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.pink.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }.padding()
                }
            }
            
            
        }
        .navigationTitle("Grocery Maps")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    
    
    private func runSearch(){
        Task{
            @MainActor in
            
            errorMessage = nil
            
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !query.isEmpty else {return}
            
            guard let userLocation = locationManager.userLocation else {
                errorMessage = "User Location is not avalible yet."
                return
            }
            
            isSearching = true
            defer { isSearching = false}
            
            do{
                let dest = try await searchCoordinate(for: query)
                destination = dest
                
                let newRoute = try await calculateRoute(
                    from: userLocation,
                    to: dest
                )
                
                route = newRoute
                
                let rect = newRoute.polyline.boundingMapRect
                let regien = MKCoordinateRegion(rect)
                camera = .region(regien)
                
            }catch{
                errorMessage = error.localizedDescription
            }
            
        }
    }
    
    
    private func calculateRoute(
            from source: CLLocationCoordinate2D,
            to destination: CLLocationCoordinate2D
    ) async throws -> MKRoute {
        try await withCheckedThrowingContinuation { continuation in
            
            let request  = MKDirections.Request()
            
            request.source = MKMapItem(
                placemark: MKPlacemark(
                    coordinate: source
                )
            )
            
            
            request.destination = MKMapItem(
                placemark: MKPlacemark(
                    coordinate: destination
                )
            )
            
            
            //TODO: idk if ima chnage it so that they can chose search the route based on vhicle, transit , walking or cycling
            request.transportType = .automobile
            
            MKDirections(request: request).calculate {
                response, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let route = response?.routes.first else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "Directions",
                            code: 0,
                            userInfo: [
                                NSLocalizedDescriptionKey: "No route found."
                            ]
                        )
                    )
                    return
                }
                continuation.resume(returning: route)
            }
            
        }
    }
    
    
    private func searchCoordinate(for query: String) async throws -> CLLocationCoordinate2D{
        try await withCheckedThrowingContinuation { continuation in
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            
            MKLocalSearch(request: request).start{
                responce, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let coordinate = responce?.mapItems.first?.placemark.coordinate else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "Search Error",
                            code: 0,
                            userInfo: [
                                NSLocalizedDescriptionKey: "No result found for query: \(query)"
                            ]
                        )
                    )
                    return
                }
            
                continuation.resume(returning: coordinate)
            }
        }
    }

    
    
    
    private func zoomIn(){
        
        guard let center = currentCenter else {return}
        
        if let userLocation = locationManager.userLocation {
            withAnimation {
                zoomLevel *= 0.8

                camera = .camera(
                    MapCamera(
                        centerCoordinate: center, //will zoom in and out based on where yr looking at the screen
                        distance: zoomLevel
                    )
                )
            }
        }
    }
    
    
    private func zoomOut(){
        guard let center = currentCenter else {return}

        if let userLocation = locationManager.userLocation {
            withAnimation {
                zoomLevel *= 1.2

                camera = .camera(
                    MapCamera(
                        centerCoordinate: center,
                        distance: zoomLevel
                    )
                )
            }
        }
    }
    
    
    private func goTOUserLocation(){
        if let userLocation = locationManager.userLocation {
            withAnimation {
                camera = .camera(
                    MapCamera(
                        centerCoordinate: userLocation,
                        distance: zoomLevel
                    )
                )
            }
        }
    }
    
    
}

#Preview {
    if #available(iOS 17.0, *) {
        GroceryMapsView()
    } else {
        // Fallback on earlier versions
    }
}
