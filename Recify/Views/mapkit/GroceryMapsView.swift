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
    
    //marker for mtl, for test
    //    let montreal = CLLocationCoordinate2D(
    //        latitude: 45.501690,
    //        longitude: -73.567253
    //    )
    
    
    //not working
//    @State private var stores: [MKMapItem] = []
//    @State private var selectedStore: MKMapItem?
    

    var body: some View {
        ZStack{
            
            Map(position: $camera){//for stores , selection: $selectedStore
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
                
                //                ForEach(stores, id: \.self) { store in
                //                    Marker(store.name ?? "Store", coordinate: store.placemark.coordinate)
                //                        .tint(.green)
                //                        .tag(store)
                //                }
                
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(Color("primaryColor") ,lineWidth: 4) //see if the pink works
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
                .onMapCameraChange {
                    context in
                    currentCenter = context.region.center
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
            
            VStack{
                storeSearchSection
                Spacer()
            }
            
//            VStack{
//                HStack(spacing: 10) {
//                    TextField("Search for a store ..", text: $searchText)
//                        .textFieldStyle(.roundedBorder)
//                        .textInputAutocapitalization(.never)
//                        .disableAutocorrection(false)//check if i wanna keep this
//                        .submitLabel(.search)
//                    
//                    Button {
//                        runSearch()
//                    } label: {
//                        if isSearching{
//                            ProgressView()
//                                .tint(.white)
//                                .frame(width: 24, height: 24)
//                                .padding(.vertical, 10)
//                                .padding(.horizontal, 14)
//                                .background(.blue)
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
//                        }else{
//                            Image(systemName: "magnifyingglass")
//                                .foregroundStyle(.white)
//                                .frame(width: 24, height: 24)
//                                .padding(.vertical, 10)
//                                .padding(.horizontal, 14)
//                                .background(.blue)
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
//                        }
//                    }.disabled(isSearching || searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//                    
//                }
//                
//                if let errorMessage {
//                    Text(errorMessage) 
//                        .foregroundStyle(.red)
//                        .padding()
//                }
//                
//                Spacer()
//            }.padding()
//                .onReceive(locationManager.$userLocation) { newValue in
//                    
//                    guard !didAutoCenter, route == nil, let loc = newValue else {return}
//                    
//                    didAutoCenter = true
//                    camera = .camera(MapCamera(centerCoordinate: loc, distance: zoomLevel))
//                }
        
            
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
    
//    private func fetchNearbyStores() {
//        guard let userLocation = locationManager.userLocation else { return }
//
//        let request = MKLocalSearch.Request()
//        request.region = MKCoordinateRegion(
//            center: userLocation,
//            latitudinalMeters: 5000,
//            longitudinalMeters: 5000
//        )
//        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.foodMarket, .bakery]) //the search and markers dont work
//
//        print("Fetching stores...")
//        MKLocalSearch(request: request).start { response, error in
//            if let error = error {
//                print("Error fetching stores:", error)
//                return
//            }
//
//            guard let items = response?.mapItems else {
//                print("No stores found")
//                return
//            }
//
//            DispatchQueue.main.async {
//                stores = items
//                print("Found stores:", items.count)
//            }
//        }
//    }
    
    
    
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
