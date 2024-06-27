//
//  TextCollectionViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 6/25/24.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: TextCollectionViewCell.self)
    
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
    }
    
    let textLabel = UILabel().then(){
        $0.textColor = .font
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.numberOfLines = 0
    }
    
    let stackView = UIStackView().then(){
        $0.axis = .vertical
        $0.spacing = 16
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
            $0.width.equalTo(imageView.snp.height).multipliedBy(330.0 / 445.0)
            $0.centerX.equalToSuperview()
        }
        
        backView.snp.makeConstraints(){
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(backView.snp.height).multipliedBy(330.0 / 445.0)
            $0.centerX.equalToSuperview()
        }
        
        stackView.snp.makeConstraints(){
            $0.centerY.equalTo(backView)
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
    
    func configure(with image: UIImage?, title: String, content: String) {
        imageView.image = image
        titleLabel.text = title

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center

        let attributedString = NSAttributedString(string: content, attributes: [
            .font: textLabel.font ?? UIFont.systemFont(ofSize: 15),
            .paragraphStyle: paragraphStyle
        ])

        textLabel.attributedText = attributedString
    }
}
