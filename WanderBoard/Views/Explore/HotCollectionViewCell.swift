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
    
    //이미지 캐싱
    private static let imageCache = NSCache<NSString, UIImage>()
    
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
        $0.layer.cornerRadius = 30
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
        $0.numberOfLines = 2
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
    }
    
    private let profile = UIImageView().then {
        $0.backgroundColor = .white
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFill
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
            $0.trailing.equalTo(profile.snp.leading).offset(-5)
        }
        
        profile.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
            $0.width.height.equalTo(30)
        }
    }
    
    func configure(with hotLog: PinLog) async {
        locationLabel.text = hotLog.location
        dateLabel.text = formatDate(hotLog.startDate)
        
        // 이전 이미지를 초기화
        backImg.image = nil
        
        // 대표 이미지
        if let imageUrl = hotLog.media.first(where: { $0.isRepresentative })?.url ?? hotLog.media.first?.url, let url = URL(string: imageUrl) {
            backImg.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        } else {
            backImg.image = UIImage(systemName: "photo") // 임시 기본 이미지
        }
        
        // 프로필 사진
        if let photoURL = try? await FirestoreManager.shared.fetchUserProfileImageURL(userId: hotLog.authorId), let url = URL(string: photoURL) {
            profile.kf.setImage(with: url, placeholder: UIImage(systemName: "person.crop.circle"))
        } else {
            profile.image = UIImage(systemName: "person.crop.circle") // 기본 프로필 이미지
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
