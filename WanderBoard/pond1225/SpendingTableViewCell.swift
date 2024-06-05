//
//  SpendingTableViewCell.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 6/3/24.
//

import Foundation
import UIKit

class SpendingTableViewCell: UITableViewCell {
    static let identifier = "cell"
    
    let categoryImage: UIImage = {
        let categoryImage = UIImage()
        
        return categoryImage
    }()
    
    let expenseContent: UILabel = {
       let expenseContent = UILabel()
        expenseContent.font = UIFont.systemFont(ofSize: 17)
        
        return expenseContent
    }()
    
    let memo: UILabel = {
        let memo = UILabel()
        memo.font = UIFont.systemFont(ofSize: 12)
        
        return memo
    }()
    
    let expenseAmount: UILabel = {
        let expenseAmount = UILabel()
        expenseAmount.font = UIFont.systemFont(ofSize: 17)
        
        return expenseAmount
    }()
    
    
    override init(style: SpendingTableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
        makeConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        
//        contentView.addSubview(categoryImage)
        contentView.addSubview(expenseContent)
        contentView.addSubview(memo)
        contentView.addSubview(expenseAmount)
        
    }
    
    func makeConstraints() {
        
//        categoryImage.snp.makeConstraints {
//            $0.top.equalTo(SpendingTableViewHeaderView.snp.bottom).inset(20)
//            $0.leading.equalTo(contentView.safeAreaLayoutGuide).inset(29)
//        }
//        
        expenseContent.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(5)
            $0.leading.equalTo(contentView.snp.leading).offset(13.23)
        }
        
        memo.snp.makeConstraints {
            $0.top.equalTo(expenseContent.snp.bottom)
            $0.leading.equalTo(expenseContent.snp.leading)
        }
        
        expenseAmount.snp.makeConstraints {
            $0.centerY.equalTo(expenseContent)
            $0.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(20)
        }

        
    }
    
    
    
}
