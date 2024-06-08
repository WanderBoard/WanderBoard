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

    init(viewModel: MapViewModel, startDate: Date, endDate: Date, onLocationSelected: ((CLLocationCoordinate2D, String) -> Void)?) {
        self.viewModel = viewModel
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
        navigationItem.rightBarButtonItem = searchButton
    }

    @objc private func showSearchBar() {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = true
        searchBar.becomeFirstResponder()
        tableView.isHidden = false
    }
    
    @objc private func handleMapTap(gestureRecognizer: UITapGestureRecognizer) {
        tableView.isHidden = true
        navigationItem.titleView?.endEditing(true)
        if let searchBar = navigationItem.titleView as? UISearchBar {
            searchBar.text = ""
        }
        navigationItem.titleView = nil
        setupNavigationBar()
    }

    private func fetchImages() {
        // Firebase에서 이미지를 가져오는 로직
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustTableViewHeight(to: min(viewModel.searchResults.count, 7))
        applyBottomCornerRadius()
    }

    private func adjustTableViewHeight(to numberOfRows: Int) {
        let cellHeight: CGFloat = 55 // 예시: 셀 높이
        let tableHeight = CGFloat(numberOfRows) * cellHeight + 10
        tableView.snp.updateConstraints { make in
            make.height.equalTo(tableHeight)
        }
    }

    private func applyBottomCornerRadius() {
        let path = UIBezierPath(roundedRect: tableView.bounds,
                                byRoundingCorners: [.bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: 16, height: 16))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        tableView.layer.mask = mask
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchQuery = searchText
        viewModel.updateSearchResults(query: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
        navigationItem.titleView = nil
        setupNavigationBar()
        navigationItem.hidesBackButton = false
        tableView.isHidden = true
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = min(viewModel.searchResults.count, 7)
        adjustTableViewHeight(to: count)
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
        viewModel.searchForLocation(completion: selectedResult) { [weak self] coordinate, address in
            guard let self = self else { return }
            self.mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: true)
            
            // 기존 핀 제거
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            // 새로운 핀 추가
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = selectedResult.title
            annotation.subtitle = selectedResult.subtitle
            self.mapView.addAnnotation(annotation)
            
            self.tableView.isHidden = true
            self.navigationItem.titleView = nil
            self.setupNavigationBar()
            self.navigationItem.hidesBackButton = false
        }
    }
}
