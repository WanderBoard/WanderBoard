//
//  GalleryCollectionViewCell.swift
//  WanderBoard
//
//  Created by David Jang on 6/25/24.
//

import UIKit

class GalleryMapCollectionViewCell: UICollectionViewCell {
    static let identifier = "GalleryMapCollectionViewCell"
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupSelectedBackgroundView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with media: Media) {
        if let imageUrl = URL(string: media.url) {
            imageView.kf.setImage(with: imageUrl)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
        if media.latitude == nil || media.longitude == nil {
            let blurView = UIView()
            blurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            blurView.frame = imageView.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imageView.addSubview(blurView)
            
            let locationIcon = UIImageView(image: UIImage(systemName: "location.slash.fill"))
            locationIcon.tintColor = .white
            blurView.addSubview(locationIcon)
            locationIcon.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(24)
            }
        } else {
            imageView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    
    private func setupSelectedBackgroundView() {
        let selectedView = UIView(frame: bounds)
        selectedView.layer.borderColor = UIColor.red.cgColor
        selectedView.layer.borderWidth = 2
        selectedView.layer.cornerRadius = 8
        selectedView.backgroundColor = .clear
        selectedBackgroundView = selectedView
    }
}

