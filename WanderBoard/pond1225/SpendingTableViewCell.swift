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
    
    let categoryImageView: UIImageView = {
        let categoryImageView = UIImageView()
        categoryImageView.tintColor = .lightgray
        
        return categoryImageView
    }()
    
    let expenseContent: UILabel = {
        let expenseContent = UILabel()
        expenseContent.font = UIFont.systemFont(ofSize: 17)
        
        return expenseContent
    }()
    
    let memo: UILabel = {
        let memo = UILabel()
        memo.font = UIFont.systemFont(ofSize: 12)
        memo.numberOfLines = 2
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
        
        contentView.addSubview(categoryImageView)
        contentView.addSubview(expenseContent)
        contentView.addSubview(memo)
        contentView.addSubview(expenseAmount)
        
    }
    
    func makeConstraints() {
        
        categoryImageView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).inset(8)
            $0.leading.equalTo(contentView.safeAreaLayoutGuide).inset(32)
            $0.height.width.equalTo(44)
        }
        
        expenseContent.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).inset(12)
            $0.leading.equalTo(categoryImageView.snp.trailing).offset(12)
        }
        
        memo.snp.makeConstraints {
            $0.top.equalTo(expenseContent.snp.bottom).offset(4)
            $0.leading.equalTo(expenseContent.snp.leading)
            $0.width.equalTo(195)
            $0.trailing.equalTo(expenseAmount.snp.leading)

        }
        
        expenseAmount.snp.makeConstraints {
            $0.centerY.equalTo(contentView.snp.centerY)
            $0.leading.equalTo(memo.snp.trailing).offset(12)
            $0.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(32)
        }
        
        
    }
    
    
    
}
