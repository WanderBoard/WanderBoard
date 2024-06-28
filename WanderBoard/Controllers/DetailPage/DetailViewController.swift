
//
//  ViewController.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 5/28/24.
//

import UIKit
import MapKit
import PhotosUI
import SnapKit
import Then
import Alamofire
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import Contacts
import CoreLocation
import ImageIO
import SwiftUI


class DetailViewController: UIViewController {
    
    weak var delegate: DetailViewControllerDelegate?
    
    var selectedImages: [(UIImage, Bool, CLLocationCoordinate2D?)] = []
    var selectedFriends: [UIImage] = []
    
    //로직 변경하면서 핀로그 id만 가져오도록
    var pinLogId: String?
    var pinLog: PinLog?
    let pinLogManager = PinLogManager()
    
    var representativeImage: UIImage?
    var pinLogTitle: String?
    var pinLogContent: String?
    
    var isExpanded = false
    
    var mapViewController: MapViewController?
    
    let subTextFieldMinHeight: CGFloat = 90
    var subTextFieldHeightConstraint: Constraint?
    
    lazy var pinButton = UIButton().then {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
        let symbolImage = UIImage(systemName: "pin.circle", withConfiguration: symbolConfiguration)
        $0.setImage(symbolImage, for: .normal)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.tintColor = .font
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(pinButtonTapped), for: .touchUpInside)
    }
    
    lazy var mapAllButton = UIButton().then {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
        let symbolImage = UIImage(systemName: "map.circle.fill", withConfiguration: symbolConfiguration)
        $0.setImage(symbolImage, for: .normal)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.tintColor = .font
        $0.isHidden = false
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var detailViewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.isPagingEnabled = true
        $0.isScrollEnabled = false
        $0.delegate = self
        $0.dataSource = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier)
        $0.register(TextCollectionViewCell.self, forCellWithReuseIdentifier: TextCollectionViewCell.identifier)
        $0.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.identifier)
    }
    
    let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
    }
    
    lazy var detailViewButton = UIHostingController(rootView: DetailPageControlButton(onIndexChanged: { [weak self] index in
        self?.switchToPage(index)
    }))
    
    var profileImageView = UIImageView().then {
        $0.backgroundColor = .white
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.backgroundColor = UIColor.darkgray
        $0.image = UIImage(systemName: "person")
        $0.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
    }
    
    var nicknameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .font
    }
    
    let profileStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 10
        $0.isUserInteractionEnabled = false
    }
    
    let optionsButton = UIButton().then {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = .font
        $0.showsMenuAsPrimaryAction = true
    }
    
    let profileOptionStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .fill
    }
    
    var locationLabel = UILabel().then {
        $0.text = "---"
        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        $0.textColor = .font
        $0.numberOfLines = 2
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }
    
    var dateDaysLabel = UILabel().then {
        $0.text = "0 Days"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .font
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    var dateStartLabel = UILabel().then {
        $0.text = "2024.08.13"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .font
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    let dateLineLabel = UILabel().then {
        $0.text = "-"
        $0.textColor = .font
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    var dateEndLabel = UILabel().then {
        $0.text = "2024.08.15"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .font
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    let dateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.spacing = 5
        $0.distribution = .fillProportionally
    }
    
    let expandableView = UIView().then {
        $0.backgroundColor = .babyGTocustomB
        $0.isHidden = false
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    lazy var expandableButton = UIButton().then {
        $0.setImage(UIImage(systemName: "person.fill"), for: .normal)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.tintColor = .darkgray
        $0.addTarget(self, action: #selector(expandableButtonTapped), for: .touchUpInside)
    }
    
    let bottomContentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 20
    }
    
    let bottomContentView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    lazy var friendCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 60, height: 60)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        newSetupConstraints()
        setupConstraints()
        setupCollectionView()
        setupActionButton()
        updateColor()
        
        checkId()
        loadData()
        
        view.backgroundColor = .systemBackground
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
            profileImageView.isUserInteractionEnabled = true
            profileImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
        
        
    }

    func setupUI() {
        view.addSubview(detailViewCollectionView)
        view.addSubview(detailViewButton.view)
        addChild(detailViewButton)
        detailViewButton.didMove(toParent: self)
        
        view.addSubview(bottomContentView)
        bottomContentView.addSubview(bottomContentStackView)
        bottomContentView.addSubview(optionsButton)
        bottomContentView.addSubview(dateDaysLabel)
        bottomContentView.addSubview(dateStackView)
        
        view.addSubview(expandableView)
        expandableView.addSubview(expandableButton)
        expandableView.addSubview(friendCollectionView)
        
        profileStackView.addArrangedSubview(profileImageView)
        profileStackView.addArrangedSubview(nicknameLabel)
    
        bottomContentStackView.addArrangedSubview(profileStackView)
        bottomContentStackView.addArrangedSubview(locationLabel)
        
        dateStackView.addArrangedSubview(dateStartLabel)
        dateStackView.addArrangedSubview(dateLineLabel)
        dateStackView.addArrangedSubview(dateEndLabel)
    }
    
    func setupConstraints() {
        let screenHeight = UIScreen.main.bounds.height
        let collectionViewHeightMultiplier: CGFloat = screenHeight < 750 ? 0.58 : 0.52
        
        detailViewCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(collectionViewHeightMultiplier)
        }
        
        detailViewButton.view.snp.makeConstraints {
            $0.top.equalTo(detailViewCollectionView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(bottomContentView.snp.top)
        }
        
        bottomContentView.snp.makeConstraints {
            $0.top.equalTo(detailViewButton.view.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(26)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            $0.height.equalTo(100)
        }
       
        
        bottomContentStackView.snp.makeConstraints {
           // $0.top.equalTo(optionsButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        dateDaysLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(bottomContentStackView.snp.bottom).offset(10)
            $0.width.equalTo(55)
        }
        
        dateStackView.snp.makeConstraints {
            $0.leading.equalTo(dateDaysLabel.snp.trailing).offset(10)
            $0.top.equalTo(bottomContentStackView.snp.bottom).offset(10)
        }
        
        optionsButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        expandableView.snp.makeConstraints {
            $0.top.equalTo(optionsButton.snp.bottom).offset(10)
            $0.centerY.equalTo(dateStackView.snp.centerY).offset(-20)
            $0.trailing.equalToSuperview().offset(15)
            $0.width.equalTo(50)
            $0.height.equalTo(90)
        }
        
        expandableButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalToSuperview()
        }
        
        friendCollectionView.snp.makeConstraints {
            $0.leading.equalTo(expandableButton.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.top.bottom.equalToSuperview()
        }
    }
    
    func switchToPage(_ index: Int) {
        detailViewCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        //다크그레이-라이트그레이
        let darkBTolightG = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightgray") : UIColor(named: "darkgray")
        profileImageView.backgroundColor = darkBTolightG
        mapAllButton.setTitleColor(darkBTolightG, for: .normal)
    }
    
    //id로 데이터 불러오기 - 한빛
    func loadData() {
        guard let pinLogId = pinLogId else { return }
        pinLogManager.fetchPinLog(by: pinLogId) { [weak self] result in
            switch result {
            case .success(let pinLog):
                self?.pinLog = pinLog
                self?.checkId() // 데이터 로드 후 UI 업데이트
            case .failure(let error):
                print("Failed to fetch pin log: \(error)")
            }
        }
    }
    
    //MARK: - 다른 사람 글 볼 때 구현 추가 - 한빛
    // 핀 버튼
    private func newSetupConstraints() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissDetailView))
        
        let pinButtonItem = UIBarButtonItem(customView: pinButton)
        let mapAllButtonItem = UIBarButtonItem(customView: mapAllButton)
        
        navigationItem.rightBarButtonItems = [mapAllButtonItem, pinButtonItem]
        
        NSLayoutConstraint.activate([
            pinButton.widthAnchor.constraint(equalToConstant: 44),
            pinButton.heightAnchor.constraint(equalToConstant: 44),
            mapAllButton.widthAnchor.constraint(equalToConstant: 44),
            mapAllButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func dismissDetailView(_ sender:UIButton) {
        dismiss(animated: true)
    }
    
    func checkId() {
        if let pinLog = pinLog {
            if isCurrentUser(pinLog: pinLog) {
                Task {
                    await configureView(with: pinLog)
                }
                updatePinButtonState()
                profileStackView.isHidden = true
            } else {
                hideAppearUIElements()
                Task {
                    await configureView(with: pinLog)
                }
                updatePinButtonState()
                profileStackView.isHidden = false
            }
            setupMenu()
        }
    }
    
    // 현재 사용자가 작성자인지 확인
    func isCurrentUser(pinLog: PinLog) -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        return userId == pinLog.authorId
    }
    
    // 사용자가 아닌 경우 숨길 UI 요소를 정의
    func hideAppearUIElements() {
        pinButton.isHidden = false
        updatePinButtonState()
    }
    
    @objc func pinButtonTapped() {
        guard let pinLog = pinLog, let currentUserId = Auth.auth().currentUser?.uid else {
            showLoginAlert()
            return
        }
        
        var updatedPinnedBy = pinLog.pinnedBy ?? []
        var updatedPinCount = pinLog.pinCount ?? 0
        
        if let index = updatedPinnedBy.firstIndex(of: currentUserId) {
            updatedPinnedBy.remove(at: index)
            updatedPinCount -= 1
        } else {
            updatedPinnedBy.append(currentUserId)
            updatedPinCount += 1
        }
        
        // Firestore에 업데이트
        guard let pinLogId = pinLog.id else { return }
        let pinLogRef = Firestore.firestore().collection("pinLogs").document(pinLogId)
        pinLogRef.updateData([
            "pinnedBy": updatedPinnedBy,
            "pinCount": updatedPinCount
        ]) { error in
            if let error = error {
                print("Error updating pin log: \(error)")
            } else {
                self.pinLog?.pinnedBy = updatedPinnedBy
                self.pinLog?.pinCount = updatedPinCount
                self.updatePinButtonState()
                if let updatedPinLog = self.pinLog {
                    print("Delegate called with updated pin log")
                    self.delegate?.didUpdatePinButton(updatedPinLog)
                }
            }
        }
    }
    
    func showLoginAlert() {
        let alert = UIAlertController(title: "로그인", message: "로그인 시 이용 가능한 기능입니다.\n로그인 하시겠습니까?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
        
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.navigateToLogin()
        })
        confirmAction.setValue(UIColor.black, forKey: "titleTextColor")
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func navigateToLogin() {
        let loginVC = AuthenticationVC()
        loginVC.modalPresentationStyle = .automatic
        present(loginVC, animated: true, completion: nil)
    }
    
    //여기에서 업데이트 해줄 때 기본 설정을 못 가져와서 생겼던 문제였던 거 같습니다 ~~
    func updatePinButtonState() {
        guard let pinLog = pinLog, let currentUserId = Auth.auth().currentUser?.uid else { return }

        let pinnedBy = pinLog.pinnedBy ?? []

        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
        let symbolImage = pinnedBy.contains(currentUserId) ? UIImage(systemName: "pin.circle.fill", withConfiguration: symbolConfiguration) : UIImage(systemName: "pin.circle", withConfiguration: symbolConfiguration)
        
        pinButton.setImage(symbolImage, for: .normal)
    }
    
    func configureView(with pinLog: PinLog) async {
        locationLabel.text = pinLog.location
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        dateStartLabel.text = dateFormatter.string(from: pinLog.startDate)
        if pinLog.startDate == pinLog.endDate {
            dateEndLabel.text = ""
            dateLineLabel.isHidden = true
        } else {
            dateEndLabel.text = dateFormatter.string(from: pinLog.endDate)
            dateLineLabel.isHidden = false
        }
        
        let duration = Calendar.current.dateComponents([.day], from: pinLog.startDate, to: pinLog.endDate).day ?? 0
        dateDaysLabel.text = "\(duration + 1) Days"
        
        selectedImages.removeAll()
        updateSelectedImages(with: pinLog.media)
        
        if let firstMedia = pinLog.media.first, let latitude = firstMedia.latitude, let longitude = firstMedia.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            mapViewController?.mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)), animated: true)
        }
        
        for media in pinLog.media {
            if let latitude = media.latitude, let longitude = media.longitude {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                mapViewController?.addPinToMap(location: coordinate, address: "")
            }
        }
        
        // GalleryCollectionViewCell에 selectedImages를 전달
        if let galleryCell = detailViewCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? GalleryCollectionViewCell {
            galleryCell.selectedImages = selectedImages
        }
        
        updateSelectedFriends(with: pinLog.attendeeIds)
        
        // 닉네임 설정
        FirestoreManager.shared.fetchUserDisplayName(userId: pinLog.authorId) { [weak self] displayName in
            DispatchQueue.main.async {
                self?.nicknameLabel.text = displayName ?? "No Name"
            }
        }
        
        // 프로필 사진
        if let photoURL = try? await FirestoreManager.shared.fetchUserProfileImageURL(userId: pinLog.authorId), let url = URL(string: photoURL) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.backgroundColor = .black
        }
        friendCollectionView.isHidden = pinLog.attendeeIds.isEmpty
        
        // 대표 이미지와 텍스트 추출
        pinLogTitle = pinLog.title
        pinLogContent = pinLog.content
        
        if let representativeMedia = pinLog.media.first(where: { $0.isRepresentative }) {
            loadImage(from: representativeMedia.url) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.representativeImage = image
                    self.detailViewCollectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
                }
            }
        } else {
            self.detailViewCollectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
        }
        self.expandableButtonAction()
    }
    
    //프로필 이미지
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        AF.request(url).response { response in
            if let data = response.data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    func updateSelectedFriends(with attendeeIds: [String]) {
        selectedFriends.removeAll()
        
        let group = DispatchGroup()
        
        for userId in attendeeIds {
            group.enter()
            fetchUserImage(userId: userId) { [weak self] image in
                guard let self = self else {
                    group.leave()
                    return
                }
                if let image = image {
                    self.selectedFriends.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.friendCollectionView.reloadData()
            self.expandableButtonAction()
        }
    }
    
    @objc func imageViewTapped() {
        let nickname = nicknameLabel.text ?? ""
        let detailVC = profileDetail()
        detailVC.configureUI(with: nickname)
        present(detailVC, animated: true, completion: nil)
    }
    
    func fetchUserImage(userId: String, completion: @escaping (UIImage?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists, let data = document.data(),
               let photoURL = data["photoURL"] as? String, let url = URL(string: photoURL) {
                AF.request(url).response { response in
                    if let data = response.data, let image = UIImage(data: data) {
                        completion(image)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
    
    @objc func expandableButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        isExpanded.toggle()
        
        if isExpanded {
            UIView.animate(withDuration: 0.6) {
                self.expandableView.snp.updateConstraints {
                    $0.width.equalTo(self.view.frame.width * 1.0)
                    $0.trailing.equalToSuperview().offset(15)
                }
                self.expandableButton.snp.updateConstraints {
                    $0.width.equalTo(30)
                }
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.expandableView.snp.updateConstraints {
                    $0.width.equalTo(50)
                    $0.trailing.equalToSuperview().offset(15)
                }
                self.expandableButton.snp.updateConstraints {
                    $0.width.equalTo(50)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func setupActionButton() {
        mapAllButton.addTarget(self, action: #selector(showToMapButtonTapped), for: .touchUpInside)
    }
    
    func fetchImagesFromFirestore(completion: @escaping ([Media]) -> Void) {
        let db = Firestore.firestore()
        db.collection("images").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                completion([])
            } else {
                var mediaItems: [Media] = []
                for document in snapshot!.documents {
                    let data = document.data()
                    if let url = data["url"] as? String,
                       let latitude = data["latitude"] as? CLLocationDegrees,
                       let longitude = data["longitude"] as? CLLocationDegrees,
                       let isRepresentative = data["isRepresentative"] as? Bool {
                        let mediaItem = Media(url: url, latitude: latitude, longitude: longitude, dateTaken: nil, isRepresentative: isRepresentative)
                        mediaItems.append(mediaItem)
                    }
                }
                completion(mediaItems)
            }
        }
    }
    
    func setupMenu() {
        guard let pinLog = pinLog else { return }
        if Auth.auth().currentUser == nil {
            optionsButton.menu = nil
            optionsButton.isHidden = true
        }
        
        if isCurrentUser(pinLog: pinLog) {
            let instaAction = UIAction(title: "이미지 공유하기", image: UIImage(systemName: "photo.on.rectangle.angled")) { [weak self] _ in
                self?.instaConnect()
            }
            
            let editAction = UIAction(title: "수정하기", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.editPinLog()
            }
            
            let deleteAction = UIAction(
                title: "삭제하기",
                image: UIImage(systemName: "trash"),
                attributes: .destructive) { [weak self] _ in
                    self?.deletePinLog()
                }
            optionsButton.menu = UIMenu(title: "", children: [instaAction, editAction, deleteAction])
        } else if Auth.auth().currentUser != nil {
            let blockAction = UIAction(title: "작성자 차단하기", image: UIImage(systemName: "person.slash.fill")) { [weak self] _ in
                let reportAlert = UIAlertController(title: "", message: "작성자를 차단하시겠습니까? \n 차단한 작성자의 글이 보이지 않게됩니다.", preferredStyle: .alert)
                reportAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                reportAlert.addAction(UIAlertAction(title: "차단", style: .destructive, handler: { [weak self] _ in
                    self?.reportPinLog()
                }))
                self?.present(reportAlert, animated: true, completion: nil)
            }
            
            let hideAction = UIAction(title: "게시글 숨기기", image: UIImage(systemName: "eye.slash.circle")) { [weak self] _ in
                let hideAlert = UIAlertController(title: "", message: "게시글을 숨기시겠습니까? \n 숨긴 게시글은 다시 볼 수 없습니다.", preferredStyle: .alert)
                hideAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                hideAlert.addAction(UIAlertAction(title: "숨기기", style: .destructive, handler: { [weak self] _ in
                    self?.hidePinLog()
                }))
                self?.present(hideAlert, animated: true, completion: nil)
            }
            
            let reportAction = UIAction(title: "신고하기", image: UIImage(systemName: "exclamationmark.triangle"), attributes: .destructive) { [weak self] _ in
                let reportAlert = UIAlertController(title: "", message: "작성자를 신고하시겠습니까?", preferredStyle: .alert)
                reportAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                reportAlert.addAction(UIAlertAction(title: "신고", style: .destructive, handler: { [weak self] _ in
                    self?.reportPinLog()
                }))
                self?.present(reportAlert, animated: true, completion: nil)
            }
            optionsButton.menu = UIMenu(title: "", children: [blockAction, hideAction, reportAction])
        }
    }
    
    func deletePinLog() {
        let alert = UIAlertController(title: "삭제 확인", message: "핀로그를 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
            guard let self = self, let pinLog = self.pinLog else { return }
            Task {
                do {
                    try await self.pinLogManager.deletePinLog(pinLogId: pinLog.id!)
                    self.delegate?.didUpdatePinLog()
                    self.dismiss(animated: true, completion: nil)
                } catch {
                    print("Failed to delete pin log: \(error.localizedDescription)")
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func instaConnect() {
        guard !selectedImages.isEmpty else {
            return
        }
        
        let imagesToShare = selectedImages.map { $0.0 }
        let tempDirectory = FileManager.default.temporaryDirectory
        var imageURLs: [URL] = []
        
        for (index, image) in imagesToShare.enumerated() {
            let imageData = image.jpegData(compressionQuality: 1.0)
            let imageURL = tempDirectory.appendingPathComponent("image\(index).jpg")
            try? imageData?.write(to: imageURL)
            imageURLs.append(imageURL)
        }
        
        let activityViewController = UIActivityViewController(activityItems: imageURLs, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .saveToCameraRoll,
            .print
        ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func editPinLog() {
        let inputVC = DetailInputViewController()
        inputVC.delegate = self
        if let pinLog = self.pinLog {
            inputVC.pinLog = pinLog
        }
        let navController = UINavigationController(rootViewController: inputVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    func reportPinLog() {
        guard let authorId = pinLog?.authorId else { return }
        Task {
            do {
                try await AuthenticationManager.shared.blockAuthor(authorId: authorId)
                delegate?.didBlockAuthor(authorId)
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("Failed to block author: \(error)")
            }
        }
    }
    
    func hidePinLog() {
        guard let pinLogId = pinLog?.id else { return }
        Task {
            do {
                try await AuthenticationManager.shared.hidePinLog(pinLogId: pinLogId)
                delegate?.didHidePinLog(pinLogId)
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("Failed to hide pin log: \(error)")
            }
        }
    }
    
    func updateSelectedImages(with mediaItems: [Media]) {
        selectedImages.removeAll()
        
        let group = DispatchGroup()
        
        for media in mediaItems {
            guard URL(string: media.url) != nil else { continue }
            group.enter()
            loadImage(from: media.url) { [weak self] image in
                guard let self = self else {
                    group.leave()
                    return
                }
                if let image = image {
                    let location: CLLocationCoordinate2D? = (media.latitude != nil && media.longitude != nil) ? CLLocationCoordinate2D(latitude: media.latitude!, longitude: media.longitude!) : nil
                    if !self.selectedImages.contains(where: { $0.0 == image && $0.1 == media.isRepresentative && $0.2?.latitude == location?.latitude && $0.2?.longitude == location?.longitude }) {
                        self.selectedImages.append((image, media.isRepresentative, location))
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let galleryCell = self.detailViewCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? GalleryCollectionViewCell {
                galleryCell.selectedImages = self.selectedImages
            }
        }
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        AF.request(url).response { response in
            if let data = response.data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
    
    // 이미지 정보 저장
    func saveImageLocationToFirestore(imageURL: String, location: CLLocationCoordinate2D) {
        let db = Firestore.firestore()
        db.collection("images").addDocument(data: [
            "url": imageURL,
            "latitude": location.latitude,
            "longitude": location.longitude,
            "isRepresentative": false,
            "timestamp": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("이미지 위치정보 저장 실패: \(error.localizedDescription)")
            } else {
                print("이미지 위치정보 저장 성공")
            }
        }
    }
    
    @objc private func showToMapButtonTapped() {
        guard let pinLog = pinLog else { return }
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        let galleryMapVC = GalleryMapViewController(region: region, onLocationSelected: { coordinate, address in
        }, pinLog: pinLog)
        
        galleryMapVC.pinLocations = pinLog.media
        
        let backButton = ButtonFactory.createBackButton()
        navigationItem.backBarButtonItem = backButton
        navigationController?.pushViewController(galleryMapVC, animated: true)
    }
    
    func setupCollectionView() {
        friendCollectionView.delegate = self
        friendCollectionView.dataSource = self
    
        friendCollectionView.register(FriendCollectionViewCell.self, forCellWithReuseIdentifier: FriendCollectionViewCell.identifier)
    }
    
    func expandableButtonAction() {
        if selectedFriends.isEmpty {
            expandableButton.setImage(UIImage(systemName: "person.slash.fill"), for: .normal)
            expandableButton.isUserInteractionEnabled = false
        } else {
            expandableButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
            expandableButton.isUserInteractionEnabled = true
        }
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == friendCollectionView {
            return selectedFriends.count
        } else if collectionView == detailViewCollectionView {
            return 3
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == detailViewCollectionView {
            switch indexPath.item {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.identifier, for: indexPath) as! GalleryCollectionViewCell
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCollectionViewCell.identifier, for: indexPath) as! TextCollectionViewCell
                cell.configure(with: representativeImage, title: pinLogTitle ?? "", content: pinLogContent ?? "")
                return cell
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as! CardCollectionViewCell
                return cell
            default:
                fatalError("Unexpected index path")
            }
        } else if collectionView == friendCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendCollectionViewCell.identifier, for: indexPath) as? FriendCollectionViewCell else {
                fatalError("컬렉션 뷰 오류")
            }
            cell.configure(with: selectedFriends[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    //카드컬렉션뷰 누르면 지출상세뷰로 넘어가도록
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        if indexPath.item == 2 {
            UIView.animate(withDuration: 0.05, animations: {
                cell.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }, completion: { _ in
                UIView.animate(withDuration: 0.05, animations: {
                    cell.transform = CGAffineTransform.identity
                }, completion: { _ in
                    
                    
                    let spendingListVC = SpendingListViewController()
                    let backButton = ButtonFactory.createBackButton()
                    self.navigationItem.backBarButtonItem = backButton
                    self.navigationController?.pushViewController(spendingListVC, animated: true)
                })
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == friendCollectionView {
            return CGSize(width: 60, height: 60)
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
}

protocol DetailViewControllerDelegate: AnyObject {
    func didUpdatePinLog()
    func didUpdatePinButton(_ updatedPinLog: PinLog)
    func didBlockAuthor(_ authorId: String)
    func didHidePinLog(_ hiddenPinLogId: String)
}

extension DetailViewController: DetailInputViewControllerDelegate {
    func didSavePinLog(_ pinLog: PinLog) {
        self.pinLog = pinLog
        Task {
            await configureView(with: pinLog)
        }
    }
}
