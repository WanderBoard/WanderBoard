//
//  MapViewModel.swift
//  WanderBoard
//
//  Created by David Jang on 6/1/24.
//

import SwiftUI
import MapKit
import CoreLocation

class MapViewModel: NSObject, ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var annotations: [MKPointAnnotation] = []
    @Published var searchQuery: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var isLoading: Bool = false
    
    private let locationManager = CLLocationManager()
    private let searchCompleter = MKLocalSearchCompleter()
    private var timer: Timer?
    
    var onLocationAuthorizationGranted: (() -> Void)?
    var searchResultsHandler: (([MKLocalSearchCompletion]) -> Void)?
    
    init(region: MKCoordinateRegion) {
        self.region = region
        super.init()
        locationManager.delegate = self
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .query
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                switch self.locationManager.authorizationStatus {
                    case .notDetermined:
                        DispatchQueue.main.async {
                            self.locationManager.requestWhenInUseAuthorization()
                        }
                    case .restricted, .denied:
                        DispatchQueue.main.async {
                            self.setDefaultRegion()
                        }
                    case .authorizedWhenInUse, .authorizedAlways:
                        DispatchQueue.main.async {
                            self.onLocationAuthorizationGranted?()
                            self.locationManager.startUpdatingLocation()
                        }
                    @unknown default:
                        break
                }
            } else {
                DispatchQueue.main.async {
                    print("Location services are not enabled")
                    self.setDefaultRegion()
                }
            }
        }
    }
    
    
    
    
    
    //    func requestLocationAuthorization() {
    //        if CLLocationManager.locationServicesEnabled() {
    //            switch locationManager.authorizationStatus {
    //            case .notDetermined:
    //                DispatchQueue.main.async {
    //                    self.locationManager.requestWhenInUseAuthorization()
    //                }
    //            case .restricted, .denied:
    //                setDefaultRegion()
    //            case .authorizedWhenInUse, .authorizedAlways:
    //                DispatchQueue.main.async {
    //                    self.locationManager.startUpdatingLocation()
    //                    self.onLocationAuthorizationGranted?()
    //                }
    //            @unknown default:
    //                break
    //            }
    //        } else {
    //            print("Location services are not enabled")
    //            setDefaultRegion()
    //        }
    //    }
    
    func setDefaultRegion() {
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
    
    func updateSearchResults(query: String) {
        DispatchQueue.main.async {
            self.searchCompleter.queryFragment = query
        }
    }
    
    func updateUserLocation() {
        if let location = self.locationManager.location {
            DispatchQueue.main.async {
                self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            }
        } else {
            print("User location is unavailable.")
        }
    }
    
    func startSearchDelay() {
        isLoading = true
        searchResults = []
        searchResultsHandler?(searchResults) // 빈 검색 결과를 전달하여 로딩 셀을 표시
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
            self.searchCompleter.queryFragment = self.searchQuery
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.searchResults = completer.results
            self.searchResultsHandler?(self.searchResults)
        }
    }
    
    func searchForLocation(completion: MKLocalSearchCompletion) async throws -> MKMapItem {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        let response = try await search.start()
        guard let mapItem = response.mapItems.first else {
            throw NSError(domain: "com.wanderboard.MapError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No map items found"])
        }
        return mapItem
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                self.setDefaultRegion()
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.startUpdatingLocation()
            @unknown default:
                break
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
}

extension MapViewModel: MKLocalSearchCompleterDelegate {
    func completerDidFailWithError(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            print("Error: \(error.localizedDescription)")
        }
    }
}
