
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

class DetailViewController: UIViewController {
    var selectedImages: [(UIImage, Bool)] = []
    var selectedFriends: [UIImage] = []

    var pinLog: PinLog? {
        didSet {
            guard let pinLog = pinLog else { return }
            configureView(with: pinLog)
        }
    }
    
    let pinLogManager = PinLogManager()

    var mapViewController: MapViewController?

    let subTextFieldMinHeight: CGFloat = 90
    var subTextFieldHeightConstraint: Constraint?

    let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .black
        $0.isUserInteractionEnabled = true
    }

    let topContentView = UIView().then {
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = false
    }
    
    // 추가
    var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .white
        $0.image = UIImage(systemName: "person")
        $0.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
    }
    
    // 추가
    var nicknameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .white
    }

    // 추가
    let profileStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 10
    }
    
    var locationLabel = UILabel().then {
        $0.text = "---"
        $0.font = UIFont.systemFont(ofSize: 40)
        $0.textColor = .white
        $0.numberOfLines = 2
    }

    var dateDaysLabel = UILabel().then {
        $0.text = "0 Days"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .white
    }

    let locationStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 10
    }

    var dateStartLabel = UILabel().then {
        $0.text = "2024.08.13"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .white
    }

    let dateLineLabel = UILabel().then {
        $0.text = "-"
        $0.textColor = .white
    }

    var dateEndLabel = UILabel().then {
        $0.text = "2024.08.15"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .white
    }

    let dateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.spacing = 5
    }

    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.bounces = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 40
    }

    let contentView = UIView().then {
        $0.backgroundColor = .white
    }

    let optionsButton = UIButton().then {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = .black
        $0.showsMenuAsPrimaryAction = true
    }

    var mainTitleLabel = UILabel().then {
        $0.text = "부산에 다녀왔다"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    // 추가
    let subTextContainer = UIView().then {
        $0.backgroundColor = .clear
    }

    var subTextLabel = UILabel().then {
        $0.text = "여기에는 이전 인풋VC 텍스트필드에서 작성된 내용이 들어옵니다. 이 텍스트는 더미 텍스트입니다."
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    let textLabelLine = UILabel().then {
        $0.backgroundColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
    }

    let segmentControl: UISegmentedControl = {
        let items = ["Map", "Album"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0

        segment.backgroundColor = UIColor(white: 1, alpha: 0.5)
        segment.layer.cornerRadius = 16
        segment.layer.masksToBounds = true
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white, .backgroundColor: UIColor.black], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        segment.selectedSegmentTintColor = .black
        segment.layer.borderWidth = 0
        segment.isUserInteractionEnabled = true
        return segment
    }()

    let albumImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.isHidden = true
        $0.isUserInteractionEnabled = false
    }

    lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 85, height: 85)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        return collectionView
    }()

    let mapAllButton = UIButton().then {
        $0.setTitle("전체 지도 보기", for: .normal)
        $0.setTitleColor(#colorLiteral(red: 0.5913596153, green: 0.5913596153, blue: 0.5913596153, alpha: 1), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.backgroundColor = .white
        $0.isHidden = false
    }

    let albumAllButton = UIButton().then {
        $0.setTitle("전체 앨범 보기", for: .normal)
        $0.setTitleColor(#colorLiteral(red: 0.5913596153, green: 0.5913596153, blue: 0.5913596153, alpha: 1), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.backgroundColor = .white
        $0.isHidden = true
    }

    let moneyTitle = UILabel().then {
        $0.text = "지출"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }

    var moneyCountTitle = UILabel().then {
        $0.text = "0000000"
        $0.font = UIFont.systemFont(ofSize: 40)
        $0.textColor = .black
    }

    let moneyCountSubTitle = UILabel().then {
        $0.text = "₩"
        $0.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        $0.textColor = #colorLiteral(red: 0.5070941448, green: 0.5070941448, blue: 0.5070941448, alpha: 1)
    }

    var maxConsumptionLabel = UILabel().then {
        $0.text = "최고금액 지출 : GS25 부산해운대점"
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
    }

    let consumStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.alignment = .leading
    }

    let friendTitle = UILabel().then {
        $0.text = "메이트"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }

    lazy var friendCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 85, height: 85)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        return collectionView
    }()

    let bottomLogo = UIImageView().then {
        $0.image = UIImage(named: "logo")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupMapViewController()
        setupConstraints()
        setupCollectionView()
        setupSegmentControl()
        applyDarkOverlayToBackgroundImage()
        setupActionButton()

        view.backgroundColor = .white

        if let pinLog = pinLog {
            configureView(with: pinLog)
        } else {
            fetchAndConfigurePinLogs()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
    }

    // 핀로그 불러오기
    func fetchAndConfigurePinLogs() {
        Task {
            do {
                guard let userId = Auth.auth().currentUser?.uid else { return }
                let fetchedPinLogs = try await PinLogManager.shared.fetchPinLogs(forUserId: userId)

                if let firstPinLog = fetchedPinLogs.first {
                    self.pinLog = firstPinLog
                }
            } catch {
                ErrorUtility.shared.presentErrorAlert(with: "Error fetching pin log data")
            }
        }
    }

    func setupUI() {
        view.addSubview(backgroundImageView)
        backgroundImageView.addSubview(topContentView)
        topContentView.addSubview(profileStackView)
        topContentView.addSubview(locationStackView)
        topContentView.addSubview(dateStackView)
        
        profileStackView.addArrangedSubview(profileImageView)
        profileStackView.addArrangedSubview(nicknameLabel)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(optionsButton)
        contentView.addSubview(mainTitleLabel)
        contentView.addSubview(subTextContainer)
        subTextContainer.addSubview(subTextLabel)
        contentView.addSubview(textLabelLine)
        if let mapVC = mapViewController {
            contentView.addSubview(mapVC.view)
            mapVC.view.isHidden = false
        }
        contentView.addSubview(segmentControl)
        contentView.addSubview(galleryCollectionView)
        contentView.addSubview(albumImageView)
        contentView.addSubview(mapAllButton)
        contentView.addSubview(albumAllButton)
        contentView.addSubview(moneyCountSubTitle)
        contentView.addSubview(consumStackView)
        contentView.addSubview(friendTitle)
        contentView.addSubview(friendCollectionView)
        contentView.addSubview(bottomLogo)

        locationStackView.addArrangedSubview(locationLabel)
        locationStackView.addArrangedSubview(dateDaysLabel)

        dateStackView.addArrangedSubview(dateStartLabel)
        dateStackView.addArrangedSubview(dateLineLabel)
        dateStackView.addArrangedSubview(dateEndLabel)

        consumStackView.addArrangedSubview(moneyTitle)
        consumStackView.addArrangedSubview(moneyCountTitle)
        consumStackView.addArrangedSubview(maxConsumptionLabel)

        scrollView.delegate = self


    }

    func setupConstraints() {
        backgroundImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(515)
        }
        
        topContentView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        profileStackView.snp.makeConstraints {
            $0.bottom.equalTo(locationStackView.snp.top).offset(-16)
            $0.leading.trailing.equalTo(topContentView).inset(32)
        }
        
        locationStackView.snp.makeConstraints {
            $0.bottom.equalTo(scrollView.snp.top).offset(-32)
            $0.leading.trailing.equalTo(topContentView).inset(32)
        }
        
        dateStackView.snp.makeConstraints {
            $0.bottom.equalTo(locationStackView).inset(-1)
            $0.leading.equalTo(dateDaysLabel.snp.trailing).offset(10)
        }

        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(backgroundImageView.snp.bottom).offset(-20)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(40)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.bottom.equalTo(bottomLogo.snp.bottom).offset(30)
        }
        
        optionsButton.snp.makeConstraints {
            $0.top.equalTo(contentView).inset(24)
            $0.trailing.equalTo(contentView).inset(32)
            $0.width.height.equalTo(24)
        }
        
        mainTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(50)
            $0.leading.trailing.equalTo(contentView).inset(32)
        }
        
        subTextContainer.snp.makeConstraints {
            $0.top.equalTo(mainTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(150)
        }
        
        subTextLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(subTextContainer)
        }
        
        textLabelLine.snp.makeConstraints {
            $0.top.equalTo(subTextContainer.snp.bottom)
            $0.height.equalTo(1)
            $0.leading.trailing.equalTo(contentView).inset(32)
        }
        
        segmentControl.snp.makeConstraints {
            $0.top.equalTo(textLabelLine.snp.bottom).offset(48)
            $0.leading.equalTo(contentView).inset(32)
            $0.height.equalTo(30)
            $0.width.equalTo(123)
        }

        mapViewController?.view.snp.makeConstraints {
            $0.top.equalTo(segmentControl).offset(10)
            $0.leading.trailing.equalTo(contentView)
            $0.height.equalTo(300)
        }

        albumImageView.snp.makeConstraints {
            $0.top.equalTo(segmentControl).offset(-10)
            $0.leading.trailing.equalTo(contentView)
            $0.height.equalTo(300)
        }

        galleryCollectionView.snp.makeConstraints {
            $0.top.equalTo(mapViewController!.view.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView)
            $0.height.equalTo(90)
        }

        mapAllButton.snp.makeConstraints {
            $0.top.equalTo(galleryCollectionView.snp.bottom)
            $0.trailing.equalTo(contentView).inset(16)
        }
        
        albumAllButton.snp.makeConstraints {
            $0.top.equalTo(galleryCollectionView.snp.bottom)
            $0.trailing.equalTo(contentView).inset(16)
        }
        
        moneyTitle.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(32)
        }
        
        moneyCountSubTitle.snp.makeConstraints {
            $0.bottom.equalTo(moneyCountTitle).inset(3)
            $0.leading.equalTo(moneyCountTitle.snp.trailing).offset(10)
        }
        
        consumStackView.snp.makeConstraints {
            $0.top.equalTo(galleryCollectionView.snp.bottom).offset(48)
            $0.leading.trailing.equalTo(contentView).offset(16)
        }
        
        consumStackView.setCustomSpacing(8, after: moneyTitle)
        
        friendTitle.snp.makeConstraints {
            $0.top.equalTo(consumStackView.snp.bottom).offset(48)
            $0.leading.equalTo(contentView).offset(16)
        }
        
        friendCollectionView.snp.makeConstraints {
            $0.top.equalTo(friendTitle.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView)
            $0.height.equalTo(90)
        }
        
        bottomLogo.snp.makeConstraints {
            $0.top.equalTo(friendCollectionView.snp.bottom).offset(100)
            $0.width.equalTo(135)
            $0.height.equalTo(18)
            $0.centerX.equalToSuperview()
        }
    }

    func configureView(with pinLog: PinLog) {
        locationLabel.text = pinLog.location

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        dateStartLabel.text = dateFormatter.string(from: pinLog.startDate)
        dateEndLabel.text = dateFormatter.string(from: pinLog.endDate)

        let duration = Calendar.current.dateComponents([.day], from: pinLog.startDate, to: pinLog.endDate).day ?? 0
        dateDaysLabel.text = "\(duration) Days"
        mainTitleLabel.text = pinLog.title
        subTextLabel.text = pinLog.content

        selectedImages.removeAll()
        updateSelectedImages(with: pinLog.media)

        if let firstMedia = pinLog.media.first, let latitude = firstMedia.latitude, let longitude = firstMedia.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//            mapViewController?.addPinToMap(location: coordinate, address: firstMedia.url)
//            mapViewController?.addPinToMap(location: coordinate, address: "Image") // 변경된 부분

            mapViewController?.mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)), animated: true)
        }

        for media in pinLog.media {
            if let latitude = media.latitude, let longitude = media.longitude {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                mapViewController?.addPinToMap(location: coordinate, address: media.url)
                mapViewController?.addPinToMap(location: coordinate, address: "")
                
            }
        }
    }

    func setupActionButton() {
        albumAllButton.addTarget(self, action: #selector(showGalleryDetail), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(setupMenu), for: .touchUpInside)
    }
    
    @objc func showGalleryDetail() {
        let galleryDetailVC = GalleryDetailViewController()
        galleryDetailVC.selectedImages = selectedImages.map { $0.0 }
        galleryDetailVC.modalPresentationStyle = .fullScreen
        present(galleryDetailVC, animated: true, completion: nil)
    }
    
    @objc func setupMenu() {
        let shareAction = UIAction(title: "공유하기", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            self.sharePinLog()
        }

        let deleteAction = UIAction(
            title: "삭제하기",
            image: UIImage(systemName: "trash"),
            attributes: .destructive) { _ in
            self.deletePinLog()
        }

        let editAction = UIAction(title: "수정하기", image: UIImage(systemName: "pencil")) { _ in
            self.editPinLog()
        }

        var menuItems = [shareAction]

        if let pinLog = pinLog, let currentUserId = Auth.auth().currentUser?.uid, pinLog.authorId == currentUserId {
            menuItems.append(editAction)
            menuItems.append(deleteAction)
        }

        optionsButton.menu = UIMenu(title: "", children: menuItems)
    }

    
    func deletePinLog() {
        let alert = UIAlertController(title: "삭제 확인", message: "핀로그를 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
            guard let self = self, let pinLog = self.pinLog, let pinLogId = pinLog.id else {
                print("Failed to delete pin log: pinLog or pinLog.id is nil")
                return
            }
            Task {
                do {
                    try await self.pinLogManager.deletePinLog(pinLogId: pinLogId)
                    self.navigationController?.popViewController(animated: true)
                } catch {
                    print("Failed to delete pin log: \(error.localizedDescription)")
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func editPinLog() {
        let inputVC = DetailInputViewController()
        inputVC.delegate = self
        if let pinLog = self.pinLog {
            inputVC.pinLog = pinLog
        }
        navigationController?.pushViewController(inputVC, animated: true)
    }
    
    func sharePinLog() {
        
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


    func updateSelectedImages(with mediaItems: [Media]) {
        selectedImages.removeAll()
        let dispatchGroup = DispatchGroup()

        for media in mediaItems {
            guard let url = URL(string: media.url) else { continue }

            dispatchGroup.enter()
            loadImage(from: url) { [weak self] image in
                if let image = image {
                    if !(self?.selectedImages.contains(where: { $0.0.pngData() == image.pngData() }) ?? false) {
                        self?.selectedImages.append((image, media.isRepresentative)) // 변경: isRepresentative 추가
                    }
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.galleryCollectionView.reloadData()
            if let representativeImage = self.selectedImages.first(where: { $0.1 })?.0 {
                self.backgroundImageView.image = representativeImage
            } else if let firstImage = self.selectedImages.first?.0 {
                self.backgroundImageView.image = firstImage
            } else {
                self.backgroundImageView.image = UIImage(systemName: "photo")
            }
        }
    }

    // 이미지를 로드하는 메서드
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let data = data, let image = UIImage(data: data) {
                completion(image)
                // 위치 정보 확인 및 디버깅 출력
                if let location = StorageManager.shared.extractLocation(from: data) {
                    // Firestore에 위치 데이터 저장
                    self.saveImageLocationToFirestore(imageURL: url.absoluteString, location: location)
                } else {
                    print("이미지 위치 정보가 없습니다.")
                }
            } else {
                print("이미지 로드 실패: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
        task.resume()
    }




    // 이미지 정보 저장
    func saveImageLocationToFirestore(imageURL: String, location: CLLocationCoordinate2D) {
        let db = Firestore.firestore()
        db.collection("images").addDocument(data: [
            "url": imageURL,
            "latitude": location.latitude,
            "longitude": location.longitude,
            "isRepresentative": false, // 기본값으로 false 설정
            "timestamp": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("이미지 위치정보 저장 실패: \(error.localizedDescription)")
            } else {
                print("이미지 위치정보 저장 성공")
            }
        }
    }

    private func setupMapViewController() {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        mapViewController = MapViewController(region: region, startDate: Date(), endDate: Date()) { coordinate, address in
            // 장소가 선택되었을 때의 처리
            // print("Location selected: \(coordinate.latitude), \(coordinate.longitude), address: \(address)")
        }
        guard let mapVC = mapViewController else { return }
        addChild(mapVC)
        view.addSubview(mapVC.view)
        mapVC.view.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(300)
        }
        mapVC.didMove(toParent: self)
        mapVC.view.isUserInteractionEnabled = false // 터치 불가능하도록 설정
    }

    func setupCollectionView() {
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self

        galleryCollectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier)

        friendCollectionView.delegate = self
        friendCollectionView.dataSource = self

        friendCollectionView.register(FriendCollectionViewCell.self, forCellWithReuseIdentifier: FriendCollectionViewCell.identifier)
    }

    func setupSegmentControl() {
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapViewController?.view.isHidden = false
            albumImageView.isHidden = true
            mapAllButton.isHidden = false
            albumAllButton.isHidden = true
        } else {
            mapViewController?.view.isHidden = true
            albumImageView.isHidden = false
            mapAllButton.isHidden = true
            albumAllButton.isHidden = false
            if let representativeImage = selectedImages.first(where: { $0.1 })?.0 {
                albumImageView.image = representativeImage
            } else if let firstImage = selectedImages.first?.0 {
                albumImageView.image = firstImage
            } else {
                albumImageView.image = UIImage(systemName: "photo")
            }
            contentView.sendSubviewToBack(albumImageView)
        }
        view.bringSubviewToFront(segmentControl)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == galleryCollectionView {
            return selectedImages.count
        } else if collectionView == friendCollectionView {
            return selectedFriends.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == galleryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.identifier, for: indexPath) as? GalleryCollectionViewCell else {
                fatalError("컬렉션 뷰 오류")
            }
            let (image, isRepresentative) = selectedImages[indexPath.row] // 변경: 튜플 사용
            cell.configure(with: image, isRepresentative: isRepresentative) // 변경: isRepresentative 전달
            return cell
        } else if collectionView == friendCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendCollectionViewCell.identifier, for: indexPath) as? FriendCollectionViewCell else {
                fatalError("컬렉션 뷰 오류")
            }
            cell.configure(with: selectedFriends[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == galleryCollectionView {
            let mediaItem = pinLog?.media[indexPath.row]
            
            if segmentControl.selectedSegmentIndex == 0 {
                // Map 상태일 때
                if let latitude = mediaItem?.latitude, let longitude = mediaItem?.longitude {
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                    mapViewController?.addPinToMap(location: coordinate, address: mediaItem?.url ?? "")
                    mapViewController?.animatePin(at: coordinate)
                    mapViewController?.mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
                } else {
                    print("사진 위치정보 없음")
                }
            } else if segmentControl.selectedSegmentIndex == 1 {
                // Album 상태일 때
                let image = selectedImages[indexPath.row].0
                albumImageView.image = image
            }
        }
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let offset = scrollView.contentOffset.y

            if let overlayView = backgroundImageView.viewWithTag(999) {
                overlayView.frame = backgroundImageView.bounds
            }

            if offset > 0 {
                UIView.animate(withDuration: 0.3) {
                    self.locationStackView.isHidden = true
                    self.dateStackView.isHidden = true
                    self.profileStackView.isHidden = true

                    self.locationStackView.snp.remakeConstraints {
                        $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
                        $0.centerX.equalToSuperview()
                    }

                    self.scrollView.snp.remakeConstraints {
                        $0.top.equalTo(self.backgroundImageView.snp.bottom).offset(-40)
                        $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
                        $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(40)
                    }

                    self.contentView.snp.remakeConstraints {
                        $0.edges.equalTo(self.scrollView.contentLayoutGuide)
                        $0.width.equalTo(self.scrollView.frameLayoutGuide)
                        $0.bottom.equalTo(self.bottomLogo.snp.bottom).offset(70)
                    }

                    self.backgroundImageView.snp.updateConstraints {
                        $0.height.equalTo(150)
                    }

                    self.view.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.locationStackView.isHidden = false
                    self.dateStackView.isHidden = false
                    self.profileStackView.isHidden = false

                    self.locationStackView.snp.remakeConstraints {
                        $0.bottom.equalTo(self.scrollView.snp.top).offset(-32)
                        $0.leading.equalTo(self.topContentView).inset(38)
                    }

                    self.scrollView.snp.remakeConstraints {
                        $0.top.equalTo(self.backgroundImageView.snp.bottom).offset(-40)
                        $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
                        $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(40)
                    }

                    self.contentView.snp.remakeConstraints {
                        $0.edges.equalTo(self.scrollView.contentLayoutGuide)
                        $0.width.equalTo(self.scrollView.frameLayoutGuide)
                        $0.bottom.equalTo(self.bottomLogo.snp.bottom).offset(70)
                    }

                    self.backgroundImageView.snp.updateConstraints {
                        $0.height.equalTo(515)
                    }

                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    func applyDarkOverlayToBackgroundImage() {
        backgroundImageView.subviews.forEach { subview in
            if subview.tag == 999 {
                subview.removeFromSuperview()
            }
        }

        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.tag = 999

        backgroundImageView.insertSubview(overlayView, belowSubview: topContentView)

        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.view.layoutIfNeeded()
    }
}

extension DetailViewController: DetailInputViewControllerDelegate {
    func didSavePinLog(_ updatedPinLog: PinLog) {
        self.pinLog = updatedPinLog
        configureView(with: updatedPinLog)
    }
}
