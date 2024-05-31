//
//  TripCollectionViewCell.swift
//  Wanderboard
//
//  Created by Luz on 5/28/24.
//

import UIKit
import Then
import SnapKit

class MyTripsCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: MyTripsCollectionViewCell.self)
    
    let bgImage = UIImageView().then {
        $0.image = UIImage(systemName: "photo")
        $0.tintColor = .black
        $0.backgroundColor = .black
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 25
    }
    
    let weatherIcon = UIImageView().then {
        let screenWidth = UIScreen.main.bounds.width
        let iconSize = screenWidth * 0.1
        let imageConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .regular)
        $0.image = UIImage(systemName: "sun.min", withConfiguration: imageConfig)
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    let titleLable = UILabel().then{
        $0.text = "Croatia"
        let screenWidth = UIScreen.main.bounds.width
        let fontSize = screenWidth * 0.075
        $0.font = .systemFont(ofSize: fontSize)
        $0.textColor = .white
        $0.textAlignment = .left
    }
    
    let subTitle = UILabel().then{
        $0.text = "Summer 2017 - 14 days"
        let screenWidth = UIScreen.main.bounds.width
        let fontSize = screenWidth * 0.04
        $0.font = .systemFont(ofSize: fontSize)
        $0.textColor = .white
        $0.textAlignment = .left
    }
    
    let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.distribution = .fill
        $0.alignment = .leading
    }
    
    let profileStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = -20
        $0.distribution = .fillEqually
        $0.alignment = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private var images = (0...2).map { _ in
        UIImage(systemName: "person.circle.fill")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
        setProfiles()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        
        [bgImage, stackView, profileStackView].forEach{
            contentView.addSubview($0)
        }
        
        [weatherIcon, titleLable, subTitle].forEach{
            stackView.addArrangedSubview($0)
        }
        
        bgImage.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        let topMarginRatio: CGFloat = 0.06
        let bottomMarginRatio: CGFloat = 0.03

        let screenHeight = UIScreen.main.bounds.height
        let topMargin = screenHeight * topMarginRatio
        let bottomMargin = screenHeight * bottomMarginRatio
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(topMargin)
            $0.leading.equalTo(contentView.snp.leading).offset(36)
            $0.trailing.equalTo(profileStackView.snp.leading).offset(-10)
            $0.bottom.equalTo(contentView.snp.bottom).inset(bottomMargin)
        }
        
        profileStackView.snp.makeConstraints {
            $0.leading.equalTo(stackView.snp.trailing).offset(10)
            $0.trailing.equalTo(contentView.snp.trailing).inset(20)
            $0.bottom.equalTo(contentView.snp.bottom).inset(bottomMargin)
        }
    }
    
    private let color = UIColor.black
    
    private func setProfiles() {
        let imageViews = images.enumerated().map { index, image in
            let imageView = UIImageView(image: image)
            imageView.image = image
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.backgroundColor = .white
            imageView.layer.cornerRadius = 15.5
            imageView.layer.borderColor = color.cgColor
            imageView.layer.borderWidth = 0.1
            imageView.tintColor = .white
            imageView.snp.makeConstraints {
                $0.width.height.equalTo(31)
            }
            imageView.layer.zPosition = CGFloat(-index)
            return imageView
        }
        imageViews.forEach(profileStackView.addArrangedSubview(_:))
    }
}
