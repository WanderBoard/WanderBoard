//
//  MapViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/1/24.
//

import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseFirestore

struct MapViewController: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchQuery = ""
    @State private var timer: Timer?
    @ObservedObject var viewModel: MapViewModel
    var startDate: Date
    var endDate: Date
    var onLocationSelected: ((CLLocationCoordinate2D, String) -> Void)?

    var body: some View {
        ZStack(alignment: .top) {
            MapView(viewModel: viewModel, onMapTap: nil)
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
            Task {
                await fetchImages()
            }
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
                locationManager.selectedMapItem = mapItem
                viewModel.region = MKCoordinateRegion(center: mapItem.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                
                // 핀 추가
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                annotation.subtitle = mapItem.placemark.title
                locationManager.annotations = [annotation]

                onLocationSelected?(mapItem.placemark.coordinate, mapItem.placemark.title ?? "Unknown Location")

                // 위치가 선택되었다고 알림 표시
                let alert = UIAlertController(title: "위치 저장됨", message: "\(mapItem.name ?? "Unknown Location")이(가) 저장되었습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    private func fetchImages() async {
        do {
            // FirestoreManager의 fetchPinLogs 메서드를 호출하여 네트워크 통신 수행
            let pinLogs = try await FirestoreManager.shared.fetchPinLogs(forUserId: Auth.auth().currentUser!.uid)
            for pinLog in pinLogs {
                for mediaItem in pinLog.media {
                    if let latitude = mediaItem.latitude, let longitude = mediaItem.longitude, let dateTaken = mediaItem.dateTaken {
                        if dateTaken >= startDate && dateTaken <= endDate {
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            annotation.title = "Image taken on \(dateTaken)"
                            locationManager.annotations.append(annotation)
                        }
                    }
                }
            }
        } catch {
            print("Failed to fetch images: \(error.localizedDescription)")
        }
    }
}

struct MapViewController_Previews: PreviewProvider {
    static var previews: some View {
        MapViewController(viewModel: MapViewModel(region: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )), startDate: Date(), endDate: Date())
    }
}
