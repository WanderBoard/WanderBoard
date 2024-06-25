//
//  GalleryCollectionViewCell.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 5/29/24.
//

import UIKit
import SnapKit
import CoreLocation

class GalleryCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: GalleryCollectionViewCell.self)
    
    var selectedImages: [(UIImage, Bool, CLLocationCoordinate2D?)] = [] {
        didSet {
            photoCollectionView.reloadData()
        }
    }
    
    lazy var photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: photoCollectionViewLayout).then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        $0.alwaysBounceHorizontal = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.alwaysBounceVertical = false
    }
    
    let photoCollectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 16
        $0.sectionInset = .init(top: 0, left: 32, bottom: 0, right: 32)
        $0.itemSize = .init(width: 330, height: 440)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        contentView.addSubview(photoCollectionView)
        
        photoCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension GalleryCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        let (image, isRepresentative, _) = selectedImages[indexPath.row]
        cell.configure(with: image, isRepresentative: isRepresentative)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = contentView.frame.height
        let itemWidth = height * 330 / 440
        return CGSize(width: itemWidth, height: height)
    }
}
