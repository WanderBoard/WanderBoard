//
//  MapDetailViewController.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 5/31/24.
//

import UIKit
import MapKit

class MapDetailViewController: UIViewController {

    let mapView = MKMapView()
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
        setupSearchBar()
        setupBackButton()
        setInitialLocation()
        
        view.backgroundColor = .white
    }

    func setupMap() {
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "여행 간 지역을 검색하세요"
        navigationItem.titleView = searchBar
    }
    
    func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    func setInitialLocation() {
        let initialLocation = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        let region = MKCoordinateRegion(center: initialLocation, latitudinalMeters: 3000, longitudinalMeters: 3000)
        mapView.setRegion(region, animated: true)
    }
}


extension MapDetailViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text else { return }
        searchForLocation(searchText)
    }
    
    func searchForLocation(_ location: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = location
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                if error != nil {
                    print( "Search error" )
                }
                return
            }
            
            let mapItems = response.mapItems
            if let firstItem = mapItems.first {
                let coordinate = firstItem.placemark.coordinate
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(firstItem.placemark)
            }
        }
    }
    
}
