//
//  TableViewHeaderView.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 6/3/24.
//

import Foundation
import UIKit

class SpendingTableViewHeaderView: UITableViewHeaderFooterView {
    static let identifier = "SpendingTableViewHeaderView"
    
    let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = UIFont.boldSystemFont(ofSize: 17)
        dateLabel.textColor = .black
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        return dateLabel
    }()
    
    let dailyTotalAmountLabel: UILabel = {
        let dailyTotalAmountLabel = UILabel()
        dailyTotalAmountLabel.font = UIFont.systemFont(ofSize: 15)
        dailyTotalAmountLabel.textColor = .black
        dailyTotalAmountLabel.textAlignment = .right
        return dailyTotalAmountLabel
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .lightGray
        
        configureUI()
        makeConstraints()
        
    }
    
    func configureUI() {
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(dailyTotalAmountLabel)
        
    }
    
    func makeConstraints() {
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide).inset(19)
            $0.leading.equalTo(contentView.safeAreaLayoutGuide).inset(32)
        }
        
        
        dailyTotalAmountLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide).inset(19)
            $0.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(32)
            
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with date: Date, dailyTotalAmount: Double) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = dateFormatter.string(from: date)
        dailyTotalAmountLabel.text = String(format: "%.2f 원", dailyTotalAmount)
    }
  
}
