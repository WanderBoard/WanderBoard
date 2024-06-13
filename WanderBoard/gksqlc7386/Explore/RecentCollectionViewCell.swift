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
        $0.backgroundColor = UIColor(named: "textColor")
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
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 10)
        $0.textAlignment = .center
    }
    
    private let localLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 5
        $0.distribution = .fill
        $0.alignment = .center
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
        
        blackView.addSubview(stackView)
        dateView.addSubview(dateLabel)
        
        stackView.addArrangedSubview(dateView)
        stackView.addArrangedSubview(localLabel)
        
        backImg.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        blackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dateView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
        }
        
        dateLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
    }
    
    func configure(with recentLog: PinLog) {
        localLabel.text = recentLog.location
        dateLabel.text = formatDate(recentLog.startDate)
        
        // 이전 이미지를 초기화
        backImg.image = nil
        
        // 이미지 일단 첫 번째 이미지
        if let imageUrl = recentLog.media.first?.url, let url = URL(string: imageUrl) {
            loadImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    guard self?.localLabel.text == recentLog.location else {
                        return
                    }
                    self?.backImg.image = image
                }
            }
        } else {
            backImg.image = UIImage(systemName: "photo") // 임시 기본 이미지
        }
    }
    
    private func formatDate(_ date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM"
        return dateFormatter.string(from: date)
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
