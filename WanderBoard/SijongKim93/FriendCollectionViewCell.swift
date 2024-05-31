//
//  FriendCollectionViewCell.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 5/29/24.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    static let identifier = "FriendCollectionViewCell"
    
    let imageView = UIImageView()
    let addButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(addButton)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 73 / 2
        imageView.layer.masksToBounds = true
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(73)
            $0.center.equalToSuperview()
        }
        
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        addButton.backgroundColor = #colorLiteral(red: 0.7674039006, green: 0.7674039006, blue: 0.7674039006, alpha: 1)
        addButton.layer.cornerRadius = 73 / 2
        addButton.clipsToBounds = true
        addButton.snp.makeConstraints {
            $0.width.height.equalTo(73)
            $0.center.equalToSuperview()
        }
    }
    
    func configure(with image: UIImage?) {
        if let image = image {
            imageView.image = image
            imageView.isHidden = false
            addButton.isHidden = true
        } else {
            imageView.isHidden = true
            addButton.isHidden = false
        }
    }
}
