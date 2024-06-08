//
//  LocationManager.swift
//  WanderBoard
//
//  Created by David Jang on 6/1/24.
//

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

//    private var completionHandler: ((Bool) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .query
        checkLocationAuthorization()
    }

//    func requestLocationAuthorization(completion: @escaping (Bool) -> Void) {
//        completionHandler = completion
//        DispatchQueue.global().async {
//            if CLLocationManager.locationServicesEnabled() {
//                DispatchQueue.main.async {
//                    switch self.locationManager.authorizationStatus {
//                    case .notDetermined:
//                        self.locationManager.requestWhenInUseAuthorization()
//                    case .restricted, .denied:
//                        completion(false)
//                    case .authorizedWhenInUse, .authorizedAlways:
//                        completion(true)
//                    @unknown default:
//                        completion(false)
//                    }
//                }
//            } else {
//                DispatchQueue.main.async {
//                    completion(false)
//                }
//            }
//        }
//    }
    
    

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
//                    self.setDefaultRegion()
//                }
//            }
//        }
//    }
    
    func checkLocationAuthorization() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    switch self.locationManager.authorizationStatus {
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

    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
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
            print("Error: \(error.localizedDescription)")
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
                self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            } else {
                print("User location is unavailable.")
            }
        }
    }
    
    func searchForLocation(completion: MKLocalSearchCompletion, completionHandler: @escaping (MKMapItem?) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, let mapItem = response.mapItems.first else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completionHandler(nil)
                return
            }
            DispatchQueue.main.async {
                completionHandler(mapItem)
            }
        }
    }
}
