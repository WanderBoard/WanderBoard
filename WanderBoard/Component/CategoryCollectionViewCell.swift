//
//  CategoryCollectionViewCell.swift
//  WanderBoard
//
//  Created by David Jang on 6/26/24.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CategoryCollectionViewCell"
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)

        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }

        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with image: UIImage?, name: String) {
        imageView.image = image
        nameLabel.text = name
    }
}
