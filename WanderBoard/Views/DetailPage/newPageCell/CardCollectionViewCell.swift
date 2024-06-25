//
//  CardCollectionViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 6/25/24.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    let cardImage = UIImageView().then(){
        $0.image = UIImage(named: "card")
        $0.contentMode = .scaleAspectFit
    }
    let subTitleLabel = UILabel().then(){
        $0.text = "총 지출 금액"
        $0.textColor = .darkgray
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textAlignment = .right
    }
    let expendLabel = UILabel().then(){
        $0.textColor = .font
        $0.font = UIFont.systemFont(ofSize: 40)
        $0.textAlignment = .right
    }
    let infoLabel = UILabel().then(){
        $0.text = "지출 내역 상세보기"
        $0.textColor = .darkGray
        $0.font = UIFont.boldSystemFont(ofSize: 13)
        $0.textAlignment = .right
    }
    let stackView = UIStackView().then(){
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
    
    func setupConstraint(){
        self.contentView.addSubview(cardImage)
        cardImage.addSubview(stackView)
        [subTitleLabel, expendLabel, infoLabel].forEach(){
            stackView.addArrangedSubview($0)
        }
        
        cardImage.snp.makeConstraints(){
            $0.left.equalToSuperview().offset(25)
            $0.height.equalTo(278)
            $0.top.equalToSuperview()
        }
        
        stackView.snp.makeConstraints(){
            $0.bottom.equalTo(cardImage.snp.bottom).inset(48)
            $0.horizontalEdges.equalTo(cardImage).inset(16)
        }
    }
    
}
