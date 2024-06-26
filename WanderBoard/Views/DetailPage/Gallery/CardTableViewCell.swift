//
//  CardTableViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 6/26/24.
//

import UIKit

enum Category: String, CaseIterable {
    case food = "식비"
    case transportation = "교통비"
    case entertainment = "문화생활비"
    case gift = "기념품비"
    case accommodation = "숙박비"
    case other = "기타"
}

class CardTableViewCell: UITableViewCell {
    static let identifier = "CardTableViewCell"
    
    let categoryTitle = UILabel().then {
        $0.textColor = .font
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textAlignment = .left
    }
    
    var expendLabel = UILabel().then {
        $0.textColor = .font
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textAlignment = .right
    }
    
    var category: Category? {
        didSet {
            setupUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        setupUI()
        constraintLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        guard let category = category else { return }
        categoryTitle.text = category.rawValue
    }
    
    func constraintLayout() {
        contentView.addSubview(categoryTitle)
        contentView.addSubview(expendLabel)
        
        categoryTitle.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(10)
            $0.right.equalTo(expendLabel.snp.left).offset(50)
        }
        expendLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-10)
        }
    }
}
