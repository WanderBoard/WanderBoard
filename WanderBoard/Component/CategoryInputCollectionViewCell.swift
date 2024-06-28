//
//  CategoryInputCollectionViewCell.swift
//  WanderBoard
//
//  Created by David Jang on 6/27/24.
//

import UIKit

protocol CategoryInputCollectionViewCellDelegate: AnyObject {
    func didSelectCategory(category: String)
}

class CategoryInputCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CategoryCollectionViewCellDelegate {

    static let identifier = "CategoryInputCollectionViewCell"

    var categories: [(String, String)] = []
    weak var delegate: CategoryInputCollectionViewCellDelegate?
    
    var extendedCategories: [(String, String)] {
        return categories + categories + categories
    }

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        scrollToMiddle()
    }

    func scrollToMiddle() {
        let middleIndexPath = IndexPath(item: categories.count, section: 0)
        collectionView.scrollToItem(at: middleIndexPath, at: .centeredHorizontally, animated: false)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return extendedCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        let category = extendedCategories[indexPath.item % categories.count] // 원래 데이터를 순환하도록 설정
        cell.configure(with: UIImage(named: category.0), name: category.1)
        cell.delegate = self
        return cell
    }

    func didTapCategoryButton(_ cell: CategoryCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let category = categories[indexPath.item % categories.count].1
            delegate?.didSelectCategory(category: category)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)

    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing

        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)

        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let middleIndex = categories.count
        let currentIndex = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
        if currentIndex == 0 {
            collectionView.scrollToItem(at: IndexPath(item: middleIndex, section: 0), at: .centeredHorizontally, animated: false)
        } else if currentIndex == extendedCategories.count - 1 {
            collectionView.scrollToItem(at: IndexPath(item: middleIndex - 1, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
}
