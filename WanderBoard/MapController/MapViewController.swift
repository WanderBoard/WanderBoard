//
//  MapViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/1/24.
//

import UIKit
import MapKit
import SnapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    private let mapView = MKMapView()
    private let viewModel: MapViewModel
    private let startDate: Date
    private let endDate: Date
    private var onLocationSelected: ((CLLocationCoordinate2D, String) -> Void)?
    private var isFirstLoad = true
    private let locationManager = CLLocationManager()
    private let tableView = UITableView()
    private let placeInfoView = PlaceInfoView()
    var locationSelected: ((String) -> Void)?

//    private var searchBar: UISearchBar!

    init(viewModel: MapViewModel, startDate: Date, endDate: Date, locationSelected: ((String) -> Void)? = nil) {
        self.viewModel = viewModel
        self.startDate = startDate
        self.endDate = endDate
        self.locationSelected = locationSelected
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupNavigationBar()
        setupLocationButton()
        centerMapOnUserLocation()
        setupTableView()
        setupPlaceInfoView()
        
        placeInfoView.delegate = self

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        viewModel.onLocationAuthorizationGranted = { [weak self] in
            self?.fetchImages()
        }
        viewModel.searchResultsHandler = { [weak self] _ in
            self?.tableView.reloadData()
            self?.adjustTableViewHeight(to: min(self?.viewModel.searchResults.count ?? 0, 7))
        }
        if isFirstLoad {
            viewModel.checkLocationAuthorization()
            isFirstLoad = false
        }
        
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    private func setupPlaceInfoView() {
        view.addSubview(placeInfoView)
        placeInfoView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(300)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(160)
        }
        placeInfoView.isHidden = true
    }

    private func showPlaceInfoView(mapItem: MKMapItem) {
        placeInfoView.configure(
            name: mapItem.name ?? "",
            address: mapItem.placemark.title ?? "", postalCode: mapItem.placemark.postalCode ?? "",
            phone: mapItem.phoneNumber ?? "",
            website: mapItem.url?.absoluteString ?? ""
        )
        placeInfoView.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.placeInfoView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(-16)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func hidePlaceInfoView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.placeInfoView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(300)
            }
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.placeInfoView.isHidden = true
        })
    }
    
    @objc private func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
        tableView.isHidden = true
        navigationItem.titleView?.endEditing(true)
        if let searchBar = navigationItem.titleView as? UISearchBar {
            searchBar.text = ""
        }
        navigationItem.titleView = nil
        setupNavigationBar()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomLocationCell.self, forCellReuseIdentifier: CustomLocationCell.identifier)
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(0)
        }
        tableView.isHidden = true
    }

    private func setupLocationButton() {
        let locationButton = UIButton(type: .system)
        locationButton.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        locationButton.tintColor = .black
        locationButton.addTarget(self, action: #selector(centerMapOnUserLocation), for: .touchUpInside)
        view.addSubview(locationButton)
        locationButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.height.equalTo(50)
        }
    }

    @objc private func centerMapOnUserLocation() {
        if let location = locationManager.location {
            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            mapView.setRegion(region, animated: true)
        }
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .black
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchBar))
        searchButton.isEnabled = true
        navigationItem.rightBarButtonItem = searchButton
    }

    private func fetchImages() {
        // Firebase에서 이미지를 가져오는 로직
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustTableViewHeight(to: min(viewModel.searchResults.count, 7))
    }

    private func adjustTableViewHeight(to numberOfRows: Int) {
        let cellHeight: CGFloat = 55 // 예시: 셀 높이
        let tableHeight = CGFloat(numberOfRows) * cellHeight
        tableView.snp.updateConstraints { make in
            make.height.equalTo(tableHeight)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchQuery = searchText
//        viewModel.updateSearchResults(query: searchText)
        viewModel.startSearchDelay()
    }
    
    @objc private func showSearchBar() {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = true
        searchBar.becomeFirstResponder()
        viewModel.searchResults = []
        tableView.reloadData()
        tableView.isHidden = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
        viewModel.searchResults = []
        tableView.reloadData()
        navigationItem.titleView = nil
        setupNavigationBar()
        navigationItem.hidesBackButton = false
        tableView.isHidden = true
        hidePlaceInfoView()
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = min(viewModel.searchResults.count, 7)
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomLocationCell", for: indexPath) as! CustomLocationCell
        let item = viewModel.searchResults[indexPath.row]
        cell.configure(with: item.title, subtitle: item.subtitle)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = viewModel.searchResults[indexPath.row]
        Task {
            do {
                let mapItem = try await viewModel.searchForLocation(completion: selectedResult)
                self.mapView.setRegion(MKCoordinateRegion(center: mapItem.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: true)
                
                // 기존 핀 제거
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                // 새로운 핀 추가
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = selectedResult.title
                annotation.subtitle = selectedResult.subtitle
                self.mapView.addAnnotation(annotation)
                
                self.tableView.isHidden = true
                self.navigationItem.titleView = nil
                self.setupNavigationBar()
                self.navigationItem.hidesBackButton = false
                
                // PlaceInfoView 업데이트 및 표시
                self.showPlaceInfoView(mapItem: mapItem)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

extension MapViewController: PlaceInfoViewDelegate {
    func didSelectLocation(_ location: String) {
        locationSelected?(location)
        navigationController?.popViewController(animated: true)
    }
}
