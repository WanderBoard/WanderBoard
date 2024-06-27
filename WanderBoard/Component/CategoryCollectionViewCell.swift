//
//  CategoryCollectionViewCell.swift
//  WanderBoard
//
//  Created by David Jang on 6/26/24.
//

import UIKit
import SnapKit

class CategoryCollectionViewCell: UICollectionViewCell {

    static let identifier = "CategoryCollectionViewCell"

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        stackView.axis = .vertical
        stackView.alignment = .center
//        stackView.spacing = 8
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(nameLabel)
        
        contentView.addSubview(stackView)

        imageView.contentMode = .scaleAspectFit
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 14)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(200)
            make.centerY.equalTo(contentView.snp.centerY).offset(-24)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(-24)
            make.centerX.equalTo(imageView.snp.centerX)
        }
    }

    func configure(with image: UIImage?, name: String) {
        imageView.image = image
        nameLabel.text = name
    }
}
