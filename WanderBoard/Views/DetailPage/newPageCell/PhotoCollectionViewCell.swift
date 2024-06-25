//
//  PhotoCollectionViewCell.swift
//  WanderBoard
//
//  Created by Luz on 6/25/24.
//

import UIKit
import SnapKit
import Then

class PhotoCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: PhotoCollectionViewCell.self)
    
    private let photoImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 30
        $0.backgroundColor = .black
        $0.tintColor = .black
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        contentView.addSubview(photoImage)
        
        photoImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(with image: UIImage?, isRepresentative: Bool) {
        photoImage.image = image
    }
}
