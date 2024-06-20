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
import Contacts
import Kingfisher


protocol DetailInputViewControllerDelegate: AnyObject {
    func didSavePinLog(_ pinLog: PinLog)
}

class DetailInputViewController: UIViewController, CalendarHostingControllerDelegate {
    
    var progressViewController: ProgressViewController?

    private let locationManager = LocationManager()
    var savedLocation: CLLocationCoordinate2D?
    var savedPinLogId: String?
    var savedAddress: String?
    
    weak var delegate: DetailInputViewControllerDelegate?
    
    var selectedImages: [(UIImage, Bool, CLLocationCoordinate2D?)] = []
    var selectedFriends: [UserSummary] = []
    var representativeImageIndex: Int? = 0
    
    var totalSpendingAmountText: String? {
        didSet {
            consumLeftLabel.text = totalSpendingAmountText
        }
    }
    
    var imageLocations: [CLLocationCoordinate2D] = []
    let pinLogManager = PinLogManager()
    var pinLog: PinLog?
    var expenses: [DailyExpenses] = []
    let subTextFieldMinHeight: CGFloat = 90
    var subTextFieldHeightConstraint: Constraint?
    var publicViewHeightConstraint: Constraint?
    
    let topContainarView = UIView().then {
        $0.backgroundColor = .font
    }
    
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.bounces = false
        $0.backgroundColor = UIColor(named: "textColor")
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 40
    }
    
    let contentView = UIView().then {
        $0.backgroundColor = UIColor(named: "textColor")
    }
    
    let publicView = UIView().then {
        $0.backgroundColor = .clear
        $0.isHidden = true
    }
    
    let publicMainLabel = UILabel().then {
        $0.text = "공개 여부"
        $0.textColor = .font
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    }
    
    let publicOpenButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        $0.tintColor = .font
    }
    
    let publicOpenStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    let publicLabel = UILabel().then {
        $0.text = "게시물 공개 여부"
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = .font
    }
    
    let publicSwitch = UISwitch().then {
        $0.isOn = true
        $0.thumbTintColor = UIColor(named: "textColor")
        $0.onTintColor = .font
    }
    
    let publicStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    let spendingPublicSwitch = UISwitch().then {
        $0.isOn = true
        $0.thumbTintColor = UIColor(named: "textColor")
        $0.onTintColor = .font
    }
    
    let spendingPublicLabel = UILabel().then {
        $0.text = "지출 공개 여부"
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = .font
    }
    
    let spendingPublicStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
        
    }
    
    let toggleSwitchStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 20
    }
    
    let topLine = UIView().then {
        $0.backgroundColor = .lightgray
    }
    
    let locationLeftLabel = UILabel().then {
        $0.text = "지역을 선택하세요"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkgray
    }
    
    let locationRightLabel = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .font
    }
    
    let locationStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
        $0.isUserInteractionEnabled = false
    }
    
    let dateLabel = UILabel().then {
        $0.text = "날짜를 선택하세요"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkgray
        $0.isHidden = false
    }
    
    let dateRightLabel = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .font
    }
    
    let dateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
        $0.isUserInteractionEnabled = false
    }
    
    let dateButton = UIButton().then {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .babygray
        configuration.baseForegroundColor = .font
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        $0.configuration = configuration
        $0.tintColor = .font
    }
    
    
    let mainTextField = UITextView().then {
        $0.text = "여행 제목을 입력해주세요."
        $0.textColor = .lightgray
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightgray.cgColor
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.isScrollEnabled = false
    }
    
    let subTextField = UITextView().then {
        $0.text = "기록을 담아 주세요."
        $0.textColor = .lightgray
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.lightgray.cgColor
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.isScrollEnabled = false
        $0.returnKeyType = .default
    }
    
    let locationButton = UIButton().then {
        $0.backgroundColor = .babygray
        $0.layer.cornerRadius = 8
    }
    
    let consumButton = UIButton().then {
        $0.backgroundColor = .babygray
        $0.layer.cornerRadius = 8
    }
    
    let consumLeftLabel = UILabel().then {
        $0.text = "지출 내역을 추가하세요"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkgray
    }
    
    let consumRightLabel = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .darkgray
    }
    
    let consumStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
        $0.isUserInteractionEnabled = false
    }
    
    let bodyLine = UIView().then {
        $0.backgroundColor = .lightblack
    }
    
    let galleryLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.textColor = .font
        
        let imageAttachment = NSTextAttachment()
        let systemImage = UIImage(systemName: "photo")?.withTintColor(.font, renderingMode: .alwaysOriginal)
        imageAttachment.image = systemImage
        imageAttachment.bounds = CGRect(x: 0, y: -5, width: 24, height: 18.4)
        
        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: " 앨범 추가", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .bold)]))
        
        $0.attributedText = fullString
    }
    
    lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 32, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 85, height: 85)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let galleryCountButton = UIButton(type: .system).then {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .babygray
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 32, bottom: 8, trailing: 40)
        $0.configuration = configuration
        $0.layer.cornerRadius = 10
        $0.isHidden = true
    }
    
    let galleryCountLabel = UILabel().then {
        $0.text = "0/10"
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .darkgray
    }
    
    let galleryArrowImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .darkgray
    }
    
    let galleryCountStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
        $0.isUserInteractionEnabled = false
    }
    
    let mateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.textColor = .font
        
        let imageAttachment = NSTextAttachment()
        let systemImage = UIImage(systemName: "person.2")?.withTintColor(.font, renderingMode: .alwaysOriginal)
        imageAttachment.image = systemImage
        imageAttachment.bounds = CGRect(x: 0, y: -5, width: 24, height: 16.61)
        
        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: " 메이트", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .bold)]))
        
        $0.attributedText = fullString
    }
    
    lazy var mateCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 32, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    
    
    // MARK: 토글토글
    
    
    let mateCountButton = UIButton(type: .system).then {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .babygray
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 32, bottom: 8, trailing: 40)
        $0.configuration = configuration
        $0.layer.cornerRadius = 10
        $0.isHidden = true
    }
    
    let mateCountLabel = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .darkgray
    }
    
    let mateIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person")
        $0.tintColor = .darkgray
    }
    
    let mateCountStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
        $0.isUserInteractionEnabled = false
    }
    
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    
    func didSelectDates(startDate: Date, endDate: Date) {
        print("didSelectDates 호출됨")
        updateDateLabel(with: startDate, endDate: endDate)
        selectedStartDate = startDate
        selectedEndDate = endDate
    }
    
    
    func updateDateLabel(with startDate: Date, endDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        let dateRangeString = "\(startDateString) ~ \(endDateString)"
        print("updateDateLabel 호출됨: \(dateRangeString)")
        
        // dateLabel의 텍스트 업데이트
        self.dateLabel.text = dateRangeString
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        actionButton()
        setupTextView()
        setupCollectionView()
        setupNavigationBar()
        requestPhotoLibraryAccess()
        updateColor()
        
        mainTextField.delegate = self
        subTextField.delegate = self
        
        if let pinLog = pinLog {
            configureView(with: pinLog)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = UIColor (named: "textColor")
        navigationItem.largeTitleDisplayMode = .never
        
    }
    
    func setupUI() {
        view.addSubview(topContainarView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(publicOpenStackView)
        contentView.addSubview(publicView)
        publicView.addSubview(toggleSwitchStackView)
        contentView.addSubview(topLine)
        
        publicOpenStackView.addArrangedSubview(publicMainLabel)
        publicOpenStackView.addArrangedSubview(publicOpenButton)
        publicStackView.addArrangedSubview(publicLabel)
        publicStackView.addArrangedSubview(publicSwitch)
        spendingPublicStackView.addArrangedSubview(spendingPublicLabel)
        spendingPublicStackView.addArrangedSubview(spendingPublicSwitch)
        toggleSwitchStackView.addArrangedSubview(publicStackView)
        toggleSwitchStackView.addArrangedSubview(spendingPublicStackView)
        
        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(dateRightLabel)
        contentView.addSubview(dateButton)
        dateButton.addSubview(dateStackView)
        
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
        contentView.addSubview(galleryCountButton)
        galleryCountButton.addSubview(galleryCountStackView)
        
        galleryCountStackView.addArrangedSubview(galleryCountLabel)
        galleryCountStackView.addArrangedSubview(galleryArrowImageView)
        
        contentView.addSubview(mateLabel)
        contentView.addSubview(mateCollectionView)
        contentView.addSubview(mateCountButton)
        mateCountButton.addSubview(mateCountStackView)
        mateCountStackView.addArrangedSubview(mateIconImageView)
        mateCountStackView.addArrangedSubview(mateCountLabel)
        
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
            $0.bottom.equalTo(mateCountButton.snp.bottom).offset(30)
        }
        
        publicOpenStackView.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(40)
            $0.leading.trailing.equalTo(contentView).inset(32)
        }
        
        publicView.snp.makeConstraints {
            $0.top.equalTo(publicOpenStackView.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(contentView).inset(32)
            self.publicViewHeightConstraint = $0.height.equalTo(0).constraint
        }
        
        toggleSwitchStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        publicStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        spendingPublicStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        topLine.snp.makeConstraints {
            $0.top.equalTo(publicView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(16)
            $0.height.equalTo(1)
        }
        
        locationButton.snp.makeConstraints {
            $0.top.equalTo(topLine.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(44)
        }
        
        locationStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        dateButton.snp.makeConstraints {
            $0.top.equalTo(locationButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(44)
        }
        
        dateStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        mainTextField.snp.makeConstraints {
            $0.top.equalTo(dateButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(44)
        }
        
        subTextField.snp.makeConstraints {
            $0.top.equalTo(mainTextField.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView).inset(32)
            self.subTextFieldHeightConstraint = $0.height.greaterThanOrEqualTo(subTextFieldMinHeight).constraint
        }
        
        consumButton.snp.makeConstraints {
            $0.top.equalTo(subTextField.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(44)
        }
        
        consumStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        bodyLine.snp.makeConstraints {
            $0.top.equalTo(consumButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(16)
            $0.height.equalTo(1)
        }
        
        galleryLabel.snp.makeConstraints {
            $0.top.equalTo(bodyLine.snp.bottom).offset(20)
            $0.leading.equalTo(contentView).inset(32)
        }
        
        galleryCollectionView.snp.makeConstraints {
            $0.top.equalTo(galleryLabel.snp.bottom)
            $0.leading.trailing.equalTo(contentView)
            $0.height.equalTo(100)
        }
        
        galleryCountButton.snp.makeConstraints {
            $0.top.equalTo(galleryCollectionView.snp.bottom).offset(10)
            $0.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(44)
        }
        
        galleryCountStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        mateLabel.snp.makeConstraints {
            $0.top.equalTo(galleryCollectionView.snp.bottom).offset(63)
            $0.leading.equalTo(contentView).inset(32)
        }
        
        mateCollectionView.snp.makeConstraints {
            $0.top.equalTo(mateLabel.snp.bottom)
            $0.leading.trailing.equalTo(contentView)
            $0.height.equalTo(100)
        }
        
        mateCountButton.snp.makeConstraints {
            $0.top.equalTo(mateCollectionView.snp.bottom).offset(10)
            $0.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(44)
        }
        
        mateCountStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        
        //베이비그레이-커스텀블랙
        let babyGTocustomB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
        dateButton.configuration?.baseBackgroundColor = babyGTocustomB
        locationButton.backgroundColor = babyGTocustomB
        consumButton.backgroundColor = babyGTocustomB
        galleryCountButton.configuration?.baseBackgroundColor = babyGTocustomB
        mateCountButton.configuration?.baseBackgroundColor = babyGTocustomB
        
        //라이트그레이-다크그레이
        let lightGTodarkG = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "darkgray") : UIColor(named: "lightgray")
        mainTextField.textColor = lightGTodarkG
        mainTextField.layer.borderColor = lightGTodarkG?.cgColor
        subTextField.textColor = lightGTodarkG
        subTextField.layer.borderColor = lightGTodarkG?.cgColor
        
        //라이트그레이-라이트블랙
        let lightGTolightB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "lightgray")
        topLine.backgroundColor = lightGTolightB
        bodyLine.backgroundColor = lightGTolightB
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
        publicOpenButton.addTarget(self, action: #selector(publicOpenButtonTapped), for: .touchUpInside)
        
        dateButton.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
        
        galleryCountButton.addTarget(self, action: #selector(showPHPicker), for: .touchUpInside)
        
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        consumButton.addTarget(self, action: #selector(consumButtonTapped), for: .touchUpInside)
        
        mateCountButton.addTarget(self, action: #selector(showMatePicker), for: .touchUpInside)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func publicOpenButtonTapped() {
        let isHidden = publicView.isHidden
        let newHeight: CGFloat = isHidden ? 90 : 0
        
        self.publicView.isHidden = !isHidden
        self.publicViewHeightConstraint?.update(offset: newHeight)
        let imageName = newHeight == 0 ? "chevron.down" : "chevron.up"
        self.publicOpenButton.setImage(UIImage(systemName: imageName), for: .normal)
        self.view.layoutIfNeeded()
    }
    
    @objc func showMatePicker() {
        let mateVC = MateViewController()
        mateVC.delegate = self
        navigationController?.pushViewController(mateVC, animated: true)
    }
    
    @objc func locationButtonTapped() {
        Task {
            let center: CLLocationCoordinate2D
            if let savedLocation = savedLocation {
                center = savedLocation
            } else {
                // 기본 위치 설정 (광화문)
                center = CLLocationCoordinate2D(latitude: 37.5760222, longitude: 126.9769000)
            }
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            
            let mapVC = MapViewController(region: region, startDate: Date(), endDate: Date(), onLocationSelected: { [weak self] (selectedLocation: CLLocationCoordinate2D, address: String) in
                guard let self = self else { return }
                self.updateLocationLabel(with: address)
                self.savedLocation = selectedLocation
                self.savedAddress = address
                
            })
            
            // 저장된 위치가 있으면 해당 위치에 핀을 생성
            if let savedLocation = savedLocation, let savedAddress = savedAddress {
                mapVC.addPinToMap(location: savedLocation, address: savedAddress)
            }
            
            self.navigationController?.pushViewController(mapVC, animated: true)
        }
    }
    
    
    @objc func consumButtonTapped() {
        let spendVC = SpendingListViewController()
        
        spendVC.pinLog = pinLog
//        spendVC.shouldShowEditButton = true
        navigationController?.pushViewController(spendVC, animated: true)
    }
    
    @objc func showCalendar() {
        let calendarVC = CalendarHostingController()
        calendarVC.delegate = self
        calendarVC.modalPresentationStyle = .pageSheet
        if let sheet = calendarVC.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 460 })]
            sheet.prefersGrabberVisible = true
        }
        present(calendarVC, animated: true, completion: nil)
    }
    
    
    
    func setupNavigationBar() {
        let closeButton = ButtonFactory.createXButton(target: self, action: #selector(dismissDetailView))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func dismissDetailView(_ sender:UIButton) {
        dismiss(animated: true)
    }
    
    func updateLocationLabel(with address: String) {
        self.locationLeftLabel.text = address
    }
    
    func configureView(with pinLog: PinLog) {
        expenses = pinLog.expenses ?? [] // 저장된 지출 내역 로드
        spendingPublicSwitch.isOn = pinLog.isSpendingPublic
        locationLeftLabel.text = pinLog.location
        mainTextField.text = pinLog.title
        mainTextField.textColor = .font
        subTextField.text = pinLog.content
        subTextField.textColor = .font
        publicSwitch.isOn = pinLog.isPublic
        spendingPublicSwitch.isOn = pinLog.isSpendingPublic
        
        updateDateLabel(with: pinLog.startDate, endDate: pinLog.endDate)
        
        selectedImages.removeAll()
        imageLocations.removeAll()
        
        let dispatchGroup = DispatchGroup()
        
        for media in pinLog.media {
            dispatchGroup.enter()
            if let url = URL(string: media.url) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        let location = media.latitude != nil && media.longitude != nil ? CLLocationCoordinate2D(latitude: media.latitude!, longitude: media.longitude!) : nil
                        self.selectedImages.append((image, media.isRepresentative, location))
                    } else {
                        print("Error loading image: \(String(describing: error))")
                    }
                    dispatchGroup.leave()
                }.resume()
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.representativeImageIndex = self.selectedImages.firstIndex { $0.1 }
            self.updateRepresentativeImage()
            self.galleryCollectionView.reloadData()
            self.updateGalleryCountButton()
        }
        
        loadSelectedFriends(pinLog: pinLog)
        
        // totalSpendingAmount 값을 consumLeftLabel에 설정
        if let totalSpendingAmount = pinLog.totalSpendingAmount, totalSpendingAmount > 0 {
            consumLeftLabel.text = "\(formatCurrency(Int(totalSpendingAmount)))원"
        } else {
            consumLeftLabel.text = "지출 내역을 입력해주세요"
        }
        updateTotalSpendingAmount(with: expenses)
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
    
    private func saveImageWithLocation(image: UIImage, location: CLLocationCoordinate2D?, address: String, completion: @escaping (Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"]))
            return
        }
        
        let filename = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("images/\(filename)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { [weak self] metadata, error in
            if let error = error {
                completion(error)
                return
            }
            
            storageRef.downloadURL { [weak self] url, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let downloadURL = url else {
                    completion(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"]))
                    return
                }
                
                guard let self = self else {
                    completion(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))
                    return
                }
                
                let mediaItem = Media(
                    url: downloadURL.absoluteString,
                    latitude: location?.latitude,
                    longitude: location?.longitude,
                    dateTaken: Date(),
                    isRepresentative: false
                )
                
                self.saveMediaItemToFirestore(mediaItem: mediaItem, address: address, completion: completion)
            }
        }
    }
    
    private func saveMediaItemToFirestore(mediaItem: Media, address: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("images").addDocument(data: [
            "url": mediaItem.url,
            "latitude": mediaItem.latitude ?? 0,
            "longitude": mediaItem.longitude ?? 0,
            "timestamp": Timestamp(date: mediaItem.dateTaken ?? Date())
        ]) { error in
            completion(error)
        }
    }
    
    private func showProgressView() {
        let progressVC = ProgressViewController()
        addChild(progressVC)
        view.addSubview(progressVC.view)
        progressVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        progressVC.didMove(toParent: self)
        progressViewController = progressVC
    }

    private func hideProgressView() {
        if let progressVC = progressViewController {
            progressVC.willMove(toParent: nil)
            progressVC.view.removeFromSuperview()
            progressVC.removeFromParent()
            progressViewController = nil
        }
    }
    
    @objc func doneButtonTapped() {
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        guard let locationTitle = locationLeftLabel.text, locationTitle != "지역을 선택하세요" else {
            let alert = UIAlertController(title: "지역 선택", message: "지역을 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let mainTitle = mainTextField.text, !mainTitle.isEmpty, mainTextField.textColor != .lightgray else {
            let alert = UIAlertController(title: "제목 입력", message: "여행 제목을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard !selectedImages.isEmpty else {
            let alert = UIAlertController(title: "앨범 추가", message: "최소한 하나의 이미지를 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let dateRange = dateLabel.text, dateRange != "날짜를 선택하세요" else {
            let alert = UIAlertController(title: "날짜 선택", message: "유효한 날짜를 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dates = dateRange.split(separator: " ~ ")
        guard dates.count == 2,
              let startDate = dateFormatter.date(from: String(dates[0])),
              let endDate = dateFormatter.date(from: String(dates[1])) else {
            let alert = UIAlertController(title: "오류", message: "유효한 날짜를 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let title = mainTextField.text ?? ""
        let content = subTextField.text ?? ""
        let isPublic = publicSwitch.isOn
        let isSpendingPublic = spendingPublicSwitch.isOn
        let address = savedAddress ?? "Unknown Address"
        let latitude = savedLocation?.latitude ?? 0.0
        let longitude = savedLocation?.longitude ?? 0.0
        let totalSpendingAmount = calculateTotalSpendingAmount()
        let maxSpendingAmount = calculateMaxSpendingAmount()
        
        let imageLocations = selectedImages.compactMap { $0.2 }
        
        showProgressView()
        
        Task {
            do {
                var pinLog: PinLog
                
                if let existingPinLog = self.pinLog {
                    pinLog = existingPinLog
                    pinLog.location = locationTitle
                    pinLog.address = address
                    pinLog.latitude = latitude
                    pinLog.longitude = longitude
                    pinLog.startDate = startDate
                    pinLog.endDate = endDate
                    pinLog.title = title
                    pinLog.content = content
                    pinLog.isPublic = isPublic
                    pinLog.isSpendingPublic = isSpendingPublic
                    pinLog.attendeeIds = selectedFriends.map { $0.uid }
                    pinLog.totalSpendingAmount = totalSpendingAmount
                    pinLog.maxSpendingAmount = maxSpendingAmount
                    pinLog.expenses = expenses
                } else {
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
                                    attendeeIds: selectedFriends.map { $0.uid },
                                    isPublic: isPublic,
                                    createdAt: Date(),
                                    pinCount: 0,
                                    pinnedBy: [],
                                    totalSpendingAmount: totalSpendingAmount,
                                    isSpendingPublic: isSpendingPublic,
                                    maxSpendingAmount: maxSpendingAmount,
                                    expenses: expenses)
                    
                }
                
                // 선택된 대표 이미지가 있으면 설정
                if let representativeIndex = selectedImages.firstIndex(where: { $0.1 }) {
                    for i in 0..<selectedImages.count {
                        selectedImages[i].1 = (i == representativeIndex)
                    }
                } else if !selectedImages.isEmpty {
                    selectedImages[0].1 = true
                }
                
                let isRepresentativeFlags = selectedImages.map { $0.1 }
                
                let savedPinLog = try await pinLogManager.createOrUpdatePinLog(pinLog: &pinLog, images: selectedImages.map { $0.0 }, imageLocations: imageLocations, isRepresentativeFlags: isRepresentativeFlags)
                self.savedPinLogId = savedPinLog.id
                self.pinLog = savedPinLog
                delegate?.didSavePinLog(savedPinLog)

                if let navigationController = self.navigationController {
                    for viewController in navigationController.viewControllers {
                        if viewController is MyTripsViewController {
                            navigationController.popToViewController(viewController, animated: true)
                            return
                        }
                    }
                    navigationController.popToRootViewController(animated: true)
                }
            } catch {
                let alert = UIAlertController(title: "오류", message: "데이터 저장에 실패했습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                present(alert, animated: true, completion: nil)
            }
            hideProgressView()
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func calculateTotalSpendingAmount() -> Int {
        return expenses.flatMap { $0.expenses }.reduce(0) { $0 + $1.expenseAmount }
    }
    
    func calculateMaxSpendingAmount() -> Int {
        return expenses.flatMap { $0.expenses }.map { $0.expenseAmount }.max() ?? 0
    }
    
    func loadSelectedFriends(pinLog: PinLog) {
        let group = DispatchGroup()
        selectedFriends.removeAll()
        
        for userId in pinLog.attendeeIds {
            group.enter()
            fetchUserSummary(userId: userId) { [weak self] userSummary in
                guard let self = self else {
                    group.leave()
                    return
                }
                if var userSummary = userSummary {
                    userSummary.isMate = true
                    self.selectedFriends.append(userSummary)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.mateCollectionView.reloadData()
            self.updateMateCountButton()
        }
    }
    
    func fetchUserSummary(userId: String, completion: @escaping (UserSummary?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                let userSummary = UserSummary(
                    uid: userId,
                    email: data["email"] as? String ?? "",
                    displayName: data["displayName"] as? String ?? "",
                    photoURL: data["photoURL"] as? String,
                    isMate: false
                )
                completion(userSummary)
            } else {
                completion(nil)
            }
        }
    }
    
    func updateGalleryCountButton() {
        let count = selectedImages.count
        galleryCountLabel.text = "\(count)/10"
        galleryCountButton.isHidden = count == 0
    }
    
    func updateMateCountButton() {
        let count = selectedFriends.count
        mateCountLabel.text = "\(count)"
        mateCountButton.isHidden = count == 0
    }
    
    func createCollectionViewFlowLayout(for collectionView: UICollectionView) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 85, height: 85)
        return layout
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
    
    private func fetchAddress(for location: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            if let error = error {
                print("Error fetching address: \(error.localizedDescription)")
                completion("No Address")
                return
            }
            if let placemark = placemarks?.first {
                let address = [
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
                completion(address)
            } else {
                completion("No Address")
            }
        }
    }
    
    @objc func deletePhoto(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? GallaryInPutCollectionViewCell,
              let indexPath = galleryCollectionView.indexPath(for: cell) else { return }
        
        selectedImages.remove(at: indexPath.row)
        if selectedImages.isEmpty {
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
    
    func updateRepresentativeImage() {
        if let index = representativeImageIndex, index < selectedImages.count {
            for i in 0..<selectedImages.count {
                selectedImages[i].1 = (i == index)
            }
        } else {
            representativeImageIndex = selectedImages.isEmpty ? nil : 0
        }
        galleryCollectionView.reloadData()
    }
    
    func updateTotalSpendingAmount(with dailyExpenses: [DailyExpenses]) {
        let totalAmount = dailyExpenses.flatMap { $0.expenses }.reduce(0) { $0 + $1.expenseAmount }
        consumLeftLabel.text = "\(formatCurrency(totalAmount))원"
    }
    
    func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}


extension DetailInputViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == galleryCollectionView {
            return selectedImages.isEmpty ? 1 : selectedImages.count
        } else if collectionView == mateCollectionView {
            return selectedFriends.isEmpty ? 1 : selectedFriends.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == galleryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GallaryInPutCollectionViewCell.identifier, for: indexPath) as? GallaryInPutCollectionViewCell else {
                fatalError("컬렉션 뷰 오류")
            }
            if selectedImages.isEmpty {
                cell.configure(with: nil, isRepresentative: false)
            } else {
                let (image, isRepresentative, _) = selectedImages[indexPath.row]
                cell.configure(with: image, isRepresentative: isRepresentative)
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendInputCollectionViewCell.identifier, for: indexPath) as? FriendInputCollectionViewCell else {
                fatalError("컬렉션 뷰 오류")
            }
            if selectedFriends.isEmpty {
                cell.configure(with: nil)
            } else {
                let friend = selectedFriends[indexPath.row]
                if let photoURL = friend.photoURL, let url = URL(string: photoURL) {
                    cell.configure(with: url)
                } else {
                    cell.configure(with: nil)
                }
            }
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == galleryCollectionView {
            if selectedImages.isEmpty || indexPath.row == selectedImages.count {
                showPHPicker()
            } else {
                representativeImageIndex = indexPath.row
                updateRepresentativeImage()
            }
        } else if collectionView == mateCollectionView {
            if selectedFriends.isEmpty {
                let mateVC = MateViewController()
                mateVC.delegate = self
                navigationController?.pushViewController(mateVC, animated: true)
            }
        }
    }
}

extension DetailInputViewController: MateViewControllerDelegate {
    func didSelectMates(_ mates: [UserSummary]) {
        selectedFriends = mates
        mateCollectionView.reloadData()
        updateMateCountButton()
    }
}

extension DetailInputViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else {
            print("No result found.")
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            let provider = result.itemProvider
            if provider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    guard let self = self else {
                        dispatchGroup.leave()
                        return
                    }
                    
                    if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let uiImage = object as? UIImage else {
                        print("Image is nil or not UIImage.")
                        dispatchGroup.leave()
                        return
                    }
                    
                    provider.loadDataRepresentation(forTypeIdentifier: "public.jpeg") { data, error in
                        if let error = error {
                            print("Error loading data representation: \(error.localizedDescription)")
                            dispatchGroup.leave()
                            return
                        }
                        guard let data = data else {
                            print("No data found.")
                            dispatchGroup.leave()
                            return
                        }
                        
                        let location = StorageManager.shared.extractLocation(from: data)
                        self.selectedImages.append((uiImage, false, location))
                        
                        dispatchGroup.leave()
                    }
                }
            } else {
                print("No provider or provider cannot load UIImage.")
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.galleryCollectionView.reloadData()
            self.updateGalleryCountButton()
        }
    }
}

extension DetailInputViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightgray {
            textView.text = nil
            textView.textColor = .font
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == mainTextField {
                textView.text = "여행 제목을 입력해주세요."
            } else if textView == subTextField {
                textView.text = "기록을 담아 주세요."
            }
            textView.textColor = .lightgray
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 첫 번째 텍스트 필드에서 던 버튼을 누르면 두 번째 텍스트 필드로 포커스를 이동
        if textView == mainTextField && text == "\n" {
            subTextField.becomeFirstResponder()
            return false
        }
        
        // 두 번째 텍스트 필드에서는 리턴 키가 줄바꿈이 되도록 허용
        if textView == subTextField && text == "\n" {
            return true
        }
        
        return true
    }
}


