//
//  ViewController.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 5/28/24.
//

import UIKit
import SnapKit

class SpendingListViewController: UIViewController {
    
// MARK: Components
    var dailyExpenses: [DailyExpenses] = []
//    var tripTotalSpendingAmount = Double.self

    
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

        
        configureUI()
        makeConstraints()
        setupNavi()
  
// MARK: TableView Delegate, DataSource. Header, Cell 등록. Notification Observer
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SpendingTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SpendingTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: SpendingTableViewHeaderView.identifier)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewExpenseData(_:)), name: .newExpenseData, object: nil)

        tableView.reloadData()
    }
 
    
// MARK: InsertSpendingVC에 입력되어 전달된 데이터 받기
    @objc func didReceiveNewExpenseData(_ notification: Notification) {
        guard let expense = notification.userInfo?["expense"] as? Expense else { return }
        
        if let index = dailyExpenses.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: expense.date) }) {
            dailyExpenses[index].expenses.append(expense)
        } else {
            let newDailyExpense = DailyExpenses(date: expense.date, expenses: [expense])
            dailyExpenses.append(newDailyExpense)
        }
        
        sortDailyExpensesByDate()
        
        tableView.reloadData()
    }
    
// MARK: 천 단위 컴마 표기
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
    
// MARK: 최신날짜가 위로 오도록 TableView에 정렬
    func sortDailyExpensesByDate() {
        dailyExpenses.sort { $0.date > $1.date }
    }
  
// MARK: Components Set up
    func configureUI() {

        self.view.addSubview(spendingCardbutton)
        spendingCardbutton.addSubview(totalSpendingText)
        spendingCardbutton.addSubview(totalSpendingAmount)
        self.view.addSubview(tableView)
        
        
    }
 
//MARK: Components Layout
    func makeConstraints() {
        
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

// MARK: NavigationBar
    func setupNavi() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(insertButtonTapped))
    }

// MARK: 추가 버튼 클릭시 InsertSpendingVC 보여줌
    @objc func insertButtonTapped() {
        let insertSpendingViewController = InsertSpendingViewController()
        insertSpendingViewController.modalPresentationStyle = .automatic
        self.present(insertSpendingViewController, animated: true, completion: nil)
    }
    
    // MARK: TableViewCell Swipe Action 
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "수정") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            let insertVC = InsertSpendingViewController()
            insertVC.expenseToEdit = self.dailyExpenses[indexPath.section].expenses[indexPath.row]
            self.navigationController?.pushViewController(insertVC, animated: true)
            success(true)
        }
        
        edit.backgroundColor = .systemBlue
        
        let delete = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            
            self.dailyExpenses[indexPath.section].expenses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            success(true)
        }
        delete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
   
}


// MARK: TableViewDataSource
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
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        
        let expense = dailyExpenses[indexPath.section].expenses[indexPath.row]
        
        cell.expenseContent.text = expense.expenseContent
        cell.memo.text = expense.memo
        cell.expenseAmount.text = "\(formatCurrency(expense.expenseAmount))"
        cell.categoryImageView.image = UIImage(systemName: expense.imageName)
        
        return cell
    }
    
}

// MARK: TableViewDelegate
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
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
