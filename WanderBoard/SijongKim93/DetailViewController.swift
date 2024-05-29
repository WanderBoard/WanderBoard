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
    var selectedFriends: [String] = []
    
    let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .black
    }
    
    let topContentView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let weatherButton = UIButton(type: .system).then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 37, weight: .light)
        let image = UIImage(systemName: "sun.min", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = .white
        $0.contentHorizontalAlignment = .center
        $0.contentVerticalAlignment = .center
    }
    
    let locationLabel = UILabel().then {
        $0.text = "----"
        $0.font = UIFont.systemFont(ofSize: 50)
        $0.textColor = .white
    }
    
    let selectDateButton = UIButton(type: .system).then {
        $0.setTitle("Select Dates", for: .normal)
        $0.tintColor = .white
    }
    
    let weatherStackView = UIStackView().then {
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
    
    let mainTextField = UITextField().then {
        $0.placeholder = "여행 제목을 입력해주세요."
        $0.borderStyle = .none
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        $0.setLeftPaddingPoints(10)
        $0.setPlaceholderAlignment(to: .left, .center)
    }
    
    let subTextField = UITextField().then {
        $0.placeholder = "기록을 담아 주세요."
        $0.borderStyle = .none
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        $0.setLeftPaddingPoints(10)
        $0.setTopPaddingPoints(10)
        $0.setPlaceholderAlignment(to: .left, .top)
    }
    
    let mapTitle = UILabel().then {
        $0.text = "이동거리"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    let noMapTitle = UILabel().then {
        $0.text = "저장된 사진 정보로\n맵 정보가 업데이트됩니다."
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    let galleryTitle = UILabel().then {
        $0.text = "나의 갤러리"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    let consumptionTitle = UILabel().then {
        $0.text = "소비 내역"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    let moneyCountTitle = UILabel().then {
        $0.text = "00₩"
        $0.font = UIFont.systemFont(ofSize: 40)
        $0.textColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
    }
    
    let addConsumptionButton = UIButton(type: .system).then {
        $0.setTitle("내역 추가 →", for: .normal)
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.isHidden = false
    }
    
    let consumptionStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
    }
    
    let noConsumptionLabel = UILabel().then {
        $0.text = "들어온 소비 내역이 없습니다."
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        $0.isHidden = false
    }
    
    let friendTitle = UILabel().then {
        $0.text = "같이 간 친구"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    
    lazy var galleryCollectionView: UICollectionView = {
        let layout = createCollectionViewFlowLayout(for: .vertical)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier)
        return collectionView
    }()
    
    lazy var friendCollectionView: UICollectionView = {
        let layout = createCollectionViewFlowLayout(for: .horizontal)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FriendCollectionViewCell.self, forCellWithReuseIdentifier: FriendCollectionViewCell.identifier)
        return collectionView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupCollectionView()
        
        view.backgroundColor = .white
    }
    
    
    func setupUI() {
        view.addSubview(backgroundImageView)
        backgroundImageView.addSubview(topContentView)
        topContentView.addSubview(weatherStackView)
        
        weatherStackView.addArrangedSubview(weatherButton)
        weatherStackView.addArrangedSubview(locationLabel)
        weatherStackView.addArrangedSubview(selectDateButton)
        
        consumptionStackView.addArrangedSubview(moneyCountTitle)
        consumptionStackView.addArrangedSubview(addConsumptionButton)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainTextField)
        contentView.addSubview(subTextField)
        contentView.addSubview(mapTitle)
        contentView.addSubview(noMapTitle)
        contentView.addSubview(galleryTitle)
        contentView.addSubview(galleryCollectionView)
        contentView.addSubview(consumptionTitle)
        contentView.addSubview(consumptionStackView)
        contentView.addSubview(noConsumptionLabel)
        contentView.addSubview(friendTitle)
        contentView.addSubview(friendCollectionView)
        
        scrollView.delegate = self
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
        
        weatherStackView.snp.makeConstraints {
            $0.top.equalTo(150)
            $0.leading.trailing.equalTo(topContentView).inset(37)
            
        }
        
        weatherButton.snp.makeConstraints {
            $0.width.height.equalTo(37)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(backgroundImageView.snp.bottom).offset(-40)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.equalTo(1500)
        }
        
        mainTextField.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(30)
            $0.leading.trailing.equalTo(contentView).inset(17)
            $0.height.equalTo(37)
        }
        
        subTextField.snp.makeConstraints {
            $0.top.equalTo(mainTextField.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView).inset(17)
            $0.height.equalTo(87)
        }
        
        mapTitle.snp.makeConstraints {
            $0.top.equalTo(subTextField.snp.bottom).offset(30)
            $0.leading.equalTo(17)
        }
        
        noMapTitle.snp.makeConstraints {
            $0.top.equalTo(mapTitle.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(17)
        }
        
        galleryTitle.snp.makeConstraints {
            $0.top.equalTo(noMapTitle.snp.bottom).offset(30)
            $0.leading.equalTo(contentView).inset(17)
        }
        
        galleryCollectionView.snp.makeConstraints {
            $0.top.equalTo(galleryTitle.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(17)
            $0.height.equalTo(400)
        }
        
        consumptionTitle.snp.makeConstraints {
            $0.top.equalTo(galleryCollectionView.snp.bottom).offset(30)
            $0.leading.equalTo(contentView).inset(17)
        }
        
        consumptionStackView.snp.makeConstraints {
            $0.top.equalTo(consumptionTitle.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(17)
        }
        
        noConsumptionLabel.snp.makeConstraints {
            $0.top.equalTo(consumptionStackView.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView).inset(17)
        }
        
        moneyCountTitle.snp.makeConstraints {
            $0.leading.equalTo(consumptionStackView.snp.leading)
            $0.width.equalTo(250)
            $0.centerY.equalToSuperview()
        }
        
        addConsumptionButton.snp.makeConstraints {
            $0.trailing.equalTo(consumptionStackView.snp.trailing)
            $0.centerY.equalToSuperview()
        }
        
        friendTitle.snp.makeConstraints {
            $0.top.equalTo(noConsumptionLabel.snp.bottom).offset(30)
            $0.leading.equalTo(contentView).offset(17)
        }
        
        friendCollectionView.snp.makeConstraints {
            $0.top.equalTo(friendTitle.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(17)
        }
    }
    
    func setupCollectionView() {
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        
        friendCollectionView.delegate = self
        friendCollectionView.dataSource = self
        
        updateCollectionViewHeight()
    }
    
    func createCollectionViewFlowLayout(for scrollDirection: UICollectionView.ScrollDirection) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        layout.estimatedItemSize = .zero
        return layout
    }
    
    func updateCollectionViewHeight() {
        let numberOfImages = selectedImages.count
        let newHeight: CGFloat = numberOfImages >= 3 ? 480 : 120
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
            return selectedFriends.count
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
            let label = UILabel()
            label.text = selectedFriends[indexPath.row]
            label.textAlignment = .center
            cell.contentView.addSubview(label)
            label.snp.makeConstraints {
                $0.edges.equalToSuperview()
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
        
        view.bringSubviewToFront(weatherStackView)
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
                self.weatherStackView.axis = .horizontal
                self.weatherStackView.spacing = 10
                self.weatherStackView.alignment = .center
                self.weatherStackView.snp.remakeConstraints {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
                    $0.centerX.equalToSuperview()
                }
                self.scrollView.layer.cornerRadius = 40
                self.view.clipsToBounds = true
                self.scrollView.snp.remakeConstraints {
                    $0.top.equalTo(self.weatherStackView.snp.bottom).offset(10)
                    $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
                }
                self.contentView.snp.remakeConstraints {
                    $0.edges.equalTo(self.scrollView.contentLayoutGuide)
                    $0.width.equalTo(self.scrollView.frameLayoutGuide)
                    $0.height.equalTo(1500)
                }
                self.backgroundImageView.snp.updateConstraints {
                    $0.height.equalTo(200) // 줄어든 높이
                }
                
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.weatherStackView.axis = .vertical
                self.weatherStackView.spacing = 10
                self.weatherStackView.alignment = .leading
                self.weatherStackView.snp.remakeConstraints {
                    $0.top.equalTo(150)
                    $0.leading.trailing.equalTo(self.topContentView).inset(37)
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
                    $0.height.equalTo(350) // 원래 높이로 복원
                }
                self.view.layoutIfNeeded()
            }
        }
    }
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setTopPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 10, width: self.frame.width, height: amount))
        self.addSubview(paddingView)
        self.contentVerticalAlignment = .top
        self.setNeedsDisplay()
    }
    
    func setPlaceholderAlignment(to horizontal: NSTextAlignment, _ vertical: UIControl.ContentVerticalAlignment) {
        self.textAlignment = horizontal
        self.contentVerticalAlignment = vertical
    }
}

//extension DetailViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offset = scrollView.contentOffset.y
//        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
//        let percentage = offset / maxOffset
//
//        backgroundImageView.alpha = 1 - percentage
//    }
//}
