//
//  CardCollectionViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 6/25/24.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: CardCollectionViewCell.self)
    
    let cardImage = UIImageView().then {
        $0.image = UIImage(named: "card")
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    let subTitleLabel = UILabel().then {
        $0.text = "총 지출 금액"
        $0.textColor = .darkgray
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textAlignment = .left
    }
    
    let expendLabel = UILabel().then {
        $0.textColor = UIColor(named: "textColor")
        $0.font = UIFont.systemFont(ofSize: 34)
        $0.textAlignment = .left
        $0.text = "190,000 원"
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }
    let tableView = UITableView().then(){
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
    }
    let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 1
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraint()
        
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: CardTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraint() {
        
        [cardImage, stackView, tableView].forEach(){
            contentView.addSubview($0)
        }
        
        [subTitleLabel, expendLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        cardImage.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(26)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(cardImage.snp.top).offset(100)
            $0.bottom.equalTo(cardImage.snp.bottom).inset(30)
            $0.left.right.equalTo(cardImage).inset(32)
        }
        
        tableView.snp.makeConstraints(){
            $0.top.equalTo(cardImage.snp.bottom).offset(16)
            $0.left.right.equalTo(cardImage)
            $0.bottom.equalToSuperview()
        }
    }
}

extension CardCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Category.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTableViewCell.identifier, for: indexPath) as? CardTableViewCell else {
            return UITableViewCell()
        }
        
        let categories: [Category] = Category.allCases
                let category = categories[indexPath.row]
                
                cell.category = category
                cell.expendLabel.text = "10000 원"
                
                cell.selectionStyle = .none
                return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    
}
