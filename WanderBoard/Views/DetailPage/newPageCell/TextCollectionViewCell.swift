//
//  TextCollectionViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 6/25/24.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
    let backView = UIView().then(){
        $0.backgroundColor = UIColor(white: 1, alpha: 0.9)
        $0.layer.cornerRadius = 30
    }
    let titleLabel = UILabel().then(){
        $0.textColor = .font
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.textAlignment = .center
    }
    let textLabel = UILabel().then(){
        $0.textColor = .font
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textAlignment = .center
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
        self.contentView.addSubview(backView)
        backView.addSubview(stackView)
        [titleLabel, textLabel].forEach(){
            stackView.addArrangedSubview($0)
        }
        
        backView.snp.makeConstraints(){
            $0.centerX.equalToSuperview()
            $0.width.equalTo(329)
            $0.height.equalTo(474)
            $0.top.equalToSuperview()
        }
        
        stackView.snp.makeConstraints(){
            $0.center.equalTo(backView)
            $0.horizontalEdges.equalTo(backView).inset(16)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        let backColor = traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0, alpha: 0.9) : UIColor(white: 1, alpha: 0.9)
        backView.backgroundColor = backColor
        
    }
    
}
