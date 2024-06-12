//
//  LocationManager.swift
//  WanderBoard
//
//  Created by David Jang on 6/1/24.
//

//import Foundation
//import CoreLocation
//import MapKit
//
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
//    private let locationManager = CLLocationManager()
//    private let searchCompleter = MKLocalSearchCompleter()
//
//    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//    @Published var searchResults: [MKLocalSearchCompletion] = []
//    @Published var selectedMapItem: MKMapItem?
//    @Published var isLoading: Bool = false
//    @Published var annotations: [MKPointAnnotation] = []
//
////    private var completionHandler: ((Bool) -> Void)?
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        searchCompleter.delegate = self
//        searchCompleter.resultTypes = .query
//        checkLocationAuthorization()
//    }
//    
//    func checkLocationAuthorization() {
//        DispatchQueue.global().async {
//            if CLLocationManager.locationServicesEnabled() {
//                DispatchQueue.main.async {
//                    switch self.locationManager.authorizationStatus {
//                    case .notDetermined:
//                        self.locationManager.requestWhenInUseAuthorization()
//                    case .restricted, .denied:
//                        self.setDefaultRegion()
//                    case .authorizedWhenInUse, .authorizedAlways:
//                        self.locationManager.startUpdatingLocation()
//                    @unknown default:
//                        break
//                    }
//                }
//            } else {
//                DispatchQueue.main.async {
//                    print("Location services are not enabled")
//                    self.setDefaultRegion()
//                }
//            }
//        }
//    }
//
//    func setDefaultRegion() {
//        DispatchQueue.main.async {
//            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//        }
//    }
//
//    @objc func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        DispatchQueue.main.async {
//            switch status {
//            case .notDetermined:
//                self.locationManager.requestWhenInUseAuthorization()
//            case .restricted, .denied:
//                self.setDefaultRegion()
//            case .authorizedWhenInUse, .authorizedAlways:
//                self.locationManager.startUpdatingLocation()
//            @unknown default:
//                break
//            }
//        }
//    }
//
//    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.first else { return }
//        DispatchQueue.main.async {
//            self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//        }
//    }
//
//    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//        DispatchQueue.main.async {
//            self.searchResults = completer.results
//        }
//    }
//
//    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
//        DispatchQueue.main.async {
//            print("Error: \(error.localizedDescription)")
//        }
//    }
//
//    func updateSearchResults(query: String) {
//        DispatchQueue.main.async {
//            self.searchCompleter.queryFragment = query
//        }
//    }
//
//    func updateUserLocation() {
//        DispatchQueue.main.async {
//            if let location = self.locationManager.location {
//                self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//            } else {
//                print("User location is unavailable.")
//            }
//        }
//    }
//}


import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
    private let locationManager = CLLocationManager()
    private let searchCompleter = MKLocalSearchCompleter()

    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var selectedMapItem: MKMapItem?
    @Published var isLoading: Bool = false
    @Published var annotations: [MKPointAnnotation] = []

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .query
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    let status = self.locationManager.authorizationStatus
                    print("Authorization status: \(status.rawValue)")
                    switch status {
                    case .notDetermined:
                        print("Requesting 'When In Use' authorization")
                        self.locationManager.requestWhenInUseAuthorization()
                    case .restricted, .denied:
                        print("Location access denied or restricted")
                        self.setDefaultRegion()
                    case .authorizedWhenInUse, .authorizedAlways:
                        print("Location access authorized")
                        self.locationManager.startUpdatingLocation()
                    @unknown default:
                        break
                    }
                }
            } else {
                DispatchQueue.main.async {
                    print("Location services are not enabled")
                    self.setDefaultRegion()
                }
            }
        }
    }

    func setDefaultRegion() {
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }

    @objc func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            print("Authorization status changed: \(status.rawValue)")
            switch status {
            case .notDetermined:
                print("Requesting 'When In Use' authorization")
                self.locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                print("Location access denied or restricted")
                self.setDefaultRegion()
            case .authorizedWhenInUse, .authorizedAlways:
                print("Location access authorized")
                self.locationManager.startUpdatingLocation()
            @unknown default:
                break
            }
        }
    }

    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            print("Search completer error: \(error.localizedDescription)")
        }
    }

    func updateSearchResults(query: String) {
        DispatchQueue.main.async {
            self.searchCompleter.queryFragment = query
        }
    }

    func updateUserLocation() {
        DispatchQueue.main.async {
            if let location = self.locationManager.location {
                print("User location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            } else {
                print("User location is unavailable.")
            }
        }
    }
}
