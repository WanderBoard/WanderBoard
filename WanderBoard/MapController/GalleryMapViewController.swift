//
//  GalleryMapViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/24/24.
//

import UIKit
import MapKit
import SnapKit
import Contacts

class GalleryMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, ImageInfoViewDelegate {
    
    func didTapSharePinButton(_ sender: UIButton) {
        if let name = imageInfoView.nameLabel.text {
            let activityItems: [Any] = [name]
            let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    let mapView = MKMapView()
    private let viewModel: MapViewModel
    private var onLocationSelected: ((CLLocationCoordinate2D, String) -> Void)?
    private let locationManager = CLLocationManager()
    private var selectedCompletion: MKLocalSearchCompletion?
    private let pinLogManager = PinLogManager()
    private var savedPinLogId: String?
    var pinLocations: [Media] = []
    let imageInfoView = ImageInfoView()
    
    private var pinLogLatitude: Double?
    private var pinLogLongitude: Double?

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 85, height: 85)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.tintColor = .font
        return button
    }()
    
    let lookAroundButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash.circle"), for: .normal)
        button.tintColor = .font
        button.isHidden = true
        return button
    }()
    
    let satelliteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "airplane.circle"), for: .normal)
        button.tintColor = .font
        button.isHidden = false
        return button
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 24
        stackView.backgroundColor = UIColor(named: "textColor")!.withAlphaComponent(0.7)
        stackView.layer.cornerRadius = 20
        stackView.clipsToBounds = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        return stackView
    }()
    
    init(region: MKCoordinateRegion, onLocationSelected: @escaping (CLLocationCoordinate2D, String) -> Void, pinLog: PinLog) {
        self.viewModel = MapViewModel(region: region)
        self.onLocationSelected = onLocationSelected
        self.pinLogLatitude = pinLog.latitude
        self.pinLogLongitude = pinLog.longitude
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        centerMapOnUserLocation()
        addPinsToMap()
        setInitialMapLocation()
        updateSatelliteButtonIcon()
        
        imageInfoView.delegate = self

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        viewModel.onLocationAuthorizationGranted = { [weak self] in
            self?.fetchImages()
        }
        collectionView.register(GalleryMapCollectionViewCell.self, forCellWithReuseIdentifier: GalleryMapCollectionViewCell.identifier)
        
        let coordinate = mapView.centerCoordinate
        checkLookAroundAvailability(for: coordinate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .font
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.font]
    }
    
    private func centerMap(on coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    private func setupViews() {
        view.addSubview(mapView)
        view.addSubview(collectionView)
        view.addSubview(imageInfoView)
        view.addSubview(buttonStackView)

        mapView.delegate = self
        mapView.showsUserLocation = true
        
        collectionView.delegate = self
        collectionView.dataSource = self

        imageInfoView.isHidden = true
        
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        lookAroundButton.addTarget(self, action: #selector(lookAroundButtonTapped), for: .touchUpInside)
        satelliteButton.addTarget(self, action: #selector(satelliteButtonTapped), for: .touchUpInside)
        
        buttonStackView.addArrangedSubview(satelliteButton)
        buttonStackView.addArrangedSubview(lookAroundButton)
        buttonStackView.addArrangedSubview(locationButton)
    }

    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(100)
        }

        imageInfoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(collectionView.snp.top).offset(-16)
            make.height.equalTo(50)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(70)
        }
    }
    
    @objc private func satelliteButtonTapped() {
        if mapView.mapType == .standard {
            mapView.mapType = .satellite
        } else {
            mapView.mapType = .standard
        }
        updateSatelliteButtonIcon()
    }

    private func updateSatelliteButtonIcon() {
        if mapView.mapType == .standard {
            satelliteButton.setImage(UIImage(systemName: "airplane.circle"), for: .normal)
        } else {
            satelliteButton.setImage(UIImage(systemName: "map.circle"), for: .normal)
        }
    }

    @objc private func lookAroundButtonTapped() {
        guard let coordinate = mapView.centerCoordinate as CLLocationCoordinate2D? else { return }
        let lookAroundSceneRequest = MKLookAroundSceneRequest(coordinate: coordinate)
        
        lookAroundSceneRequest.getSceneWithCompletionHandler { [weak self] (scene, error) in
            guard let self = self else { return }
            if let scene = scene {
                let lookAroundViewController = MKLookAroundViewController(scene: scene)
                self.present(lookAroundViewController, animated: true, completion: nil)
            } else {
                print("위치에 Look Around 정보 없음")
            }
        }
    }
    
    private func checkLookAroundAvailability(for coordinate: CLLocationCoordinate2D) {
        let lookAroundSceneRequest = MKLookAroundSceneRequest(coordinate: coordinate)
        
        lookAroundSceneRequest.getSceneWithCompletionHandler { [weak self] (scene, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if scene != nil {
                    self.lookAroundButton.setImage(UIImage(systemName: "eye.circle.fill"), for: .normal)
                    self.lookAroundButton.isHidden = false
                } else {
                    self.lookAroundButton.setImage(UIImage(systemName: "eye.slash.circle"), for: .normal)
                    self.lookAroundButton.isHidden = false
                }
            }
        }
    }

    private func setInitialMapLocation() {
        var initialCoordinate: CLLocationCoordinate2D?
        
        if let representativeMedia = pinLocations.first(where: { $0.isRepresentative }),
           let latitude = representativeMedia.latitude,
           let longitude = representativeMedia.longitude {
            initialCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else if let firstMedia = pinLocations.first(where: { $0.latitude != nil && $0.longitude != nil }),
                  let latitude = firstMedia.latitude,
                  let longitude = firstMedia.longitude {
            initialCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else if let pinLogLatitude = pinLogLatitude, let pinLogLongitude = pinLogLongitude {
            initialCoordinate = CLLocationCoordinate2D(latitude: pinLogLatitude, longitude: pinLogLongitude)
        }
        
        if let coordinate = initialCoordinate {
            centerMap(on: coordinate)
            checkLookAroundAvailability(for: coordinate)
        }
    }
    
    func addPinsToMap() {
        for media in pinLocations {
            if let latitude = media.latitude, let longitude = media.longitude {
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                addPinToMap(location: location, address: "")
            }
        }
    }

    func addPinToMap(location: CLLocationCoordinate2D, address: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = address
        mapView.addAnnotation(annotation)
    }
    
    func animatePin(at coordinate: CLLocationCoordinate2D) {
        let matchingAnnotations = mapView.annotations.filter { $0.coordinate.latitude == coordinate.latitude && $0.coordinate.longitude == coordinate.longitude }
        
        for annotation in matchingAnnotations {
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
    }
    
    func sharePinButtonTapped(_ sender: UIButton) {
        if let name = imageInfoView.nameLabel.text {
            let activityItems: [Any] = [name]
            let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
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

    private func fetchImages() {
        // Firebase에서 이미지를 가져와야함
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
}

extension GalleryMapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pinLocations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryMapCollectionViewCell.identifier, for: indexPath) as? GalleryMapCollectionViewCell else {
            fatalError("UICollectionView dequeue error")
        }
        let media = pinLocations[indexPath.row]
        cell.configure(with: media)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let media = pinLocations[indexPath.row]
        if let latitude = media.latitude, let longitude = media.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            animatePin(at: coordinate)
            mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
            
            checkLookAroundAvailability(for: coordinate)
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                guard let self = self else { return }
                if let error = error {
                    print("Geocoding error: \(error)")
                    return
                }
                if let placemark = placemarks?.first {
                    let name = placemark.name ?? "Unknown Place"
//                    let address = [
//                        placemark.thoroughfare,
//                        placemark.subThoroughfare,
//                        placemark.locality,
//                        placemark.administrativeArea,
//                        placemark.postalCode,
//                        placemark.country
//                    ].compactMap { $0 }.joined(separator: ", ")
                    let phone = ""
                    let website = ""
                    
//                    self.imageInfoView.isHidden = false
                    self.showImageInfoView(name: name, phone: phone, website: website)
                }
            }
        } else {
            print("사진 위치정보 없음")
            imageInfoView.isHidden = true
        }
    }
    
    private func showImageInfoView(name: String, phone: String, website: String) {
        imageInfoView.configure(name: name, phone: phone, website: website)
        imageInfoView.isHidden = false
        imageInfoView.transform = CGAffineTransform(translationX: 0, y: 4)
        UIView.animate(withDuration: 0.3) {
            self.imageInfoView.transform = .identity
        }
    }
}
