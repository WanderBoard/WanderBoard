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
    func didDeleteImage(at index: Int)
}

class GallaryInputCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "GallaryInputCollectionViewCell"
    
    weak var delegate: GallaryInputCollectionViewCellDelegate?
    
    var selectedImages: [(UIImage, Bool, CLLocationCoordinate2D?)] = [] {
        didSet {
            if !selectedImages.contains(where: { $0.1 }) && !selectedImages.isEmpty {
                selectedImages[0].1 = true
            }
            DispatchQueue.main.async {
                if let layout = self.photoInputCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    if self.selectedImages.isEmpty {
                        layout.sectionInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 64)
                    } else {
                        layout.sectionInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 64)
                    }
                }
                self.photoInputCollectionView.reloadData()
                self.photoInputCollectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    lazy var photoInputCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 64)
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

extension GallaryInputCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoInputCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoInputCollectionViewCell.identifier, for: indexPath) as! PhotoInputCollectionViewCell
        
        if indexPath.item == 0 {
            cell.configure(with: nil, isRepresentative: false, indexPath: indexPath)
        } else {
            let (image, isRepresentative, _) = selectedImages[indexPath.item - 1]
            cell.configure(with: image, isRepresentative: isRepresentative, indexPath: indexPath)
            cell.delegate = self
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - (selectedImages.isEmpty ? 128 : 96)
        let height = collectionView.frame.height
        
        if indexPath.item == 0 && !selectedImages.isEmpty {
            return CGSize(width: width / 2, height: height)
        } else {
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            delegate?.didSelectAddPhoto()
        } else {
            if let previousRepresentativeIndex = selectedImages.firstIndex(where: { $0.1 }) {
                selectedImages[previousRepresentativeIndex].1 = false
            }
            selectedImages[indexPath.item - 1].1 = true
            collectionView.reloadData()
            delegate?.didSelectRepresentativeImage(at: indexPath.item - 1)
        }
    }
    
    func didTapDeleteButton(at indexPath: IndexPath) {
        selectedImages.remove(at: indexPath.item - 1)
        if selectedImages.isEmpty {
            photoInputCollectionView.reloadData()
        } else {
            if !selectedImages.contains(where: { $0.1 }) {
                selectedImages[0].1 = true
            }
            photoInputCollectionView.reloadData()
        }
        delegate?.didDeleteImage(at: indexPath.item - 1)
    }
}
