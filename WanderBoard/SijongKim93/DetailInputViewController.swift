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
import PhotosUI
import MapKit
import SwiftUI
import CoreLocation

protocol DetailInputViewControllerDelegate: AnyObject {
    func didSavePinLog(_ pinLog: PinLog)
}

class DetailInputViewController: UIViewController {
    
    private let locationManager = LocationManager()
    
    weak var delegate: DetailInputViewControllerDelegate?
    
    var selectedImages: [UIImage] = []
    var selectedFriends: [UIImage] = []
    let pinLogManager = PinLogManager()
    
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
        guard let indexPath = galleryCollectionView.indexPathForItem(at: point), !selectedImages.isEmpty else { return }

        if gesture.state == .began {
            isEditingPhotos = true
            startShakingCells()
        }
    }

    @objc func locationButtonTapped() {
        let viewModel = MapViewModel(region: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))

        viewModel.onLocationAuthorizationGranted = { [weak self] in
            guard let self = self else { return }
            let mapVC = MapViewController(viewModel: viewModel, startDate: Date(), endDate: Date()) { selectedLocation, locationTitle in
                self.locationLeftLabel.text = locationTitle
            }
            
            // 내비게이션 스택에 MapViewController가 없는 경우에만 푸시
            if !(self.navigationController?.viewControllers.contains(where: { $0 is MapViewController }) ?? false) {
                self.navigationController?.pushViewController(mapVC, animated: true)
            }

        }

        // 위치 권한 상태를 확인하고 적절한 동작 수행
        viewModel.checkLocationAuthorization()
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
            // Handle invalid location selection
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
        
        Task {
            do {
                let pinLog = try await pinLogManager.createPinLog(
                    location: locationTitle,
                    startDate: startDate,
                    endDate: endDate,
                    title: title,
                    content: content,
                    images: selectedImages,
                    authorId: Auth.auth().currentUser?.uid ?? "",
                    attendeeIds: [],
                    isPublic: isPublic
                )
                delegate?.didSavePinLog(pinLog)
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
    
    @objc func showPHPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10 - selectedImages.count
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
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
    }
}

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
