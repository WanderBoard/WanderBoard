//
//  HotTableViewCell.swift
//  WanderBoard
//
//  Created by Luz on 6/3/24.
//

import UIKit
import SnapKit
import Then

class HotTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: HotTableViewCell.self)
    
    let hotView = UIView().then {
        $0.backgroundColor = .white
    
        // 그림자
        $0.layer.shadowOffset = CGSize(width: 10, height: 10)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.masksToBounds = false
  
        $0.layer.cornerRadius = 30
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMinXMaxYCorner)
    }
    
    let hotLabel = UILabel().then {
        $0.text = "Hot"
        $0.font = .boldSystemFont(ofSize: 20)
    }
    
    let hotLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 20
        $0.itemSize = .init(width: 253, height: 332)
        $0.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    lazy var hotCollectionView = UICollectionView(frame: .zero, collectionViewLayout: hotLayout).then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(HotCollectionViewCell.self, forCellWithReuseIdentifier: HotCollectionViewCell.identifier)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        contentView.addSubview(hotView)
        
        hotView.addSubview(hotLabel)
        hotView.addSubview(hotCollectionView)
        
        hotView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(442)
        }
        
        hotLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(30)
        }
        
        hotCollectionView.snp.makeConstraints {
            $0.top.equalTo(hotLabel.snp.bottom)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(10)
        }
    }
}

extension HotTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotCollectionViewCell.identifier, for: indexPath) as! HotCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let itemWidth = collectionView.frame.width * 0.7
            let itemHeight = itemWidth * 336 / 256
            return CGSize(width: itemWidth, height: itemHeight)
        }
}
