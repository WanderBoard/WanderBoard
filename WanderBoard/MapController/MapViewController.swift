//
//  MapViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/1/24.
//

import SwiftUI
import MapKit

struct MapViewController: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchQuery = ""
    @State private var timer: Timer?
//    @Binding var photoLocation: CLLocationCoordinate2D?

    
    var body: some View {
        ZStack(alignment: .top) {
            MapView(region: $locationManager.region, annotations: $locationManager.annotations, locationManager: locationManager) // 수정된 부분
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    HStack {
                        TextField("", text: $searchQuery)
                            .padding(8)
                            .cornerRadius(10)
                            .overlay(
                                HStack {
                                    if searchQuery.isEmpty {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 8)
                                    }
                                    Spacer()
                                    if !searchQuery.isEmpty {
                                        Button(action: {
                                            searchQuery = ""
                                            locationManager.searchResults = []
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 8)
                                    }
                                }
                            )
                            .onChange(of: searchQuery) { newValue in
                                startSearchDelay()
                            }
                    }
                    .padding(8)
                    .background(Color.white).opacity(0.8)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 20)
                
                if locationManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                
                if !locationManager.searchResults.isEmpty {
                    LocationListView(searchResults: locationManager.searchResults) { completion in
                        searchForLocation(completion: completion)
                        locationManager.searchResults = []
                    }
                    .frame(maxHeight: 600)
                    .padding(.top, -16)
                    .padding(.leading, 4)
                    .padding(.trailing, 4)
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        locationManager.updateUserLocation()
                    }) {
                        Image(systemName: "location.fill")
                            .frame(width: 30, height: 30)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 40)
                    Spacer()
                }
            }
        }
        .onAppear {
            locationManager.checkLocationAuthorization()
        }
    }
    
    private func startSearchDelay() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            locationManager.updateSearchResults(query: searchQuery)
        }
    }
    
    private func searchForLocation(completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, let mapItem = response.mapItems.first else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                locationManager.selectedMapItem = mapItem // 수정된 부분
                locationManager.region = MKCoordinateRegion(center: mapItem.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                
                // 핀 추가
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                annotation.subtitle = mapItem.placemark.title
//                annotation.subtitle = mapItem.phoneNumber
                locationManager.annotations = [annotation]
            }
        }
    }
}

struct MapViewController_Previews: PreviewProvider {
    static var previews: some View {
        MapViewController()
    }
}

