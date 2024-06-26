//
//  PhotoInputCollectionViewCell.swift
//  WanderBoard
//
//  Created by 김시종 on 6/26/24.
//

import UIKit

class PhotoInputCollectionViewCell: UICollectionViewCell {
    static let identifier = "PhotoInputCollectionViewCell"
    
    var isRepresentative: Bool = false {
        didSet {
            representativeLabel.isHidden = !isRepresentative
        }
    }
    
    let imageView = UIImageView()
    let addButton = UIButton(type: .system)
    
    let representativeLabel = UILabel().then {
        $0.text = "대표"
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.textColor = .white
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        self.isUserInteractionEnabled = true
        self.contentView.backgroundColor = .darkgray
        self.contentView.layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(addButton)
        contentView.addSubview(representativeLabel)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 80)
        addButton.backgroundColor = .clear
        addButton.layer.cornerRadius = 16
        addButton.isUserInteractionEnabled = false
        addButton.clipsToBounds = true
        addButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        representativeLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(6)
            $0.size.equalTo(CGSize(width: 40, height: 24))
        }
    }

    func configure(with image: UIImage?, isRepresentative: Bool) {
        if let image = image {
            imageView.image = image
            imageView.isHidden = false
            addButton.isHidden = true
            self.isRepresentative = isRepresentative
        } else {
            imageView.isHidden = true
            addButton.isHidden = false
            representativeLabel.isHidden = true
        }
    }
}
