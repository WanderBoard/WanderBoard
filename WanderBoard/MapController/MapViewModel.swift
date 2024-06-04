//
//  MapViewModel.swift
//  WanderBoard
//
//  Created by David Jang on 6/1/24.
//

import SwiftUI
import MapKit

class MapViewModel: NSObject, ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var annotations: [MKPointAnnotation] = []
    @Published var searchQuery: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var isLoading: Bool = false
    
    private let locationManager = CLLocationManager()
    private let searchCompleter = MKLocalSearchCompleter()
    private var timer: Timer?

    init(region: MKCoordinateRegion) {
        self.region = region
        super.init()
        locationManager.delegate = self
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .query
        checkLocationAuthorization()
    }

    func checkLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                setDefaultRegion()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            @unknown default:
                break
            }
        } else {
            print("Location services are not enabled")
            setDefaultRegion()
        }
    }

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
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            self.updateSearchResults(query: self.searchQuery)
        }
    }

    func searchForLocation(completion: MKLocalSearchCompletion, onComplete: @escaping (CLLocationCoordinate2D, String) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, let mapItem = response.mapItems.first else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let coordinate = mapItem.placemark.coordinate
            let address = "\(mapItem.placemark.name ?? ""), \(mapItem.placemark.locality ?? ""), \(mapItem.placemark.administrativeArea ?? ""), \(mapItem.placemark.country ?? "")"
            DispatchQueue.main.async {
                onComplete(coordinate, address)
            }
        }
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
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            print("Error: \(error.localizedDescription)")
        }
    }
}
