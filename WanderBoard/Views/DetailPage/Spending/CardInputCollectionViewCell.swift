//
//  CardInputCollectionViewCell.swift
//  WanderBoard
//
//  Created by 김시종 on 6/26/24.
//

import UIKit

class CardInputCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: CardInputCollectionViewCell.self)
    
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
        $0.text = "--- 원"
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
    
    let emptyView = UIView().then {
        $0.backgroundColor = .systemBackground.withAlphaComponent(0.9)
        $0.isHidden = true
        $0.isUserInteractionEnabled = true
    }
    
    let emptyImageView = UIImageView().then {
        $0.image = UIImage(named: "emptyImg")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .black
    }
    
    let emptyTitleLabel = UILabel().then {
        $0.text = "기록된 지출 내용이 없습니다."
        $0.textColor = .font
        $0.font = UIFont.boldSystemFont(ofSize: 17)
        $0.textAlignment = .center
    }
    
    var sortedExpenses: [Expense] = []
    
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
        [cardImage, tableView, emptyView].forEach {
            contentView.addSubview($0)
        }
        
        cardImage.addSubview(titleLabel)
        cardImage.addSubview(stackView)
        
        stackView.addArrangedSubview(subTitleLabel)
        stackView.addArrangedSubview(expendLabel)
        
        emptyView.addSubview(emptyImageView)
        emptyView.addSubview(emptyTitleLabel)
        
        cardImage.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.centerX.equalTo(contentView.snp.centerX)
            $0.width.equalTo(contentView.snp.width).multipliedBy(0.75)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(cardImage.snp.top).offset(47)
            $0.right.equalTo(cardImage).inset(50)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(cardImage.snp.top).offset(100)
            $0.bottom.equalTo(cardImage.snp.bottom).inset(32)
            $0.left.right.equalTo(cardImage).inset(32)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(cardImage.snp.bottom).offset(16)
            $0.left.right.equalTo(contentView).inset(32)
            $0.bottom.equalTo(contentView.snp.bottom)
        }
        
        emptyView.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }
        
        emptyImageView.snp.makeConstraints {
            $0.centerX.equalTo(contentView)
            $0.centerY.equalTo(contentView).offset(-20)
            $0.height.equalTo(35)
            $0.width.equalTo(55)
        }
        
        emptyTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(10)
            $0.centerX.equalTo(contentView)
        }
    }
    
    func configure(with expenses: [DailyExpenses]) {
        let flattenedExpenses = expenses.flatMap { $0.expenses }
        
        let groupedExpenses = Dictionary(grouping: flattenedExpenses, by: { $0.category })
        
        var combinedExpenses: [Expense] = []
        for (category, expenses) in groupedExpenses {
            let totalAmount = expenses.reduce(0) { $0 + $1.expenseAmount }
            if let firstExpense = expenses.first {
                let combinedExpense = Expense(
                    id: firstExpense.id,
                    date: firstExpense.date,
                    expenseContent: firstExpense.expenseContent,
                    expenseAmount: totalAmount,
                    category: category,
                    memo: firstExpense.memo,
                    imageName: firstExpense.imageName
                )
                combinedExpenses.append(combinedExpense)
            }
        }
        
        self.sortedExpenses = combinedExpenses.sorted { $0.expenseAmount > $1.expenseAmount }
        self.tableView.reloadData()
        self.updateTotalExpenditure()
        
        emptyView.isHidden = !sortedExpenses.isEmpty
        tableView.isHidden = sortedExpenses.isEmpty
    }
    
    func updateTotalExpenditure() {
        let total = sortedExpenses.reduce(0) { $0 + $1.expenseAmount }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedTotal = formatter.string(from: NSNumber(value: total)) ?? "0"
        expendLabel.text = "\(formattedTotal) 원"
    }
}

extension CardInputCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTableViewCell.identifier, for: indexPath) as? CardTableViewCell else {
            return UITableViewCell()
        }
        let expense = sortedExpenses[indexPath.row]
        cell.setExpenseAmount(expense.expenseAmount, category: expense.category)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
