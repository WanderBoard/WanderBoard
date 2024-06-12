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
    
    private let blackView = UIImageView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.4)
        $0.layer.cornerRadius = 25
    }
    
    let titleLabel = UILabel().then{
        $0.text = "Croatia"
        let screenWidth = UIScreen.main.bounds.width
        $0.font = .systemFont(ofSize: 28)
        $0.textColor = .white
        $0.textAlignment = .left
        $0.numberOfLines = 2
    }
    
    let subTitle = UILabel().then{
        $0.text = "Summer 2017 - 14 days"
        let screenWidth = UIScreen.main.bounds.width
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .white
        $0.textAlignment = .left
    }
    
    let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.distribution = .fill
        $0.alignment = .leading
    }
    
    let privateButton = UIButton().then {
        $0.setImage(UIImage(systemName: "lock.fill"), for: .normal)
        $0.tintColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        contentView.addSubview(bgImage)
        bgImage.addSubview(blackView)
        
        blackView.addSubview(stackView)
        blackView.addSubview(privateButton)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitle)
        
        bgImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        blackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    
        stackView.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).offset(30)
            $0.bottom.equalTo(contentView.snp.bottom).inset(30)
        }
        
        privateButton.snp.makeConstraints{
            $0.leading.equalTo(stackView.snp.trailing).offset(30)
            $0.trailing.equalTo(contentView.snp.trailing).inset(30)
            $0.bottom.equalTo(contentView.snp.bottom).inset(30)
        }
    }
    
    func configure(with tripLog: PinLog) {
        if let imageUrl = tripLog.media.first(where: { $0.isRepresentative })?.url ?? tripLog.media.first?.url, let url = URL(string: imageUrl) {
            bgImage.kf.setImage(with: url)
        } else {
            bgImage.image = UIImage(systemName: "photo")
        }
        
        titleLabel.text = tripLog.location
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.string(from: tripLog.startDate)
        let endDate = dateFormatter.string(from: tripLog.endDate)
        let duration = Calendar.current.dateComponents([.day], from: tripLog.startDate, to: tripLog.endDate).day ?? 0
        subTitle.text = "\(startDate) - \(endDate) \(duration) days"
        
        privateButton.isHidden = tripLog.isPublic
    }
}
