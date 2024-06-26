//
//  InPutGallaryCollectionViewCell.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 6/4/24.
//

import UIKit
import CoreLocation

protocol GallaryInputCollectionViewCellDelegate: AnyObject {
    func didSelectAddPhoto()
    func didSelectRepresentativeImage(at index: Int)
}

class GallaryInputCollectionViewCell: UICollectionViewCell {
    static let identifier = "GallaryInputCollectionViewCell"
    
    weak var delegate: GallaryInputCollectionViewCellDelegate?
    
    var selectedImages: [(UIImage, Bool, CLLocationCoordinate2D?)] = [] {
        didSet {
            DispatchQueue.main.async {
                self.photoInputCollectionView.reloadData()
                self.photoInputCollectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    lazy var photoInputCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoInputCollectionViewCell.self, forCellWithReuseIdentifier: PhotoInputCollectionViewCell.identifier)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        //self.isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubview(photoInputCollectionView)

        photoInputCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension GallaryInputCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoInputCollectionViewCell.identifier, for: indexPath) as! PhotoInputCollectionViewCell
        
        if indexPath.item == 0 {
            cell.configure(with: nil, isRepresentative: false)
        } else {
            let (image, isRepresentative, _) = selectedImages[indexPath.item - 1]
            cell.configure(with: image, isRepresentative: isRepresentative)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            delegate?.didSelectAddPhoto()
        } else {
            delegate?.didSelectRepresentativeImage(at: indexPath.row)
        }
    }
}

