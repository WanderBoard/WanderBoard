//
//  CategorySelectionViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/26/24.
//

import UIKit
import SnapKit

class CategorySelectionViewController: UIViewController, SingleDayCalendarHostingControllerDelegate, AmountInputHostingControllerDelegate {

    let categories = [
        ("food", "식사"),
        ("car", "교통"),
        ("hotel", "숙박"),
        ("gift", "선물"),
        ("entertain", "문화생활"),
        ("etc", "기타")
    ]
    var selectedCategory: String?
    var selectedDate: Date?
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(200)
        }
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        selectedCategory = categories[sender.tag].1
        showCalendar()
    }

    private func showCalendar() {
        let calendarVC = SingleDayCalendarHostingController()
        calendarVC.delegate = self
        calendarVC.modalPresentationStyle = .pageSheet
        if let sheet = calendarVC.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 460 })]
            sheet.prefersGrabberVisible = true
        }
        present(calendarVC, animated: true, completion: nil)
    }


    func didSelectDate(_ date: Date) {
        self.selectedDate = date
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let amountVC = AmountInputHostingController()
            amountVC.delegate = self
            amountVC.modalPresentationStyle = .pageSheet
            if let sheet = amountVC.sheetPresentationController {
                sheet.detents = [.custom(resolver: { _ in 460 })]
                sheet.prefersGrabberVisible = true
            }
            self.present(amountVC, animated: true, completion: nil)
        }
    }

    func didEnterAmount(_ amount: Double) {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.showSummaryViewController(withAmount: amount)
        }
    }

    private func showSummaryViewController(withAmount amount: Double) {
        let summaryVC = SummaryViewController()
        summaryVC.selectedCategory = selectedCategory
        summaryVC.selectedDate = selectedDate
        summaryVC.amount = amount
        summaryVC.modalPresentationStyle = .formSheet
        if let sheet = summaryVC.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 460 })]
            sheet.prefersGrabberVisible = true
        }
        present(summaryVC, animated: true, completion: nil)
    }
}


extension CategorySelectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as! CategoryCollectionViewCell
        let category = categories[indexPath.item]
        cell.configure(with: UIImage(named: category.0), name: category.1)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item].1
        showCalendar()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 120)
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
}
