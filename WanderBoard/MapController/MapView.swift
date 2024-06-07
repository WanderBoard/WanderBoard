//
//  MapView.swift
//  WanderBoard
//
//  Created by David Jang on 6/3/24.
//

import UIKit
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    var onMapTap: (() -> Void)?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.mapTapped))
        mapView.addGestureRecognizer(tapGesture)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(viewModel.region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(viewModel.annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onMapTap: onMapTap)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var onMapTap: (() -> Void)?

        init(_ parent: MapView, onMapTap: (() -> Void)?) {
            self.parent = parent
            self.onMapTap = onMapTap
        }

        @objc func mapTapped() {
            onMapTap?()
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
            if let title = annotation.title, let completion = self.parent.viewModel.searchResults.first(where: { $0.title == title }) {
                self.parent.viewModel.searchForLocation(completion: completion) { location, address in
                    // 필요한 동작을 여기에 추가할 수 있습니다.
                }
            }
        }
    }
}
