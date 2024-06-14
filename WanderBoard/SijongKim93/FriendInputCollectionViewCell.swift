//
//  FriendInputCollectionViewCell.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 6/4/24.
//

import UIKit

class FriendInputCollectionViewCell: UICollectionViewCell {
    static let identifier = "FriendInputCollectionViewCell"
    
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
        imageView.layer.cornerRadius = 42.5
        imageView.clipsToBounds = true
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(#colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1), for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        addButton.backgroundColor = .clear
        addButton.layer.cornerRadius = 42.5
        addButton.layer.borderColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        addButton.layer.borderWidth = 1
        addButton.clipsToBounds = true
        addButton.isHidden = true
        addButton.isUserInteractionEnabled = false
        addButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(with imageURL: URL?) {
        if let imageURL = imageURL {
            imageView.kf.setImage(with: imageURL)
            imageView.isHidden = false
            addButton.isHidden = true
        } else {
            imageView.isHidden = true
            addButton.isHidden = false
        }
    }
}




