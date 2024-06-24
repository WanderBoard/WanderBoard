//
//  HotTableViewCell.swift
//  WanderBoard
//
//  Created by Luz on 6/6/24.
//

import UIKit

class HotTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: HotTableViewCell.self)
    
    weak var delegate: HotTableViewCellDelegate?
    
    var isRefreshing = false
    var itemWidth: CGFloat = 240.0
    let minimumLineSpacing: CGFloat = 20
    
    let hotView = UIView().then {
        $0.backgroundColor = UIColor(named: "textColor")
        
        $0.layer.shadowOffset = CGSize(width: 5, height: 5)
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowRadius = 10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.masksToBounds = false
        
        $0.layer.cornerRadius = 30
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMinXMaxYCorner)
    }
    
    let hotLabel = UILabel().then {
        $0.text = "Hot"
        $0.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    lazy var hotCollectionView = UICollectionView(frame: .zero, collectionViewLayout: hotCollectionViewLayout).then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(HotCollectionViewCell.self, forCellWithReuseIdentifier: HotCollectionViewCell.identifier)
        $0.alwaysBounceHorizontal = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.alwaysBounceVertical = false
    }
    
    lazy var refreshControl = UIRefreshControl().then {
        $0.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    let hotCollectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 20
        $0.itemSize = .init(width: 240, height: 320)
        $0.sectionInset = .init(top: 10, left: 30, bottom: 5, right: 10)
    }
    
    var hotPinLogs: [PinLogSummary] = [] {
        didSet {
            hotCollectionView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupConstraints()
        updateColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        
        contentView.addSubview(hotView)
        
        [hotLabel,hotCollectionView].forEach {
            hotView.addSubview($0)
        }
        
        hotView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().inset(32)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(400)
        }
        
        hotLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.leading.equalToSuperview().inset(40)
        }
        
        hotCollectionView.snp.makeConstraints {
            $0.top.equalTo(hotLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(325)
        }
    }
    
    func configure(with pinLogs: [PinLogSummary]) {
        self.hotPinLogs = pinLogs
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // 이전 trait collection과 현재 trait collection이 다를 경우 업데이트
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        let shadowColor = traitCollection.userInterfaceStyle == .dark ? UIColor.lightgray : UIColor.black
        hotView.layer.shadowColor = shadowColor.cgColor
    }
    
    @objc func refreshData() {
        guard !isRefreshing else { return }
        isRefreshing = true
        delegate?.refreshHotData()
    }
    
    func endRefreshing() {
        isRefreshing = false
    }
}

extension HotTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotCollectionViewCell.identifier, for: indexPath) as! HotCollectionViewCell
        let hotLog = hotPinLogs[indexPath.item]
        Task {
            await cell.configure(with: hotLog)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotPinLogs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.hotTableViewCell(self, didSelectItemAt: indexPath)
    }
    
    // 페이징 기능 추가
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellWidthIncludeSpacing = itemWidth + minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludeSpacing
        let roundedIndex: CGFloat = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludeSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width
        let width = scrollView.frame.size.width
        
        if offsetX + width >= contentWidth + 100 {
            scrollView.setContentOffset(.zero, animated: true)
            refreshData()
        }
        
        // 맨 앞으로 당겼을 때 새로고침
        if offsetX <= -100 {
            scrollView.setContentOffset(.zero, animated: true)
            refreshData()
        }
    }
}

protocol HotTableViewCellDelegate: AnyObject {
    func hotTableViewCell(_ cell: HotTableViewCell, didSelectItemAt indexPath: IndexPath)
    func refreshHotData()
}
