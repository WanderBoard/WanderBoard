//
//  CardCollectionViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 6/25/24.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: CardCollectionViewCell.self)
    
    let cardImage = UIImageView().then {
        $0.image = UIImage(named: "detailViewCard")
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    let subTitleLabel = UILabel().then {
        $0.text = "총 지출 금액"
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textAlignment = .right
    }
    
    let expendLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 40, weight: .medium)
        $0.textAlignment = .right
        $0.text = "190,000 원"
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }
    
    let infoLabel = UILabel().then {
        $0.text = "지출 내역 상세보기"
        $0.textColor = .darkGray
        $0.font = UIFont.boldSystemFont(ofSize: 13)
        $0.textAlignment = .right
    }
    
    let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraint() {
        contentView.addSubview(cardImage)
        contentView.addSubview(stackView)
        
        [subTitleLabel, expendLabel, infoLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        cardImage.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(cardImage.snp.height).multipliedBy(278.0 / 474.0)
        }
        
        stackView.snp.makeConstraints {
            $0.bottom.equalTo(cardImage.snp.bottom).inset(48)
            $0.leading.equalTo(cardImage.snp.leading).inset(26)
            $0.trailing.equalTo(cardImage.snp.trailing).inset(16)
        }
    }
}

