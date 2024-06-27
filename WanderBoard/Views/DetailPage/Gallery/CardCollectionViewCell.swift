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
    let titleLabel = UILabel().then(){
        $0.text = "상세 지출 리스트"
        $0.textColor = UIColor(named: "PageCtrlUnselectedText2")
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textAlignment = .right
    }
    
    let subTitleLabel = UILabel().then {
        $0.text = "총 지출 금액"
        $0.textColor = .darkgray
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textAlignment = .left
    }
    
    let expendLabel = UILabel().then {
        $0.textColor = UIColor(named: "textColor")
        $0.font = UIFont.systemFont(ofSize: 28)
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
        $0.spacing = 5
        $0.alignment = .fill
        $0.distribution = .fill
    }
    //정렬된 카테고리는 카테고리 타입 배열
    var sortedCategories: [Category] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraint()
        sortCategoriesByPrice()
        
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: CardTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraint() {
        
        [cardImage, tableView].forEach(){
            contentView.addSubview($0)
        }
        cardImage.addSubview(titleLabel)
        cardImage.addSubview(stackView)
        
        [subTitleLabel, expendLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        cardImage.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.75)
        }
        titleLabel.snp.makeConstraints(){
            $0.top.equalTo(cardImage.snp.top).offset(47)
            $0.right.equalTo(cardImage).inset(50)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(cardImage.snp.top).offset(100)
            $0.bottom.equalTo(cardImage.snp.bottom).inset(32)
            $0.left.right.equalTo(cardImage).inset(32)
        }
        
        tableView.snp.makeConstraints(){
            $0.top.equalTo(cardImage.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview()
        }
    }
    //카테고리별 가격이 높은 순서로 정렬되게 하는 메서드
    func sortCategoriesByPrice() {
        sortedCategories = Category.allCases.sorted { $0.price > $1.price }
    }
}

extension CardCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTableViewCell.identifier, for: indexPath) as? CardTableViewCell else {
            return UITableViewCell()
        }
                let category = sortedCategories[indexPath.row]
                
                cell.category = category
        cell.expendLabel.text = "\(category.price) 원"
                cell.selectionStyle = .none
                return cell
    }
    //테이블뷰 높이와 들어갈 셀 수를 계산하여 셀의 높이를 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let numberOfRows = CGFloat(Category.allCases.count)
        let tableViewHieght = tableView.bounds.height
        let totalSpacing: CGFloat = -5
        let cellHieght = (tableViewHieght - totalSpacing) / numberOfRows
        return cellHieght
    }
}
