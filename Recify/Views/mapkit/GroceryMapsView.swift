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
    
    //ima keep it as search bar becuase the find all grocery stores isnt working
    @State private var searchText: String = ""
    @State private var destination : CLLocationCoordinate2D?
    @State private var isSearching: Bool = false
    
    
    @State private var route: MKRoute?
    
    @State private var errorMessage: String?
    @State private var didAutoCenter: Bool = false
    @State private var currentCenter: CLLocationCoordinate2D?
    
    @State private var selectedTransport: TransportOption = .car
    
    //marker for mtl, for test
    //    let montreal = CLLocationCoordinate2D(
    //        latitude: 45.501690,
    //        longitude: -73.567253
    //    )
    
    let college = CLLocationCoordinate2D(
            latitude: 45.4916,
            longitude: -73.5815

        )
    
  
    
    @State private var stores: [GroceryStore] = []
    @State private var selectedStore: GroceryStore?
    

    var body: some View {
        ZStack{
            
            Map(position: $camera, selection: $selectedStore){
                
                  Marker("You", coordinate: college) //for niw its only loads the user location after a while so teven if they give the location it shows the collage so tom ima focus on user the suer lcoation becuase if i allow it then it send the user from ls to a metro in mtl so no good
                      .tint(.blue)
                
//                if let userLocation = locationManager.userLocation{
//                    Marker("You", coordinate: userLocation)
//                        .tint(.blue)
//                }
                
                if let destination {
                    Marker(searchText, coordinate: destination)
                        .tint(.green)
                }

                
//                ForEach(stores, id: \.self) { store in
                ForEach(stores) { store in
                    Marker(store.name, coordinate: store.coordinate)
                        .tint(.green)
                        .tag(store)
                }
                
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(Color("primaryColor") ,lineWidth: 4)
                }
                
            }.mapStyle(.standard)
            //                .onReceive(locationManager.$userLocation) { newValue in
            //                    print("Location update:", newValue as Any)
            //
            //                    guard let loc = newValue else { return }
            //
            //                    if !didAutoCenter {
            //                        print("Fetching stores...")
            //
            //                        didAutoCenter = true
            //                        camera = .camera(MapCamera(centerCoordinate: loc, distance: zoomLevel))
            //
            //                        fetchNearbyStores()
            //                    }
            //                }
                .onAppear {
                    if !didAutoCenter {
                        let startLocation = locationManager.userLocation ?? college
                        
                        camera = .camera(
                            MapCamera(
                                centerCoordinate: startLocation,
                                distance: zoomLevel
                            )
                        )
                        
                        fetchNearbyStores()
                        
                        didAutoCenter = true
                    }
                }
                .onMapCameraChange {
                    context in
                    currentCenter = context.region.center
                }
                .onChange(of: selectedStore) { newStore in
                    guard let store = newStore else { return }
                    
                    selectStore(store)
                }
                .onChange(of: selectedTransport) { _ in //i wanted that if the user chnages the transport type the route recals its self
                    let source = locationManager.userLocation ?? college
                    
                    if let store = selectedStore {
                        selectStore(store)
                    } else if let dest = destination {
                        Task {
                            do {
                                let newRoute = try await calculateRoute(
                                    from: source,
                                    to: dest,
                                    transport: selectedTransport.mapKitType
                                )
                                
                                route = newRoute
                                camera = .region(MKCoordinateRegion(newRoute.polyline.boundingMapRect))
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color("myPurple").opacity(0.5), location: 0.0),
                    .init(color: Color("myPurple").opacity(0.01), location: 0.1),
                    .init(color: Color("myPurple").opacity(0.01), location: 0.9),
                    .init(color: Color("myPurple").opacity(0.8), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false) //it was stoping me from being able to touche anything before
            
            VStack{
                storeSearchSection
                
                Picker("Transport", selection: $selectedTransport) {
                    ForEach(TransportOption.allCases, id: \.self) { option in
                        Label(option.rawValue.capitalized, systemImage: option.icon)
                            .tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Spacer()
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
                                .background(Color("myBrown").opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button {
                            zoomOut()
                        } label: {
                            Image(systemName: "minus")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color("myBrown").opacity(0.9))
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
            
            
//            if let store = selectedStore {
//                VStack {
//                    Spacer()
//                    
//                    VStack(spacing: 10) {
//                        Text(store.name ?? "Store")
//                            .font(.headline)
//                        
//                        Text(store.placemark.title ?? "")
//                            .font(.subheadline)
//                            .foregroundStyle(.gray)
//                        
//                        Button {
//                            store.openInMaps()
//                        } label: {
//                            Text("Get Directions")
//                                .foregroundStyle(.white)
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(Color.blue)
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
//                        }
//                    }
//                    .padding()
//                    .background(.ultraThinMaterial)
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                    .padding()
//                }
//            }
            
            
            
        }
        .navigationTitle("Grocery Maps").foregroundStyle(.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    private var storeSearchSection: some View {
        
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .font(.title3)

                
                TextField("Search for a store ...", text: $searchText)
                    .padding(5)
                    .font(.title3)
                    .autocapitalization(.none)
                    .disableAutocorrection(false)
                    .submitLabel(.search)
                    .onSubmit {
                        runSearch()
                    }
                    .foregroundStyle(.white)
                    .shadow(radius: 5)
                
                if isSearching {
                    ProgressView()
                        .tint(.blue)
                        .scaleEffect(0.8)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(.ultraThinMaterial)
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    
    //MARK: funtions
    
    private func selectStore(_ store: GroceryStore) {
        Task {
            let source = locationManager.userLocation ?? college
            
            do {
                let newRoute = try await calculateRoute(
                    from: source,
                    to: store.coordinate,
                    transport: selectedTransport.mapKitType
                )
                
                route = newRoute
                
                let rect = newRoute.polyline.boundingMapRect
                camera = .region(MKCoordinateRegion(rect))
                
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    
    private func fetchNearbyStores() {
        let center = locationManager.userLocation ?? college
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "grocery store"
        
        request.region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: 3000,
            longitudinalMeters: 3000
        )
        
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.foodMarket])
        
        MKLocalSearch(request: request).start { response, error in
            guard let items = response?.mapItems else { return }
            
            DispatchQueue.main.async {
//                self.stores = Array(items.prefix(10))
                
                self.stores = Array(items.prefix(10)).map {
                    GroceryStore(item: $0)
                }
                
            }
        }
    }
    
    
    private func runSearch(){
        Task{
            @MainActor in
            
            errorMessage = nil
            
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !query.isEmpty else {return}
            
//            guard let userLocation = locationManager.userLocation else {
//                errorMessage = "User Location is not avalible yet."
//                return
//            }
            
            let source = locationManager.userLocation ?? college
            
            isSearching = true
            defer { isSearching = false}
            
            do{
                let dest = try await searchCoordinate(for: query)
                destination = dest
                
                let newRoute = try await calculateRoute(
                    from: source /*userLocation*/,
                    to: dest,
                    transport: $selectedTransport.wrappedValue.mapKitType
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
            to destination: CLLocationCoordinate2D,
            transport: MKDirectionsTransportType
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
//            request.transportType = .automobile
            request.transportType = transport
            
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
    
    private func searchCoordinate(for query: String) async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { continuation in
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            
            // 📍 your reference point
            let center = locationManager.userLocation ?? college
            
            request.region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 3000,
                longitudinalMeters: 3000
            )
            
            MKLocalSearch(request: request).start { response, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let items = response?.mapItems, !items.isEmpty else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "Search Error",
                            code: 0,
                            userInfo: [
                                NSLocalizedDescriptionKey: "No results found for \(query)"
                            ]
                        )
                    )
                    return
                }
                
                let centerLocation = CLLocation(
                    latitude: center.latitude,
                    longitude: center.longitude
                )
                
                let sortedItems = items.sorted { item1, item2 in
                    let loc1 = CLLocation(
                        latitude: item1.placemark.coordinate.latitude,
                        longitude: item1.placemark.coordinate.longitude
                    )
                    
                    let loc2 = CLLocation(
                        latitude: item2.placemark.coordinate.latitude,
                        longitude: item2.placemark.coordinate.longitude
                    )
                    
                    return loc1.distance(from: centerLocation) < loc2.distance(from: centerLocation)
                }
                
                let closest = sortedItems.first!
                
                continuation.resume(returning: closest.placemark.coordinate)
            }
        }
    }
    
    
    
    private func zoomIn(){
        
        guard let center = currentCenter else {return}
        
//        if let userLocation = locationManager.userLocation {
            withAnimation {
                zoomLevel *= 0.8

                camera = .camera(
                    MapCamera(
                        centerCoordinate: center, //will zoom in and out based on where yr looking at the screen
                        distance: zoomLevel
                    )
                )
//            }
        }
    }
    
    
    private func zoomOut(){
        guard let center = currentCenter else {return}

//        if let userLocation = locationManager.userLocation {
            withAnimation {
                zoomLevel *= 1.2

                camera = .camera(
                    MapCamera(
                        centerCoordinate: center,
                        distance: zoomLevel
                    )
                )
            }
//        }
    }
    
    
    private func goTOUserLocation(){
//        if let userLocation = locationManager.userLocation {
        let target = locationManager.userLocation ?? college
            withAnimation {
                camera = .camera(
                    MapCamera(
                        centerCoordinate: target,
                        distance: zoomLevel
                    )
                )
            }
//        }
    }
    
    
}

#Preview {
    if #available(iOS 17.0, *) {
        GroceryMapsView()
    } else {
        // Fallback on earlier versions
    }
}
