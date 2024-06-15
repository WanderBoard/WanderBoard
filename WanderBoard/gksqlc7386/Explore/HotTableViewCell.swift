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
    
    let hotView = UIView().then {
        $0.backgroundColor = UIColor(named: "textColor")
        
        $0.layer.shadowOffset = CGSize(width: 5, height: 5)
        $0.layer.shadowOpacity = 0.4
        $0.layer.shadowRadius = 10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.masksToBounds = false
        
        $0.layer.cornerRadius = 30
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMinXMaxYCorner)
    }
    
    let hotLabel = UILabel().then {
        $0.text = "Hot"
        $0.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    lazy var hotCollectionView = UICollectionView(frame: .zero, collectionViewLayout: hotCollectionViewLayout).then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(HotCollectionViewCell.self, forCellWithReuseIdentifier: HotCollectionViewCell.identifier)
    }
    
    let hotCollectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 20
        $0.itemSize = .init(width: 253, height: 332)
        $0.sectionInset = .init(top: 0, left: 26, bottom: 5, right: 0)
    }
    
    var hotPinLogs: [PinLog] = [] {
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
            $0.height.equalTo(442)
        }
        
        hotLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(38)
        }
        
        hotCollectionView.snp.makeConstraints {
            $0.top.equalTo(hotLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(360)
        }
    }
    
    func configure(with pinLogs: [PinLog]) {
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
        let shadowColor = traitCollection.userInterfaceStyle == .dark ? UIColor.babygray : UIColor.black
        hotView.layer.shadowColor = shadowColor.cgColor
    }
}

extension HotTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotPinLogs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotCollectionViewCell.identifier, for: indexPath) as! HotCollectionViewCell
        let hotLog = hotPinLogs[indexPath.item]
        cell.configure(with: hotLog)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.hotTableViewCell(self, didSelectItemAt: indexPath)
    }
}

protocol HotTableViewCellDelegate: AnyObject {
    func hotTableViewCell(_ cell: HotTableViewCell, didSelectItemAt indexPath: IndexPath)
}
