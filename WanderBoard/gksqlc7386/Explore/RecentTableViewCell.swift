//
//  RecentTableViewCell.swift
//  WanderBoard
//
//  Created by Luz on 6/6/24.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    static let identifier = String(describing: RecentTableViewCell.self)
    
    let recentLabel = UILabel().then {
        $0.text = "Recent"
        $0.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    lazy var recentCollectionView = UICollectionView(frame: .zero, collectionViewLayout: recentCollectionViewLayout).then {
        $0.dataSource = self
        $0.delegate = self
                
        $0.register(RecentCollectionViewCell.self, forCellWithReuseIdentifier: RecentCollectionViewCell.identifier)
        $0.isScrollEnabled = false
    }
    
    let recentCollectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 10
        $0.sectionInset = .init(top: 0, left: 30, bottom: 0, right: 30)
        
        let screenWidth = UIScreen.main.bounds.width
        let inset: CGFloat = 30
        let spacing: CGFloat = 10
        let numberOfItemsPerRow: CGFloat = 2
            
        let itemWidth = (screenWidth - 2 * inset - (numberOfItemsPerRow - 1) * spacing) / numberOfItemsPerRow
        let itemHeight = itemWidth * 110 / 160
            
        $0.itemSize = CGSize(width: itemWidth, height: itemHeight)
        print("Item size: \($0.itemSize)") // 아이템 크기 로그
    }

    var itemCount: Int = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        [recentLabel, recentCollectionView].forEach {
            contentView.addSubview($0)
        }
        
        recentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().inset(30)
        }
        
        recentCollectionView.snp.makeConstraints {
            $0.top.equalTo(recentLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func updateItemCount(_ count: Int) {
        itemCount = count
        recentCollectionView.reloadData()
        layoutIfNeeded()
    }
    
    func calculateCollectionViewHeight() -> CGFloat {
        let layout = recentCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let rows = ceil(CGFloat(itemCount) / 2.0)
        let height = (rows * layout.itemSize.height) + ((rows - 1) * layout.minimumLineSpacing) + layout.sectionInset.top + layout.sectionInset.bottom + 80 // 80은 레이블과 컬렉션 뷰의 여백 합계
        print("Calculated collection view height: \(height)")
        return height
    }
}

extension RecentTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCollectionViewCell.identifier, for: indexPath) as! RecentCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": true])
    }
}
