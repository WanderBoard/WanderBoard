
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

class DetailViewController: UIViewController {
    
    var selectedImages: [UIImage] = []
    var selectedFriends: [UIImage] = []
    var pinLog: PinLog?
    
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
    
    let shareButton = UIButton().then {
        $0.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        $0.tintColor = .black
    }
    
    var mainTitleLabel = UILabel().then {
        $0.text = "부산에 다녀왔다"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    var subTextLabel = UILabel().then {
        $0.text = "여기에는 이전 인풋VC 텍스트필드에서 작성된 내용이 들어옵니다. 이 텍스트는 더미 텍스트입니다."
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.numberOfLines = 0
    }
    
    let mapView = MKMapView().then {
        $0.isUserInteractionEnabled = false
    }
    
    let segmentControl: UISegmentedControl = {
        let items = ["Map", "Album"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0

        segment.backgroundColor = UIColor(white: 1, alpha: 0.5)
        segment.layer.cornerRadius = 16
        segment.layer.masksToBounds = true
//        segment.layer.shadowColor = UIColor.black.cgColor
//        segment.layer.shadowOffset = CGSize(width: 0, height: 2)
//        segment.layer.shadowRadius = 10
//        segment.layer.shadowOpacity = 0.1
        
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
        $0.font = UIFont.systemFont(ofSize: 30 ,weight: .semibold)
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
        $0.image = UIImage(named: "logoBlack")
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupCollectionView()
        setupSegmentControl()
        applyDarkOverlayToBackgroundImage()
        setupActionButton()
        
        view.backgroundColor = .white
        
        if let pinLog = pinLog {
            configureView(with: pinLog)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
    }
    
    func setupUI() {
        view.addSubview(backgroundImageView)
        backgroundImageView.addSubview(topContentView)
        topContentView.addSubview(locationStackView)
        topContentView.addSubview(dateStackView)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(shareButton)
        contentView.addSubview(mainTitleLabel)
        contentView.addSubview(subTextLabel)
        contentView.addSubview(mapView)
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
            $0.height.equalTo(457)
        }
        
        topContentView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        locationStackView.snp.makeConstraints {
            $0.bottom.equalTo(scrollView.snp.top).offset(-32)
            $0.leading.equalTo(topContentView).inset(38)
        }
        
        dateStackView.snp.makeConstraints {
            $0.bottom.equalTo(locationStackView).inset(-1)
            $0.leading.equalTo(dateDaysLabel.snp.trailing).offset(32)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(backgroundImageView.snp.bottom).offset(-40)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(40)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.bottom.equalTo(bottomLogo.snp.bottom).offset(70)
        }
        
        shareButton.snp.makeConstraints {
            $0.top.trailing.equalTo(contentView).inset(24)
            $0.width.height.equalTo(24)
        }
        
        mainTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(50)
            $0.leading.trailing.equalTo(contentView).inset(16)
        }
        
        subTextLabel.snp.makeConstraints {
            $0.top.equalTo(mainTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView).inset(16)
        }
        
        segmentControl.snp.makeConstraints {
            $0.top.equalTo(subTextLabel.snp.bottom).offset(48)
            $0.leading.equalTo(contentView).inset(16)
            $0.height.equalTo(30)
            $0.width.equalTo(123)
        }
        
        mapView.snp.makeConstraints {
            $0.top.equalTo(segmentControl).offset(-10)
            $0.leading.trailing.equalTo(contentView)
            $0.height.equalTo(300)
        }
        
        albumImageView.snp.makeConstraints {
            $0.top.equalTo(segmentControl).offset(-10)
            $0.leading.trailing.equalTo(contentView)
            $0.height.equalTo(300)
        }
        
        galleryCollectionView.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(10)
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
        
        updateSelectedImages(with: pinLog.media)
        
        if let firstMedia = pinLog.media.first, let latitude = firstMedia.latitude, let longitude = firstMedia.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
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
    
    func updateSelectedImages(with mediaItems: [Media]) {
        selectedImages = []
        let group = DispatchGroup()
        
        for media in mediaItems {
            guard URL(string: media.url) != nil else { continue }
            group.enter()
            loadImage(from: media.url) { [weak self] image in
                if let image = image {
                    self?.selectedImages.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.galleryCollectionView.reloadData()
            if let firstImage = self.selectedImages.first {
                self.backgroundImageView.image = firstImage
            } else {
                self.backgroundImageView.image = UIImage(systemName: "photo")
            }
        }
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
            mapView.isHidden = false
            albumImageView.isHidden = true
            mapAllButton.isHidden = false
            albumAllButton.isHidden = true
        } else {
            mapView.isHidden = true
            albumImageView.isHidden = false
            mapAllButton.isHidden = true
            albumAllButton.isHidden = false
            if let firstImage = selectedImages.first {
                albumImageView.image = firstImage
            }
            contentView.sendSubviewToBack(albumImageView)
        }
        view.bringSubviewToFront(segmentControl)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setupActionButton() {
        albumAllButton.addTarget(self, action: #selector(showGalleryDetail), for: .touchUpInside)
    }
    
    @objc func showGalleryDetail() {
        let galleryDetailVC = GalleryDetailViewController()
        galleryDetailVC.selectedImages = selectedImages
        galleryDetailVC.modalPresentationStyle = .fullScreen
        present(galleryDetailVC, animated: true, completion: nil)
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
            cell.configure(with: selectedImages[indexPath.row])
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
        if collectionView == galleryCollectionView && segmentControl.selectedSegmentIndex == 1 {
            let selectedImage = selectedImages[indexPath.row]
            albumImageView.image = selectedImage
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
                    self.locationStackView.axis = .horizontal
                    self.locationStackView.spacing = 10
                    self.locationStackView.alignment = .center
                    self.locationLabel.font = UIFont.systemFont(ofSize: 20)
                    self.dateStackView.isHidden = true
                    
                    self.locationStackView.snp.remakeConstraints {
                        $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
                        $0.centerX.equalToSuperview()
                    }
                    
                    self.scrollView.layer.cornerRadius = 40
                    self.view.clipsToBounds = true
                    
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
                    self.locationStackView.axis = .vertical
                    self.locationStackView.spacing = 10
                    self.locationStackView.alignment = .leading
                    self.locationLabel.font = UIFont.systemFont(ofSize: 40)
                    self.dateStackView.isHidden = false
                    
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
                        $0.height.equalTo(457)
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
    
