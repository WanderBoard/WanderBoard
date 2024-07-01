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
    
    let minimumLineSpacing: CGFloat = 24
    let aspectRatio: CGFloat = 330 / 465
    
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
        $0.decelerationRate = .fast
    }
    
    let photoCollectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 24
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight < 750 {
            $0.sectionInset = .init(top: 0, left: 50, bottom: 0, right: 40)
        } else {
            $0.sectionInset = .init(top: 0, left: 40, bottom: 0, right: 35)
        }
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
    
    func calculateItemWidth() -> CGFloat {
        let height = photoCollectionView.frame.height
        return height * aspectRatio
    }
}

extension GalleryCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        let itemWidth = calculateItemWidth()
        let height = collectionView.frame.height
        return CGSize(width: itemWidth, height: height)
    }
    
    // 페이징 기능 추가
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemWidth = calculateItemWidth()
        let cellWidthIncludeSpacing = itemWidth + minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludeSpacing
        let roundedIndex: CGFloat = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludeSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}
