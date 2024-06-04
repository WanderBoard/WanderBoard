//
//  GalleryCollectionViewCell.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 5/29/24.
//

import UIKit
import SnapKit

class GalleryCollectionViewCell: UICollectionViewCell {
    static let identifier = "GalleryCollectionViewCell"
    
    let imageView = UIImageView()
    let addButton = UIButton(type: .system)
    let overlayView = UIView()
    let moreLabel = UILabel()
    
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
        contentView.addSubview(overlayView)
        overlayView.addSubview(moreLabel)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        addButton.backgroundColor = #colorLiteral(red: 0.7674039006, green: 0.7674039006, blue: 0.7674039006, alpha: 1)
        addButton.layer.cornerRadius = 16
        addButton.clipsToBounds = true
        addButton.isHidden = true
        addButton.isUserInteractionEnabled = false
        addButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 16
        overlayView.isHidden = true
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        moreLabel.textColor = .white
        moreLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        moreLabel.textAlignment = .center
        moreLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
    }
    
    func configure(with image: UIImage?, moreCount: Int? = nil) {
        if let image = image {
            imageView.image = image
            imageView.isHidden = false
            addButton.isHidden = true
            if let count = moreCount {
                overlayView.isHidden = false
                moreLabel.text = "+\(count) more"
            } else {
                overlayView.isHidden = true
                moreLabel.text = nil
            }
        } else {
            imageView.isHidden = true
            addButton.isHidden = false
            overlayView.isHidden = true
            moreLabel.text = nil
        }
    }
}
