//
//  CategoryInputCollectionViewCell.swift
//  WanderBoard
//
//  Created by David Jang on 6/27/24.
//

import UIKit

protocol CategoryInputCollectionViewCellDelegate: AnyObject {
    func didSelectCategory(category: String, imageName: String)
}

class CategoryInputCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CategoryCollectionViewCellDelegate {
    
    weak var delegate: CategoryInputCollectionViewCellDelegate?
    
    static let identifier = "CategoryInputCollectionViewCell"
    
    var categories: [(String, String)] = []
    let aspectRatio: CGFloat = 195 / 268
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 24
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight < 750 {
            layout.sectionInset = UIEdgeInsets(top: 0, left: 110, bottom: 0, right: 110)
        } else {
            layout.sectionInset = UIEdgeInsets(top: 0, left: 96, bottom: 0, right: 96)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    let explainLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리 버튼 클릭 시 세부적인 내용을 입력할 수 있습니다."
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightgray
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let screenHeight = UIScreen.main.bounds.height
        let isSmallScreen = screenHeight < 750
        
        contentView.addSubview(collectionView)
        contentView.addSubview(explainLabel)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if isSmallScreen {
                make.top.equalToSuperview().offset(12)
                make.bottom.equalToSuperview()
            } else {
                make.top.equalToSuperview().offset(32)
                make.bottom.equalToSuperview().offset(-30)
            }
        }
        explainLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func calculateItemWidth() -> CGFloat {
        let height = collectionView.frame.height
        return height * aspectRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        let category = categories[indexPath.item]
        cell.configure(with: UIImage(named: category.0), name: category.1)
        cell.delegate = self
        return cell
    }
    
    func didTapCategoryButton(_ cell: CategoryCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let category = categories[indexPath.item % categories.count]
            // delegate?.didSelectCategory(category: category.1)
            delegate?.didSelectCategory(category: category.1, imageName: category.0)
        }
    }


    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: calculateItemWidth(), height: collectionView.bounds.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemWidth = calculateItemWidth()
        let cellWidthIncludeSpacing = itemWidth + 24
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludeSpacing
        let roundedIndex: CGFloat = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludeSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}
