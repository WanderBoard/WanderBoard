//
//  FilterCollectionViewCell.swift
//  WanderBoard
//
//  Created by Luz on 6/3/24.
//

import UIKit
import SnapKit
import Then

class FilterCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: FilterCollectionViewCell.self)
    
    let filterButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitleColor(.darkgray, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        $0.layer.cornerRadius = 12
        $0.layer.borderColor = UIColor.babygray.cgColor
        $0.layer.borderWidth = 1
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(filterButton)
        filterButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        updateColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        let lineColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "babygray")
        filterButton.layer.borderColor = lineColor?.cgColor
    }
}
