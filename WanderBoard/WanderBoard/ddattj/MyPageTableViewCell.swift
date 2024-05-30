//
//  MyPageTableViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit

class MyPageTableViewCell: UITableViewCell {
    static let identifier = "MyPageTableViewCell"
    let icon = UIImageView()
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        constraintLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureUI(){
        
    }
    func constraintLayout(){
        
    }
}
