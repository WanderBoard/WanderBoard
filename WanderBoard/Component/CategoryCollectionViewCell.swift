//
//  CategoryCollectionViewCell.swift
//  WanderBoard
//
//  Created by David Jang on 6/26/24.
//

import UIKit
import SnapKit

protocol CategoryCollectionViewCellDelegate: AnyObject {
    func didTapCategoryButton(_ cell: CategoryCollectionViewCell)
}

class CategoryCollectionViewCell: UICollectionViewCell {

    static let identifier = "CategoryCollectionViewCell"

    weak var delegate: CategoryCollectionViewCellDelegate?
    
    let imageView = UIImageView()

    let button = UIButton()
    let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(button)
        contentView.addSubview(nameLabel)

        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 14)
      
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        button.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(button.snp.width)
        }
                
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(button.snp.bottom).offset(16)
            make.centerX.equalTo(button.snp.centerX)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 4, height: 2)
        button.layer.shadowRadius = 4

        button.addTarget(self, action: #selector(iconTapped), for: .touchUpInside)
    }

    @objc private func iconTapped() {
        delegate?.didTapCategoryButton(self)
    }

    func configure(with image: UIImage?, name: String) {
        button.setImage(image, for: .normal)
        nameLabel.text = name
    }
}
