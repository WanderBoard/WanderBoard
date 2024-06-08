//
//  RecentCollectionViewCell.swift
//  WanderBoard
//
//  Created by Luz on 6/3/24.
//

import UIKit

class RecentCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: RecentCollectionViewCell.self)
    
    private let backImg = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.image = UIImage(systemName: "photo")
        $0.backgroundColor = .black
        $0.tintColor = .black
    }
    
    private let blackView = UIImageView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.4)
        $0.layer.cornerRadius = 20
    }
    
    private let dateView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1
        $0.clipsToBounds = true
    }
        
    private let dateLabel = UILabel().then {
        $0.text = "2024.06"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 10)
        $0.textAlignment = .center
    }
    
    private let localLabel = UILabel().then {
        $0.text = "제주도"
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        contentView.addSubview(backImg)
        backImg.addSubview(blackView)
        
        blackView.addSubview(dateView)
        dateView.addSubview(dateLabel)
        
        blackView.addSubview(stackView)
        stackView.addArrangedSubview(dateView)
        stackView.addArrangedSubview(localLabel)
        
        backImg.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        blackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(4)
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }

    func configure() {
    }
}
