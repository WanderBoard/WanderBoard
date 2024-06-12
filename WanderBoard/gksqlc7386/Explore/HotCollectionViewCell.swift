//
//  HotCollectionViewCell.swift
//  WanderBoard
//
//  Created by Luz on 6/3/24.
//

import UIKit
import SnapKit
import Then

class HotCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: HotCollectionViewCell.self)
    
    private let backImg = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 30
        $0.image = UIImage(systemName: "photo")
        $0.backgroundColor = .black
        $0.tintColor = .black
    }
    
    private let blackView = UIImageView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.4)
        $0.layer.cornerRadius = 20
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.text = "2023.05"
    }
    
    private let locationLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.boldSystemFont(ofSize: 22)
        $0.text = "충청북도 청주시"
    }
    
    private let profile = UIImageView().then {
        $0.backgroundColor = .white
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
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
        
        [dateLabel, locationLabel, profile].forEach{
            blackView.addSubview($0)
        }
        
        backImg.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        blackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(locationLabel.snp.top).offset(-10)
        }
        
        locationLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        profile.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
            $0.width.height.equalTo(30)
        }
    }
    
    func configure(with hotLog: PinLog) {
        locationLabel.text = hotLog.location
        dateLabel.text = formatDate(hotLog.startDate)
        
        // 이전 이미지를 초기화
        backImg.image = nil
        
        // 이미지 일단 첫 번째 이미지
        if let imageUrl = hotLog.media.first?.url, let url = URL(string: imageUrl) {
            loadImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    guard self?.locationLabel.text == hotLog.location else {
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
