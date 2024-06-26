//
//  TextInputCollectionViewCell.swift
//  WanderBoard
//
//  Created by 김시종 on 6/26/24.
//

import UIKit

class TextInputCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: TextInputCollectionViewCell.self)
    
    let imageView = UIImageView().then() {
        $0.image = UIImage(systemName: "photo")
        $0.backgroundColor = .blue
        $0.layer.cornerRadius = 30
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    let backView = UIView().then(){
        $0.backgroundColor = UIColor(white: 1, alpha: 0.9)
        $0.layer.cornerRadius = 30
    }
    let titleLabel = UILabel().then(){
        $0.textColor = .font
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.textAlignment = .center
        $0.text = "테스트 문구"
    }
    let textLabel = UILabel().then(){
        $0.textColor = .font
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textAlignment = .center
        $0.text = "테스트 문구"
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
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(backView)
        backView.addSubview(stackView)
        [titleLabel, textLabel].forEach(){
            stackView.addArrangedSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(imageView.snp.height).multipliedBy(330.0 / 440.0)
            $0.centerX.equalToSuperview()
        }
        
        backView.snp.makeConstraints(){
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(backView.snp.height).multipliedBy(330.0 / 440.0)
            $0.centerX.equalToSuperview()
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
