//
//  ViewController.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 5/28/24.
//

import UIKit
import SnapKit

class SpendingListViewController: UIViewController {
    
    
    var dailyExpenses: [DailyExpenses] = []
    
    let backButton: UIButton = {
        var backButton = UIButton()
        backButton.tintColor = .black
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.addTarget(SpendingListViewController.self, action: #selector(backButtonTapped), for: .touchUpInside)
        return backButton
    }()
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    let insertButton: UIButton = {
        var insertButton = UIButton()
        insertButton.tintColor = .black
        insertButton.setImage(UIImage(systemName: "plus"), for: .normal)
        insertButton.addTarget(self, action: #selector(insertButtonTapped), for: .touchUpInside)
        return insertButton
    }()
    
    @objc func insertButtonTapped() {
        let insertSpendingViewController = InsertSpendingViewController()
        insertSpendingViewController.modalPresentationStyle = .automatic
        self.present(insertSpendingViewController, animated: true, completion: nil)
    }
    
    let spendingCardbutton: UIButton = {
        var spendingCardbutton = UIButton()
        spendingCardbutton.backgroundColor = .black // 나중에 앨범에서 선택된 사진으로 변경되도록 수정
        spendingCardbutton.layer.cornerRadius = 25
        
        return spendingCardbutton
    }()
    
    let totalSpendingText: UILabel = {
        var totalSpendingText = UILabel()
        totalSpendingText.text = "총 지출금액"
        totalSpendingText.font = UIFont.systemFont(ofSize: 15)
        totalSpendingText.textColor = .white //나중에 878787로 변경
        
        return totalSpendingText
    }()
    
    let totalSpendingAmount: UILabel = {
        var totalSpendingAmount = UILabel()
        totalSpendingAmount.adjustsFontSizeToFitWidth = true
        totalSpendingAmount.text = "₩ 100,000,000" //테이블뷰 또는 컬렉션 뷰 헤더의 금액의 합으로 변경
        totalSpendingAmount.font = UIFont.systemFont(ofSize: 34)
        totalSpendingAmount.textColor = .white
        return totalSpendingAmount
    }()
    
    lazy var labelStackView: UIStackView = {
        let labelStackView = UIStackView(arrangedSubviews: [
            UIView(),
            totalSpendingText,
            totalSpendingAmount,
            UIView()
        ])
        labelStackView.axis = .vertical
        return labelStackView
    }()
    
    var tableView : UITableView = {
        let tableView = UITableView()
        
        
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        dailyExpenses = [DailyExpenses(date: Date(), expenses: [
            Expense(date: today, expenseContent: "점심", expenseAmount: 12000, category: "식비", memo: "불고기 덮밥"),
            Expense(date: yesterday, expenseContent: "렌터카", expenseAmount: 250000, category: "교통비", memo: "2박3일 oo렌터카 렌트")
        ])]
        
        configureUI()
        makeConstraints()
        setupNavi()
        
        //        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SpendingTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SpendingTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: SpendingTableViewHeaderView.identifier)
        tableView.reloadData()
    }
    
    func configureUI() {
        self.view.addSubview(backButton)
        self.view.addSubview(insertButton)
        self.view.addSubview(spendingCardbutton)
        spendingCardbutton.addSubview(totalSpendingText)
        spendingCardbutton.addSubview(totalSpendingAmount)
        self.view.addSubview(tableView)
        
        
    }
    
    func makeConstraints() {
        
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(24.5)
            $0.height.equalTo(30)
            $0.width.equalTo(30)
            
        }
        
        insertButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(27.41)
            $0.height.equalTo(24)
            $0.width.equalTo(24)
        }
        
        spendingCardbutton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(115)
            $0.width.equalTo(344)
            $0.height.equalTo(203)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(25)
        }
        
        totalSpendingText.snp.makeConstraints {
            $0.top.equalToSuperview().inset(101.5)
            $0.leading.equalToSuperview().inset(32)
            $0.width.equalTo(74)
            $0.height.equalTo(22.11)
        }
        
        totalSpendingAmount.snp.makeConstraints {
            $0.top.equalTo(totalSpendingText.snp.bottom).offset(16.08)
            $0.leading.equalTo(spendingCardbutton.snp.leading).inset(32)
            $0.width.equalTo(171)
            $0.height.equalTo(30)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(spendingCardbutton.snp.bottom).offset(44)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
    func setupNavi() {
        navigationController?.navigationBar.tintColor = .black
    }
    
}

extension SpendingListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dailyExpenses.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyExpenses[section].expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SpendingTableViewCell else {
            return UITableViewCell()
        }
        let expense = dailyExpenses[indexPath.section].expenses[indexPath.row]
        /*cell.categoryImage =*/ //카테고리 분류 별 이미지 별도로 모델 및 asset에 저장 필요
        cell.expenseContent.text = expense.expenseContent
        cell.memo.text = expense.memo
        cell.expenseAmount.text = "\(expense.expenseAmount)원"
        
        return cell
    }
    
}

extension SpendingListViewController: UITableViewDelegate {
    func tableView(_ tablewView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tablewView.dequeueReusableHeaderFooterView(withIdentifier: SpendingTableViewHeaderView.identifier) as? SpendingTableViewHeaderView else {
            return nil
        }
        
        var dailyTotalAmount: Double = 0.0
        
        for i in dailyExpenses[section].expenses {
            dailyTotalAmount += i.expenseAmount
            
        }
        
        header.configure(with: dailyExpenses[section].date, dailyTotalAmount: dailyTotalAmount)
        
        return header
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 59
    }
    
}
