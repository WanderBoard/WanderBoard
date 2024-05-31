
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

class DetailViewController: UIViewController {
    
    var selectedImages: [UIImage] = []
    var selectedFriends: [UIImage] = []
    
    let subTextFieldMinHeight: CGFloat = 90
    var subTextFieldHeightConstraint: Constraint?
    
    let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .black
    }
    
    let topContentView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let introLocation = UILabel().then {
        $0.text = "지도에서 지역을 선택하세요!"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = #colorLiteral(red: 0.2989681959, green: 0.2989682257, blue: 0.2989681959, alpha: 1)
    }
    
    var locationLabel = UILabel().then {
        $0.text = "---"
        $0.font = UIFont.systemFont(ofSize: 40)
        $0.textColor = .white
    }
    
    var dateDaysLabel = UILabel().then {
        $0.text = "0 Days"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .white
    }
    
    var selectDateButton = UIButton(type: .system).then {
        $0.setTitle("날짜를 선택해주세요", for: .normal)
        $0.tintColor = #colorLiteral(red: 0.2989681959, green: 0.2989682257, blue: 0.2989681959, alpha: 1)
    }
    
    let dayStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 10
    }
    
    let locationStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 10
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
    
    let mainTextField = UITextView().then {
        $0.text = "여행 제목을 입력해주세요."
        $0.textColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.textContainerInset = UIEdgeInsets(top: 9, left: 10, bottom: 10, right: 10)
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
        $0.textContainerInset = UIEdgeInsets(top: 9, left: 10, bottom: 10, right: 10)
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.isScrollEnabled = false
    }
    
    let mapTitle = UILabel().then {
        $0.text = "지도"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    let mapContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.isUserInteractionEnabled = true
    }
    
    let mapIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "map")
        $0.tintColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.contentMode = .scaleAspectFit
    }
    
    let mapTitleLabel = UILabel().then {
        $0.text = "여행 맵 정보를 추가해주세요"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.textAlignment = .center
    }
    
    let mapSubtitleLabel = UILabel().then {
        $0.text = "* 사진을 추가하면 위치를 인식합니다"
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textAlignment = .center
        $0.textColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
    }
    
    let mapStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 10
    }
    
    let galleryTitle = UILabel().then {
        $0.text = "앨범"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    let consumptionTitle = UILabel().then {
        $0.text = "지출"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    let addConsumptionButton = UIButton(type: .system).then {
        $0.setTitle("+", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        $0.isHidden = false
    }
    
    let consumptionHeaderStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    let moneyCountTitle = UILabel().then {
        $0.text = "00₩"
        $0.font = UIFont.systemFont(ofSize: 40)
        $0.textColor = #colorLiteral(red: 0.5913596153, green: 0.5913596153, blue: 0.5913596153, alpha: 1)
    }
    
    let consumptionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fillEqually
        $0.spacing = 0
    }
    
    let noConsumptionLabel = UILabel().then {
        $0.text = "들어온 소비 내역이 없습니다."
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = #colorLiteral(red: 0.5913596153, green: 0.5913596153, blue: 0.5913596153, alpha: 1)
        $0.isHidden = false
    }
    
    let friendTitle = UILabel().then {
        $0.text = "메이트"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    let bottomLogo = UIImageView().then {
        $0.image = UIImage(named: "logoBlack")
    }
    
    lazy var galleryCollectionView: UICollectionView = {
        let layout = CustomFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    lazy var friendCollectionView: UICollectionView = {
        let layout = createCollectionViewFlowLayout(for: .horizontal)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FriendCollectionViewCell.self, forCellWithReuseIdentifier: FriendCollectionViewCell.identifier)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupCollectionView()
        setupTextView()
        
        view.backgroundColor = .white
    }
    
    func setupUI() {
        view.addSubview(backgroundImageView)
        backgroundImageView.addSubview(topContentView)
        topContentView.addSubview(introLocation)
        topContentView.addSubview(locationStackView)
        topContentView.addSubview(dayStackView)
        
        locationStackView.addArrangedSubview(locationLabel)
        locationStackView.addArrangedSubview(dayStackView)
        
        dayStackView.addArrangedSubview(dateDaysLabel)
        dayStackView.addArrangedSubview(selectDateButton)
        
        consumptionHeaderStackView.addArrangedSubview(consumptionTitle)
        consumptionHeaderStackView.addArrangedSubview(addConsumptionButton)
        
        consumptionStackView.addArrangedSubview(consumptionHeaderStackView)
        consumptionStackView.addArrangedSubview(moneyCountTitle)
        
        publicStackView.addArrangedSubview(publicLabel)
        publicStackView.addArrangedSubview(publicSwitch)
        
        mapStackView.addArrangedSubview(mapIconImageView)
        mapStackView.addArrangedSubview(mapTitleLabel)
        mapStackView.addArrangedSubview(mapSubtitleLabel)
        
        mapContainerView.addSubview(mapStackView)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(publicStackView)
        contentView.addSubview(mainTextField)
        contentView.addSubview(subTextField)
        contentView.addSubview(mapTitle)
        contentView.addSubview(mapContainerView)
        contentView.addSubview(galleryTitle)
        contentView.addSubview(galleryCollectionView)
        contentView.addSubview(consumptionStackView)
        contentView.addSubview(noConsumptionLabel)
        contentView.addSubview(friendTitle)
        contentView.addSubview(friendCollectionView)
        contentView.addSubview(bottomLogo)
        
        scrollView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapContainerViewTapped))
        mapContainerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupConstraints() {
        backgroundImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(350)
        }
        
        topContentView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        introLocation.snp.makeConstraints {
            $0.top.equalTo(150)
            $0.leading.equalTo(topContentView).inset(38)
        }
        
        locationStackView.snp.makeConstraints {
            $0.top.equalTo(introLocation).offset(20)
            $0.leading.equalTo(topContentView).inset(38)
        }
        
        selectDateButton.snp.makeConstraints {
            $0.leading.equalTo(dateDaysLabel.snp.trailing).offset(20)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(backgroundImageView.snp.bottom).offset(-40)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.bottom.equalTo(bottomLogo.snp.bottom).offset(70)
        }
        
        publicStackView.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(32)
            $0.leading.trailing.equalTo(contentView).inset(16)
        }
        
        mainTextField.snp.makeConstraints {
            $0.top.equalTo(publicStackView.snp.bottom).offset(32)
            $0.leading.trailing.equalTo(contentView).inset(16)
            $0.height.equalTo(37)
        }
        
        subTextField.snp.makeConstraints {
            $0.top.equalTo(mainTextField.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView).inset(16)
            self.subTextFieldHeightConstraint = $0.height.greaterThanOrEqualTo(subTextFieldMinHeight).constraint
        }
        
        mapTitle.snp.makeConstraints {
            $0.top.equalTo(subTextField.snp.bottom).offset(32)
            $0.leading.equalTo(17)
        }
        
        mapContainerView.snp.makeConstraints {
            $0.top.equalTo(mapTitle.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView)
            $0.height.equalTo(250)
        }
        
        mapStackView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
        
        galleryTitle.snp.makeConstraints {
            $0.top.equalTo(mapContainerView.snp.bottom).offset(32)
            $0.leading.equalTo(contentView).inset(16)
        }
        
        galleryCollectionView.snp.makeConstraints {
            $0.top.equalTo(galleryTitle.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(16)
            $0.height.equalTo(400)
        }
        
        consumptionHeaderStackView.snp.makeConstraints {
            $0.top.equalTo(consumptionStackView.snp.top)
            $0.leading.trailing.equalTo(contentView).inset(16)
        }
        
        consumptionStackView.snp.makeConstraints {
            $0.top.equalTo(galleryCollectionView.snp.bottom).offset(32)
            $0.leading.equalTo(contentView).inset(16)
        }
        
        noConsumptionLabel.snp.makeConstraints {
            $0.top.equalTo(moneyCountTitle.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView).inset(16)
        }
        
        
        friendTitle.snp.makeConstraints {
            $0.top.equalTo(noConsumptionLabel.snp.bottom).offset(32)
            $0.leading.equalTo(contentView).offset(17)
        }
        
        friendCollectionView.snp.makeConstraints {
            $0.top.equalTo(friendTitle.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(17)
            $0.height.equalTo(90)
        }
        
        bottomLogo.snp.makeConstraints {
            $0.top.equalTo(friendCollectionView.snp.bottom).offset(100)
            $0.width.equalTo(135)
            $0.height.equalTo(18)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupTextView() {
        mainTextField.delegate = self
        subTextField.delegate = self
        
    }
    
    func setupCollectionView() {
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        
        friendCollectionView.delegate = self
        friendCollectionView.dataSource = self
        
        updateCollectionViewHeight()
    }
    
    func createCollectionViewFlowLayout(for scrollDirection: UICollectionView.ScrollDirection) -> UICollectionViewFlowLayout {
        let layout = CustomFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        layout.estimatedItemSize = .zero
        return layout
    }
    
    func updateCollectionViewHeight() {
        let numberOfImages = selectedImages.count
        let newHeight: CGFloat = numberOfImages >= 3 ? 410 : 120
        galleryCollectionView.snp.updateConstraints {
            $0.height.equalTo(newHeight)
        }
        view.layoutIfNeeded()
    }
}


extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, PHPickerViewControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == galleryCollectionView {
            return max(selectedImages.count, 1)
        } else {
            return max(selectedFriends.count, 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == galleryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.identifier, for: indexPath) as? GalleryCollectionViewCell else { fatalError("컬렉션 뷰 오류")}
            if selectedImages.isEmpty {
                cell.configure(with: nil)
            } else {
                cell.configure(with: selectedImages[indexPath.row])
                cell.imageView.layer.cornerRadius = 16
                cell.imageView.clipsToBounds = true
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendCollectionViewCell.identifier, for: indexPath) as? FriendCollectionViewCell else { fatalError("컬렉션 뷰 오류")}
            if selectedFriends.isEmpty {
                cell.configure(with: nil)
            } else {
                cell.configure(with: selectedFriends[indexPath.row])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == galleryCollectionView && selectedImages.isEmpty {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 0
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.selectedImages.append(image)
                        self?.galleryCollectionView.reloadData()
                        self?.updateCollectionViewHeight()
                        
                        if let firstImage = self?.selectedImages.first {
                            self?.backgroundImageView.image = firstImage
                            self?.applyDarkOverlayToBackgroundImage()
                        }
                    }
                }
            }
        }
    }
    
    func applyDarkOverlayToBackgroundImage() {
        let overlayView = UIView(frame: backgroundImageView.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        backgroundImageView.addSubview(overlayView)
        
        view.bringSubviewToFront(locationStackView)
        self.view.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == galleryCollectionView {
            if selectedImages.isEmpty {
                return CGSize(width: 173, height: 115)
            } else {
                switch indexPath.row {
                case 0, 3:
                    return CGSize(width: 173, height: 115)
                case 1, 2:
                    return CGSize(width: 173, height: 223)
                default:
                    return CGSize(width: 173, height: 115)
                }
            }
        } else {
            return CGSize(width: 73, height: 73)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset > 0 {
            UIView.animate(withDuration: 0.3) {
                self.locationStackView.axis = .horizontal
                self.locationStackView.spacing = 10
                self.locationStackView.alignment = .center
                self.locationLabel.font = UIFont.systemFont(ofSize: 20)
                self.selectDateButton.isHidden = true
                self.introLocation.isHidden = true
                self.locationStackView.snp.remakeConstraints {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
                    $0.centerX.equalToSuperview()
                }
                self.scrollView.layer.cornerRadius = 40
                self.view.clipsToBounds = true
                self.scrollView.snp.remakeConstraints {
                    $0.top.equalTo(self.locationStackView.snp.bottom).offset(10)
                    $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
                }
                self.contentView.snp.remakeConstraints {
                    $0.edges.equalTo(self.scrollView.contentLayoutGuide)
                    $0.width.equalTo(self.scrollView.frameLayoutGuide)
                    $0.height.equalTo(1500)
                }
                self.backgroundImageView.snp.updateConstraints {
                    $0.height.equalTo(200)
                }
                
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.locationStackView.axis = .vertical
                self.locationStackView.spacing = 10
                self.locationStackView.alignment = .leading
                self.locationLabel.font = UIFont.systemFont(ofSize: 40)
                self.selectDateButton.isHidden = false
                self.introLocation.isHidden = false
                self.locationStackView.snp.remakeConstraints {
                    $0.top.equalTo(self.introLocation.snp.bottom).offset(20)
                    $0.leading.trailing.equalTo(self.topContentView).inset(38)
                }
                self.scrollView.snp.remakeConstraints {
                    $0.top.equalTo(self.backgroundImageView.snp.bottom).offset(-40)
                    $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
                }
                self.contentView.snp.remakeConstraints {
                    $0.edges.equalTo(self.scrollView.contentLayoutGuide)
                    $0.width.equalTo(self.scrollView.frameLayoutGuide)
                    $0.height.equalTo(1500)
                }
                self.backgroundImageView.snp.updateConstraints {
                    $0.height.equalTo(350)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func mapContainerViewTapped() {
        let mapDetailVC = MapDetailViewController()
        let navigationController = UINavigationController(rootViewController: mapDetailVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}


extension UITextView {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        self.textContainerInset.left = amount
    }
    
    func setTopPaddingPoints(_ amount: CGFloat) {
        self.textContainerInset.top = amount
    }
}


extension DetailViewController: UITextViewDelegate {
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

