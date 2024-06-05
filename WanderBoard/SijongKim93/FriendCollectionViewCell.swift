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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(imageView)
    
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.layoutIfNeeded()
        imageView.layer.cornerRadius = imageView.frame.height / 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.height / 2
    }
    
    func configure(with image: UIImage?) {
        imageView.image = image
    }
}
