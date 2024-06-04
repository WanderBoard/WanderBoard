//
//  HotCollectionViewCell.swift
//  WanderBoard
//
//  Created by Luz on 6/3/24.
//

import UIKit
import SnapKit

class HotCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: HotCollectionViewCell.self)
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.image = UIImage(systemName: "photo")
        $0.backgroundColor = .black
        $0.tintColor = .black
        $0.layer.cornerRadius = 30
    }
    
    let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .white
        $0.text = "2023.05"
    }
    
    let localLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.textColor = .white
        $0.text = "충청북도 청주시"
    }
    
    let profileImg = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.image = UIImage(systemName: "person.fill")
        $0.backgroundColor = .white
        $0.tintColor = .black
        $0.layer.cornerRadius = 13
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        [imageView, dateLabel, localLabel, profileImg].forEach {
            contentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalTo(localLabel.snp.top).offset(-10)
        }
        
        localLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(profileImg.snp.leading).offset(-30)
        }
        
        profileImg.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
            $0.width.height.equalTo(30)
        }
    }
}
