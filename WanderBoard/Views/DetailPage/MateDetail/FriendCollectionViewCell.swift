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
    
    weak var delegate: FriendCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapImage)
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
        imageView.layer.cornerRadius = 30
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = 30
    }
    
    func configure(with image: UIImage?) {
        imageView.image = image
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        delegate?.didTapImage(in: self)
    }
}

protocol FriendCollectionViewCellDelegate: AnyObject {
    func didTapImage(in cell: FriendCollectionViewCell)
}

