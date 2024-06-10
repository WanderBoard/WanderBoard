//
//  ViewController.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 5/28/24.
//



import UIKit
import FirebaseAuth
import SnapKit
import Then
import Photos
import PhotosUI
import MapKit
import SwiftUI
import CoreLocation
import FirebaseStorage
import FirebaseFirestore

protocol DetailInputViewControllerDelegate: AnyObject {
    func didSavePinLog(_ pinLog: PinLog)
}

class DetailInputViewController: UIViewController {
    
    private let locationManager = LocationManager()
    var savedLocation: CLLocationCoordinate2D?
    var savedPinLogId: String?
    var savedAddress: String?
    
    weak var delegate: DetailInputViewControllerDelegate?
    
    var selectedImages: [UIImage] = []
    var selectedFriends: [UIImage] = []
    let pinLogManager = PinLogManager.shared
    
    let subTextFieldMinHeight: CGFloat = 90
    var subTextFieldHeightConstraint: Constraint?
    
    var isEditingPhotos = false
    
    let topContainarView = UIView().then {
        $0.backgroundColor = .black
    }
    
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.bounces = false
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 40
    }
    
    let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let publicLabel = UILabel().then {
        $0.text = "공개 여부"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    let publicSwitch = UISwitch().then {
        $0.isOn = true
        $0.onTintColor = .black
    }
    
    let publicStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    let topLine = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
    }
    
    let dateLabel = UILabel().then {
        $0.text = "날짜"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    let startDateButton = UIButton(type: .system).then {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "시작일자"
        configuration.baseBackgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        configuration.baseForegroundColor = .black
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        $0.configuration = configuration
        $0.tintColor = .black
    }
    
    let endDateLabel = UILabel().then {
        $0.text = "-"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textAlignment = .center
    }
    
    let endDateButton = UIButton(type: .system).then {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "종료일자"
        configuration.baseBackgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        configuration.baseForegroundColor = .black
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        $0.configuration = configuration
        $0.tintColor = .black
    }
    
    let dateContainerView = UIView()
    
    let mainTextField = UITextView().then {
        $0.text = "여행 제목을 입력해주세요."
        $0.textColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.isScrollEnabled = false
    }
    
    let subTextField = UITextView().then {
        $0.text = "기록을 담아 주세요."
        $0.textColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.isScrollEnabled = false
    }
    
    let locationButton = UIButton().then {
        $0.backgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    
    let locationLeftLabel = UILabel().then {
        $0.text = "지역을 선택하세요"
        $0.font = UIFont.systemFont(ofSize: 15)
    }
    
    let locationRightLabel = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .black
    }
    
    let locationStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
        $0.isUserInteractionEnabled = false
    }
    
    let consumButton = UIButton().then {
        $0.backgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    
    let consumLeftLabel = UILabel().then {
        $0.text = "지출 내역을 추가하세요"
        $0.font = UIFont.systemFont(ofSize: 15)
    }
    
    let consumRightLabel = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .black
    }
    
    let consumStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
        $0.isUserInteractionEnabled = false
    }
    
    let bodyLine = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
    }
    
    let galleryLabel = UILabel().then {
        $0.text = "앨범 추가"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 32, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 85, height: 85)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let galleryInstructionLabel = UILabel().then {
        $0.text = "사진을 꾸욱 누르면 삭제가 가능합니다."
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = #colorLiteral(red: 0.5913596153, green: 0.5913596153, blue: 0.5913596153, alpha: 1)
        $0.isHidden = true
        $0.textAlignment = .center
    }
    
    let galleryCountButton = UIButton(type: .system).then {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 40, bottom: 8, trailing: 40)
        $0.configuration = configuration
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }
    
    let galleryCountLabel = UILabel().then {
        $0.text = "0/10"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = #colorLiteral(red: 0.5913596153, green: 0.5913596153, blue: 0.5913596153, alpha: 1)
    }
    
    let galleryArrowImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .black
    }
    
    let galleryCountStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 4
        $0.isUserInteractionEnabled = false
    }
    
    let mateLabel = UILabel().then {
        $0.text = "메이트"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    lazy var mateCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 85, height: 85)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        actionButton()
        setupTextView()
        setupCollectionView()
        setupNavigationBar()
        requestPhotoLibraryAccess()
        
        print("DetailInputViewController loaded") // 디버깅을 위해 추가
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    func setupUI() {
        view.addSubview(topContainarView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(publicStackView)
        contentView.addSubview(topLine)
        
        publicStackView.addArrangedSubview(publicLabel)
        publicStackView.addArrangedSubview(publicSwitch)
        
        contentView.addSubview(dateContainerView)
        dateContainerView.addSubview(dateLabel)
        dateContainerView.addSubview(startDateButton)
        dateContainerView.addSubview(endDateLabel)
        dateContainerView.addSubview(endDateButton)
        
        contentView.addSubview(mainTextField)
        contentView.addSubview(subTextField)
        contentView.addSubview(locationButton)
        locationButton.addSubview(locationStackView)
        contentView.addSubview(consumButton)
        consumButton.addSubview(consumStackView)
        
        locationStackView.addArrangedSubview(locationLeftLabel)
        locationStackView.addArrangedSubview(locationRightLabel)
        consumStackView.addArrangedSubview(consumLeftLabel)
        consumStackView.addArrangedSubview(consumRightLabel)
        
        contentView.addSubview(bodyLine)
        contentView.addSubview(galleryLabel)
        contentView.addSubview(galleryCollectionView)
        contentView.addSubview(galleryInstructionLabel)
        contentView.addSubview(galleryCountButton)
        galleryCountButton.addSubview(galleryCountStackView)
        
        galleryCountStackView.addArrangedSubview(galleryCountLabel)
        galleryCountStackView.addArrangedSubview(galleryArrowImageView)
        
        contentView.addSubview(mateLabel)
        contentView.addSubview(mateCollectionView)
        
    }
    
    func setupConstraints() {
        topContainarView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(150)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(topContainarView.snp.bottom).offset(-40)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(40)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.bottom.equalTo(mateCollectionView.snp.bottom).offset(50)
        }
        
        publicStackView.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(40)
            $0.leading.trailing.equalTo(contentView).inset(32)
        }
        
        topLine.snp.makeConstraints {
            $0.top.equalTo(publicStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(contentView).inset(16)
            $0.height.equalTo(1)
        }
        
        dateContainerView.snp.makeConstraints {
            $0.top.equalTo(topLine.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(44)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(dateContainerView.snp.leading)
            $0.centerY.equalTo(dateContainerView.snp.centerY)
        }
        
        endDateButton.snp.makeConstraints {
            $0.trailing.equalTo(dateContainerView.snp.trailing)
            $0.centerY.equalTo(dateContainerView.snp.centerY)
            $0.height.equalTo(44)
        }
        
        endDateLabel.snp.makeConstraints {
            $0.trailing.equalTo(endDateButton.snp.leading).offset(-10)
            $0.centerY.equalTo(dateContainerView.snp.centerY)
        }
        
        startDateButton.snp.makeConstraints {
            $0.trailing.equalTo(endDateLabel.snp.leading).offset(-10)
            $0.centerY.equalTo(dateContainerView.snp.centerY)
            $0.height.equalTo(44)
        }
        
        mainTextField.snp.makeConstraints {
            $0.top.equalTo(dateContainerView.snp.bottom).offset(32)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(37)
        }
        
        subTextField.snp.makeConstraints {
            $0.top.equalTo(mainTextField.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView).inset(32)
            self.subTextFieldHeightConstraint = $0.height.greaterThanOrEqualTo(subTextFieldMinHeight).constraint
        }
        
        locationButton.snp.makeConstraints {
            $0.top.equalTo(subTextField.snp.bottom).offset(32)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(46)
        }
        
        locationStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        consumButton.snp.makeConstraints {
            $0.top.equalTo(locationButton.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(46)
        }
        
        consumStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        bodyLine.snp.makeConstraints {
            $0.top.equalTo(consumButton.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(contentView).inset(16)
            $0.height.equalTo(1)
        }
        
        galleryLabel.snp.makeConstraints {
            $0.top.equalTo(bodyLine.snp.bottom).offset(16)
            $0.leading.equalTo(contentView).inset(32)
        }
        
        galleryInstructionLabel.snp.makeConstraints {
            $0.top.equalTo(bodyLine.snp.bottom).offset(18)
            $0.trailing.equalTo(contentView).inset(32)
        }
        
        galleryCollectionView.snp.makeConstraints {
            $0.top.equalTo(galleryLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(contentView)
            $0.height.equalTo(100)
        }
        
        galleryCountButton.snp.makeConstraints {
            $0.top.equalTo(galleryCollectionView.snp.bottom).offset(5)
            $0.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(44)
        }
        
        galleryCountStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        mateLabel.snp.makeConstraints {
            $0.top.equalTo(galleryCollectionView.snp.bottom).offset(50)
            $0.leading.equalTo(contentView).inset(32)
        }
        
        mateCollectionView.snp.makeConstraints {
            $0.top.equalTo(mateLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(contentView)
            $0.height.equalTo(100)
        }
    }
    
    func setupCollectionView() {
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        
        mateCollectionView.delegate = self
        mateCollectionView.dataSource = self
        
        galleryCollectionView.register(GallaryInPutCollectionViewCell.self, forCellWithReuseIdentifier: GallaryInPutCollectionViewCell.identifier)
        mateCollectionView.register(FriendInputCollectionViewCell.self, forCellWithReuseIdentifier: FriendInputCollectionViewCell.identifier)
        
    }
    
    func setupTextView() {
        mainTextField.delegate = self
        subTextField.delegate = self
    }
    
    func actionButton() {
        startDateButton.addTarget(self, action: #selector(showDatePicker(_:)), for: .touchUpInside)
        endDateButton.addTarget(self, action: #selector(showDatePicker(_:)), for: .touchUpInside)
        galleryCountButton.addTarget(self, action: #selector(showPHPicker), for: .touchUpInside)
        
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        consumButton.addTarget(self, action: #selector(consumButtonTapped), for: .touchUpInside)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        galleryCollectionView.addGestureRecognizer(longPressGesture)
        
        
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: galleryCollectionView)
        guard let _ = galleryCollectionView.indexPathForItem(at: point), !selectedImages.isEmpty else { return }
        
        if gesture.state == .began {
            isEditingPhotos = true
            startShakingCells()
        }
    }
    
    @objc func locationButtonTapped() {
        print("locationButtonTapped called")
        
        Task {
            do {
                let (savedLocation, savedAddress) = try await fetchSavedLocation()
                
                let center: CLLocationCoordinate2D
                if let savedLocation = savedLocation {
                    center = savedLocation
                } else {
                    // 기본 위치 설정 (샌프란시스코)
                    center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
                }
                
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                
                let mapVC = MapViewController(region: region, startDate: Date(), endDate: Date(), onLocationSelected: { [weak self] (selectedLocation: CLLocationCoordinate2D, address: String) in
                    guard let self = self else { return }
                    self.updateLocationLabel(with: address)
                    self.savedLocation = selectedLocation
                    self.savedAddress = address
                    
                    // Firestore에 저장
                    self.saveLocationToFirestore(location: selectedLocation, address: address)
                })
                
                // 저장된 위치가 있으면 해당 위치에 핀을 생성
                if let savedLocation = savedLocation, let savedAddress = savedAddress {
                    mapVC.addPinToMap(location: savedLocation, address: savedAddress)
                }
                
                self.navigationController?.pushViewController(mapVC, animated: true)
            } catch {
                print("Error fetching saved location from Firestore: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchSavedLocation() async throws -> (CLLocationCoordinate2D?, String?) {
        let userId = Auth.auth().currentUser?.uid ?? ""
        let documentRef = Firestore.firestore().collection("users").document(userId)
        
        let document = try await documentRef.getDocument()
        if let data = document.data(), let latitude = data["latitude"] as? CLLocationDegrees, let longitude = data["longitude"] as? CLLocationDegrees {
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let address = data["address"] as? String
            return (location, address)
        } else {
            return (nil, nil)
        }
    }
    
    func updateLocationLabel(with address: String) {
        self.locationLeftLabel.text = address
    }
    
    private func saveLocationToFirestore(location: CLLocationCoordinate2D, address: String) {
        guard let pinLogId = self.savedPinLogId else {
            createNewPinLog(location: location, address: address)
            return
        }
        
        let data: [String: Any] = [
            "location": GeoPoint(latitude: location.latitude, longitude: location.longitude),
            "address": address,
        ]
        
        Task {
            do {
                try await PinLogManager.shared.updatePinLog(pinLogId: pinLogId, data: data)
                print("Location updated successfully in Firestore")
            } catch {
                print("Error updating location in Firestore: \(error.localizedDescription)")
            }
        }
    }
    
    private func createNewPinLog(location: CLLocationCoordinate2D, address: String) {
        var pinLog = PinLog(location: address, address: address, latitude: location.latitude, longitude: location.longitude, startDate: Date(), endDate: Date(), title: "", content: "", media: [], authorId: Auth.auth().currentUser?.uid ?? "", attendeeIds: [], isPublic: true)
        
        Task {
            do {
                let savedPinLog = try await PinLogManager.shared.createOrUpdatePinLog(pinLog: &pinLog, images: [])
                self.savedPinLogId = savedPinLog.id
            } catch {
                print("Error creating new pin log in Firestore: \(error.localizedDescription)")
            }
        }
    }
    
    func loadSavedLocation() {
        let userId = Auth.auth().currentUser?.uid ?? ""
        let documentRef = Firestore.firestore().collection("users").document(userId)
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                if let latitude = data["latitude"] as? CLLocationDegrees,
                   let longitude = data["longitude"] as? CLLocationDegrees {
                    self.savedLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let address = data["address"] as? String ?? ""
                    self.updateLocationLabel(with: address)
                }
            }
        }
    }
    
    @objc func consumButtonTapped() {
        let spendVC = SpendingListViewController()
        navigationController?.pushViewController(spendVC, animated: true)
    }
    
    @objc func showDatePicker(_ sender: UIButton) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let alert = UIAlertController(title: "날짜 선택", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker)
        
        datePicker.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(alert.view)
            $0.bottom.equalTo(alert.view.snp.bottom).offset(-44)
        }
        
        let selectAction = UIAlertAction(title: "선택", style: .default) { _ in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let selectedDate = dateFormatter.string(from: datePicker.date)
            sender.setTitle(selectedDate, for: .normal)
        }
        
        alert.addAction(selectAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func setupNavigationBar() {
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func doneButtonTapped() {
        guard let locationTitle = locationLeftLabel.text, locationTitle != "지역을 선택하세요" else {
            let alert = UIAlertController(title: "오류", message: "지역을 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDateString = startDateButton.title(for: .normal),
              let endDateString = endDateButton.title(for: .normal),
              let startDate = dateFormatter.date(from: startDateString),
              let endDate = dateFormatter.date(from: endDateString) else {
            let alert = UIAlertController(title: "오류", message: "유효한 날짜를 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let title = mainTextField.text ?? ""
        let content = subTextField.text ?? ""
        let isPublic = publicSwitch.isOn
        let address = savedAddress ?? "Unknown Address"
        let latitude = savedLocation?.latitude ?? 0.0
        let longitude = savedLocation?.longitude ?? 0.0
        
        Task {
            do {
                var pinLog: PinLog
                
                if let pinLogId = self.savedPinLogId {
                    // 핀로그가 이미 존재하는 경우 업데이트
                    pinLog = PinLog(id: pinLogId,
                                    location: locationTitle,
                                    address: address,
                                    latitude: latitude,
                                    longitude: longitude,
                                    startDate: startDate,
                                    endDate: endDate,
                                    title: title,
                                    content: content,
                                    media: [],
                                    authorId: Auth.auth().currentUser?.uid ?? "",
                                    attendeeIds: [],
                                    isPublic: isPublic)
                } else {
                    // 핀로그가 존재하지 않는 경우 새로 생성
                    pinLog = PinLog(location: locationTitle,
                                    address: address,
                                    latitude: latitude,
                                    longitude: longitude,
                                    startDate: startDate,
                                    endDate: endDate,
                                    title: title,
                                    content: content,
                                    media: [],
                                    authorId: Auth.auth().currentUser?.uid ?? "",
                                    attendeeIds: [],
                                    isPublic: isPublic)
                }
                
                let savedPinLog = try await PinLogManager.shared.createOrUpdatePinLog(pinLog: &pinLog, images: selectedImages)
                self.savedPinLogId = savedPinLog.id
                delegate?.didSavePinLog(savedPinLog)
                navigationController?.popViewController(animated: true)
            } catch {
                let alert = UIAlertController(title: "오류", message: "데이터 저장에 실패했습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func updateGalleryCountButton() {
        let count = selectedImages.count
        galleryCountLabel.text = "\(count)/10"
        galleryCountButton.isHidden = count == 0
        galleryInstructionLabel.isHidden = count == 0
    }
    
    
    func createCollectionViewFlowLayout(for collectionView: UICollectionView) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 85, height: 85)
        return layout
    }
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        if isEditingPhotos {
            stopShakingCells()
            isEditingPhotos = false
        }
    }
    
    func startShakingCells() {
        for case let cell as GallaryInPutCollectionViewCell in galleryCollectionView.visibleCells {
            cell.showDeleteButton(true)
            shake(cell: cell)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func stopShakingCells() {
        for case let cell as GallaryInPutCollectionViewCell in galleryCollectionView.visibleCells {
            cell.showDeleteButton(false)
            cell.layer.removeAllAnimations()
        }
    }
    
    func shake(cell: UICollectionViewCell) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = -0.05
        animation.toValue = 0.05
        animation.duration = 0.1
        animation.repeatCount = .greatestFiniteMagnitude
        animation.autoreverses = true
        cell.layer.add(animation, forKey: "shake")
    }
    
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
                case .authorized:
                    print("사진 접근 권한이 허용되었습니다.")
                case .denied, .restricted, .notDetermined:
                    print("사진 접근 권한이 거부되었습니다.")
                case .limited:
                    print("사진 접근 권한이 제한되었습니다.")
                @unknown default:
                    fatalError("새로운 권한 상태")
            }
        }
    }
    
    @objc func showPHPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10 - selectedImages.count
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func extractLocation(from data: Data) -> CLLocationCoordinate2D? {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
              let gpsData = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any],
              let latitude = gpsData[kCGImagePropertyGPSLatitude] as? Double,
              let longitude = gpsData[kCGImagePropertyGPSLongitude] as? Double,
              let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef] as? String,
              let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef] as? String else {
                  return nil
              }

        let lat = latitudeRef == "S" ? -latitude : latitude
        let lon = longitudeRef == "W" ? -longitude : longitude

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    //    func extractCreationDate(from result: PHPickerResult) -> Date? {
    //        var creationDate: Date? = nil
    //        let dispatchGroup = DispatchGroup()
    //        dispatchGroup.enter()
    //
    //        result.itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { (item, error) in
    //            if let url = item as? URL {
    //                if let source = CGImageSourceCreateWithURL(url as CFURL, nil),
    //                   let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
    //                   let exifData = metadata[kCGImagePropertyExifDictionary] as? [CFString: Any],
    //                   let dateString = exifData[kCGImagePropertyExifDateTimeOriginal] as? String {
    //
    //                    let dateFormatter = DateFormatter()
    //                    dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
    //                    creationDate = dateFormatter.date(from: dateString)
    //                }
    //            }
    //            dispatchGroup.leave()
    //        }
    //
    //        dispatchGroup.wait()
    //        return creationDate
    //    }
    
    
    @objc func deletePhoto(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? GallaryInPutCollectionViewCell,
              let indexPath = galleryCollectionView.indexPath(for: cell) else { return }
        
        selectedImages.remove(at: indexPath.row)
        if selectedImages.isEmpty {
            isEditingPhotos = false
            galleryCollectionView.reloadData()
            updateGalleryCountButton()
        } else {
            galleryCollectionView.performBatchUpdates({
                galleryCollectionView.deleteItems(at: [indexPath])
            }) { _ in
                self.updateGalleryCountButton()
            }
        }
    }
}

extension DetailInputViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == galleryCollectionView {
            return selectedImages.isEmpty ? 1 : selectedImages.count
        } else if collectionView == mateCollectionView {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == galleryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GallaryInPutCollectionViewCell.identifier, for: indexPath) as? GallaryInPutCollectionViewCell else {fatalError("컬렉션뷰 오류")}
            if selectedImages.isEmpty {
                cell.configure(with: nil, isEditing: isEditingPhotos)
            } else {
                cell.configure(with: selectedImages[indexPath.row], isEditing: isEditingPhotos)
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendInputCollectionViewCell.identifier, for: indexPath) as? FriendInputCollectionViewCell else { fatalError("컬렉션뷰 오류")}
            if selectedFriends.isEmpty {
                cell.configure(with: nil)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedImages.isEmpty || indexPath.row == selectedImages.count {
            showPHPicker()
        }
    }
}

extension DetailInputViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        var newImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()

        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    newImages.append(image)
                    result.itemProvider.loadDataRepresentation(forTypeIdentifier: "public.jpeg") { data, error in
                        if let error = error {
                            print("Error loading data representation: \(error.localizedDescription)")
                            return
                        }
                        guard let data = data else {
                            print("No data found.")
                            return
                        }
                        if let location = self.extractLocation(from: data) {
                            print("위치 정보: \(location.latitude), \(location.longitude)")
                        } else {
                            print("위치 정보가 없습니다.")
                        }
                    }
                } else {
                    print("이미지를 로드하는 중 오류 발생: \(error?.localizedDescription ?? "알 수 없는 오류")")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.selectedImages.append(contentsOf: newImages.prefix(10 - self.selectedImages.count))
            self.galleryCollectionView.reloadData()
            self.updateGalleryCountButton()
        }
    }}

extension DetailInputViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1) {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == mainTextField {
                textView.text = "여행 제목을 입력해주세요."
            } else if textView == subTextField {
                textView.text = "기록을 담아 주세요."
            }
            textView.textColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            textView.isScrollEnabled = false
            self.subTextFieldHeightConstraint?.update(offset: max(newSize.height, subTextFieldMinHeight))
            UIView.setAnimationsEnabled(true)
            textView.layoutIfNeeded()
        }
    }
}
