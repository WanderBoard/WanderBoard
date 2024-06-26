//
//  RecentTableViewCell.swift
//  WanderBoard
//
//  Created by Luz on 6/6/24.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    static let identifier = String(describing: RecentTableViewCell.self)
    
    weak var delegate: RecentTableViewCellDelegate?
    
    var logCount: Int = 0
    var recentLogs: [PinLogSummary] = []
    var isLoadingMoreLogs = false
    
    let recentLabel = UILabel().then {
        $0.text = "Recent"
        $0.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    lazy var recentCollectionView = UICollectionView(frame: .zero, collectionViewLayout: recentCollectionViewLayout).then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(RecentCollectionViewCell.self, forCellWithReuseIdentifier: RecentCollectionViewCell.identifier)
        $0.isScrollEnabled = true
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    let recentCollectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 16
        $0.sectionInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        
        let screenWidth = UIScreen.main.bounds.width
        let inset: CGFloat = 30
        let spacing: CGFloat = 10
        let numberOfItemsPerRow: CGFloat = 2
        
        let itemWidth = (screenWidth - 2 * inset - (numberOfItemsPerRow - 1) * spacing) / numberOfItemsPerRow
        let itemHeight = itemWidth * 117 / 170
        
        $0.itemSize = CGSize(width: itemWidth, height: itemHeight)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        contentView.addSubview(recentLabel)
        contentView.addSubview(recentCollectionView)
        
        recentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().inset(48)
            $0.trailing.equalToSuperview().inset(32)
        }
        
        recentCollectionView.snp.makeConstraints {
            $0.top.equalTo(recentLabel.snp.bottom).offset(15)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func updateItemCount(_ count: Int) {
        logCount = count
        recentCollectionView.reloadData()
        layoutIfNeeded()
    }

    func configure(with logs: [PinLogSummary]) {
        recentLogs = logs
        logCount = logs.count
        recentCollectionView.reloadData()
    }
    
    func calculateCollectionViewHeight() -> CGFloat {
        let layout = recentCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let rows = ceil(CGFloat(logCount) / 2.0)
        let height = (rows * layout.itemSize.height) + ((rows - 1) * layout.minimumLineSpacing) + layout.sectionInset.top + layout.sectionInset.bottom + 80 // 80은 레이블과 컬렉션 뷰의 여백 합계
        return height
    }
}

extension RecentTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return logCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCollectionViewCell.identifier, for: indexPath) as! RecentCollectionViewCell
        let log = recentLogs[indexPath.item]
        Task {
            await cell.configure(with: log)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.recentTableViewCell(self, didSelectItemAt: indexPath)
    }
}

protocol RecentTableViewCellDelegate: AnyObject {
    func recentTableViewCell(_ cell: RecentTableViewCell, didSelectItemAt indexPath: IndexPath)
    func loadMoreRecentLogs()
}
