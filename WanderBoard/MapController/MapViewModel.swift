//
//  MapViewModel.swift
//  WanderBoard
//
//  Created by David Jang on 6/1/24.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var annotations: [MKPointAnnotation]
    var locationManager: LocationManager

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.mapTapped))
        mapView.addGestureRecognizer(tapGesture)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, locationManager: locationManager)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var locationManager: LocationManager

        init(_ parent: MapView, locationManager: LocationManager) {
            self.parent = parent
            self.locationManager = locationManager
        }

        @objc func mapTapped() {
//            self.locationManager.selectedMapItem = nil
//            self.locationManager.annotations = []
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "Placemark"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation as? MKPointAnnotation else { return }
            if let title = annotation.title, let completion = self.locationManager.searchResults.first(where: { $0.title == title }) {
                self.locationManager.searchForLocation(completion: completion) { mapItem in
                    guard let mapItem = mapItem else { return }
                    self.locationManager.selectedMapItem = mapItem
                }
            }
        }
    }
}
