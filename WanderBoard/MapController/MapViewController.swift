//
//  MapViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/1/24.
//

import UIKit
import MapKit
import SnapKit
import Contacts

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let mapView = MKMapView()
    private let viewModel: MapViewModel
    private let startDate: Date
    private let endDate: Date
    private var onLocationSelected: ((CLLocationCoordinate2D, String) -> Void)?
    private var isFirstLoad = true
    private let locationManager = CLLocationManager()
    private let tableView = UITableView()
    private let placeInfoView = PlaceInfoView()
    private var selectedCompletion: MKLocalSearchCompletion?
    private let pinLogManager = PinLogManager()
    private var savedPinLogId: String?
    var pinLocations: [CLLocationCoordinate2D] = []


    init(region: MKCoordinateRegion, startDate: Date, endDate: Date, onLocationSelected: @escaping (CLLocationCoordinate2D, String) -> Void) {
        self.viewModel = MapViewModel(region: region)
        self.startDate = startDate
        self.endDate = endDate
        self.onLocationSelected = onLocationSelected
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
        addPinsToMap()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        viewModel.onLocationAuthorizationGranted = { [weak self] in
            self?.fetchImages()
        }
        viewModel.searchResultsHandler = { [weak self] _ in
            self?.tableView.reloadData()
            self?.adjustTableViewHeight(to: min(self?.viewModel.searchResults.count ?? 0, 8))
        }
        if isFirstLoad {
            viewModel.checkLocationAuthorization()
            isFirstLoad = false
        }
        placeInfoView.savePinButton.addTarget(self, action: #selector(savePinTapped), for: .touchUpInside)
        
        for location in pinLocations {
            addPinToMap(location: location, address: "")
        }

        // Center map on the first pin location
        if let firstLocation = pinLocations.first {
            let region = MKCoordinateRegion(center: firstLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
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
    
    func addPinsToMap() {
        for location in pinLocations {
            addPinToMap(location: location, address: "")
        }
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
            address: mapItem.placemark.title?.replacingOccurrences(of: ", 대한민국", with: "") ?? "",
            postalCode: mapItem.placemark.postalCode ?? "",
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
    
    func addPinToMap(location: CLLocationCoordinate2D, address: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = address
        mapView.addAnnotation(annotation)

    }
    
    func animatePin(at coordinate: CLLocationCoordinate2D) {
        guard let annotation = mapView.annotations.first(where: { $0.coordinate.latitude == coordinate.latitude && $0.coordinate.longitude == coordinate.longitude }) else {
            return
        }

        if let annotationView = mapView.view(for: annotation) {
            let originalTransform = annotationView.transform
            UIView.animate(withDuration: 0.2, animations: {
                annotationView.transform = originalTransform.scaledBy(x: 1.5, y: 1.5)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    annotationView.transform = originalTransform
                }
            }
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
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        view.addSubview(locationButton)
        locationButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.height.equalTo(50)
        }
    }
    
    @objc private func locationButtonTapped() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            centerMapOnUserLocation()
        } else {
            showLocationSettingsAlert()
        }
    }
    
    private func showLocationSettingsAlert() {
        let alertController = UIAlertController(
            title: "위치 접근 필요",
            message: "설정에서 위치 접근을 허용해 주세요.",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "설정", style: .default) { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func centerMapOnUserLocation() {
        if let location = locationManager.location {
            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            centerMapOnUserLocation()
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
        // Firebase에서 이미지를 가져와야함
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
    
    
    
    func updateAddressLabel(with address: String) {
        // 주소 레이블을 업데이트
        placeInfoView.configure(name: "", address: address, postalCode: "", phone: "", website: "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchQuery = searchText
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
    
    @objc private func savePinTapped() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            guard let annotation = self.mapView.annotations.first(where: { $0 is MKPointAnnotation }) as? MKPointAnnotation else {
                return
            }

            let selectedLocation = annotation.coordinate
            let address = annotation.title ?? "주소 없음"

            self.onLocationSelected?(selectedLocation, address)
            self.navigationController?.popViewController(animated: true)
        }
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
        self.selectedCompletion = selectedResult

        Task {
            do {
                let mapItem = try await viewModel.searchForLocation(completion: selectedResult)

                let region = MKCoordinateRegion(center: mapItem.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.mapView.setRegion(region, animated: true)

                self.mapView.removeAnnotations(self.mapView.annotations)

                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name

                if let postalAddress = mapItem.placemark.postalAddress {
                    let formatter = CNPostalAddressFormatter()
                    formatter.style = .mailingAddress
                    var addressString = formatter.string(from: postalAddress)
                    addressString = addressString.replacingOccurrences(of: "\n", with: ", ")
                    addressString = addressString.replacingOccurrences(of: "대한민국", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    annotation.customSubtitle = addressString
                }

                self.mapView.addAnnotation(annotation)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                }

                self.tableView.isHidden = true
                self.navigationItem.titleView = nil
                self.setupNavigationBar()
                self.navigationItem.hidesBackButton = false
                self.showPlaceInfoView(mapItem: mapItem)
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

