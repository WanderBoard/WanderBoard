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
    
    let profileImg = UIImageView().then {
        $0.image = UIImage(systemName: "pesron")
        $0.backgroundColor = .white
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.isHidden = true
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
        blackView.addSubview(profileImg)
        
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
            $0.leading.equalTo(stackView.snp.trailing).offset(20)
            $0.trailing.equalTo(contentView.snp.trailing).inset(30)
            $0.bottom.equalTo(contentView.snp.bottom).inset(30)
        }
        
        profileImg.snp.makeConstraints{
            $0.width.height.equalTo(30)
            $0.leading.equalTo(stackView.snp.trailing).offset(20)
            $0.trailing.equalTo(contentView.snp.trailing).inset(30)
            $0.bottom.equalTo(contentView.snp.bottom).inset(30)
        }
    }
    
    func updateProfileImageVisibility(for filterIndex: Int) {
        self.profileImg.isHidden = filterIndex == 0
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
        
        // 프로필 이미지 로드
        FirestoreManager.shared.fetchUserProfileImageURL(userId: tripLog.authorId) { [weak self] photoURL in
            if let photoURL = photoURL, let url = URL(string: photoURL) {
                self?.loadImage(from: url) { image in
                    DispatchQueue.main.async {
                        self?.profileImg.image = image
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.profileImg.image = UIImage(systemName: "person.circle")
                }
            }
        }
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
