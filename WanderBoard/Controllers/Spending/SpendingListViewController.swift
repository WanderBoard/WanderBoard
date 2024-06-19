//
//  ViewController.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 5/28/24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class SpendingListViewController: UIViewController {
    var pinLog: PinLog?
    var shouldShowEditButton: Bool = true
    
    // MARK: Components
    var dailyExpenses: [DailyExpenses] = []
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(handleBackButtonTapped))
        return button
    }()
    
    lazy var penButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(handlePenButtonTapped))
        return button
    }()
    
    lazy var spendingCardbutton: UIButton = {
        let spendingCardbutton = UIButton()
        spendingCardbutton.backgroundColor = .black
        spendingCardbutton.layer.cornerRadius = 25
        
        return spendingCardbutton
    }()
    
    lazy var totalSpendingText: UILabel = {
        let totalSpendingText = UILabel()
        totalSpendingText.text = "총 지출 금액"
        totalSpendingText.font = UIFont.systemFont(ofSize: 15)
        totalSpendingText.textColor = .white //나중에 878787로 변경
        
        return totalSpendingText
    }()
    
    lazy var totalSpendingAmount: UILabel = {
        let totalSpendingAmount = UILabel()
        totalSpendingAmount.adjustsFontSizeToFitWidth = true
        totalSpendingAmount.text = ""
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
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    lazy var spendingEmptyView: SpendingEmptyView = {
        let spendingEmptyView = SpendingEmptyView()
        spendingEmptyView.delegate = self
        spendingEmptyView.isHidden = true
        
        return spendingEmptyView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureUI()
        makeConstraints()
        updateTotalSpendingAmount()
        
        if let pinLog = pinLog {
            dailyExpenses = pinLog.expenses ?? []
            updateTotalSpendingAmount()
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SpendingTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SpendingTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: SpendingTableViewHeaderView.identifier)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewExpenseData(_:)), name: .newExpenseData, object: nil)
        
        updateView()
        tableView.reloadData()
        
        // 네비게이션 바 아이템 설정
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = penButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        
        navigationController?.navigationBar.tintColor = .black
        
        
//        if shouldShowEditButton {
//            navigationItem.rightBarButtonItem = penButton
//        } else {
//            navigationItem.rightBarButtonItem = nil
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = navigationController,
           navigationController.viewControllers.contains(where: { $0 is DetailViewController }) {
            navigationItem.rightBarButtonItem = penButton
        }
    }
    
    func loadExpensesFromFirestore() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let pinLogRef = db.collection("pinLogs").document(userId)
        
        pinLogRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let expensesData = document.data()?["expenses"] as? [[String: Any]] {
                    self.dailyExpenses = self.parseExpenses(expensesData)
                    self.updateView()
                    self.tableView.reloadData()
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func parseExpenses(_ expensesData: [[String: Any]]) -> [DailyExpenses] {
        var dailyExpenses: [DailyExpenses] = []
        
        for data in expensesData {
            guard let timestamp = data["date"] as? Timestamp else { continue }
            let date = timestamp.dateValue()
            let expenseContent = data["expenseContent"] as? String ?? ""
            let expenseAmount = data["expenseAmount"] as? Int ?? 0
            let category = data["category"] as? String ?? ""
            let memo = data["memo"] as? String ?? ""
            let imageName = data["imageName"] as? String ?? ""
            
            let expense = Expense(
                date: date,
                expenseContent: expenseContent,
                expenseAmount: expenseAmount,
                category: category,
                memo: memo,
                imageName: imageName
            )
            
            if let index = dailyExpenses.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                dailyExpenses[index].expenses.append(expense)
            } else {
                let newDailyExpense = DailyExpenses(date: date, expenses: [expense])
                dailyExpenses.append(newDailyExpense)
            }
        }
        
        return dailyExpenses
    }
    
    private func updateView() {
        if dailyExpenses.isEmpty {
            tableView.isHidden = true
            spendingEmptyView.isHidden = false
            penButton.isHidden = true
//            penButton.isEnabled = false
        } else {
            tableView.isHidden = false
            spendingEmptyView.isHidden = true
            penButton.isHidden = false
//            penButton.isEnabled = true
        }
        tableView.reloadData()
    }
    
    @objc func handleBackButtonTapped() {
        if let navigationController = navigationController {
            if let detailInputVC = navigationController.viewControllers.first(where: { $0 is DetailInputViewController }) as? DetailInputViewController {
                if let totalSpendingText = totalSpendingAmount.text, !totalSpendingText.isEmpty, totalSpendingText != "0원" {
                    detailInputVC.totalSpendingAmountText = totalSpendingText
                }
                detailInputVC.expenses = dailyExpenses
            }
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handlePenButtonTapped() {
        let inputVC = InsertSpendingViewController()
        inputVC.delegate = self
        inputVC.modalPresentationStyle = .automatic
        self.present(inputVC, animated: true, completion: nil)
    }
    
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
        updateTotalSpendingAmount()
        updateView()
    }
    
    func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
    
    func sortDailyExpensesByDate() {
        dailyExpenses.sort { $0.date > $1.date }
    }
    
    func configureUI() {
        self.view.addSubview(spendingCardbutton)
        spendingCardbutton.addSubview(totalSpendingText)
        spendingCardbutton.addSubview(totalSpendingAmount)
        self.view.addSubview(tableView)
        self.view.addSubview(spendingEmptyView)
    }
    
    func makeConstraints() {
        spendingCardbutton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.height.equalTo(203)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(25)
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
        
        spendingEmptyView.snp.makeConstraints {
            $0.top.equalTo(spendingCardbutton.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func updateHeaderView(forSection section: Int, withDeletedExpense deletedExpense: Expense) {
        guard section < dailyExpenses.count else { return }
        var dailyTotalAmount: Int = 0
        
        for expense in dailyExpenses[section].expenses {
            dailyTotalAmount += expense.expenseAmount
        }
        
        if let headerView = tableView.headerView(forSection: section) as? SpendingTableViewHeaderView {
            headerView.configure(with: dailyExpenses[section].date, dailyTotalAmount: dailyTotalAmount)
        }
        updateTotalSpendingAmount()
        
        if dailyExpenses[section].expenses.isEmpty {
            tableView.deleteSections(IndexSet(integer: section), with: UITableView.RowAnimation.fade)
            updateTotalSpendingAmount()
        }
    }
    
    func updateTotalSpendingAmount() {
        var totalAmount: Int = 0
        
        for dailyExpense in dailyExpenses {
            for expense in dailyExpense.expenses {
                totalAmount += expense.expenseAmount
            }
        }
        
        totalSpendingAmount.text = "\(formatCurrency(totalAmount))원"
    }
    
    func totalExpensesAmount() -> Int {
        return dailyExpenses.flatMap { $0.expenses }.reduce(0) { $0 + $1.expenseAmount }
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
        cell.memo.numberOfLines = 2
        cell.expenseAmount.text = "\(formatCurrency(expense.expenseAmount))원"
        cell.categoryImageView.image = UIImage(systemName: expense.imageName)
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: TableViewDelegate
extension SpendingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SpendingTableViewHeaderView.identifier) as? SpendingTableViewHeaderView else {
            return nil
        }
        
        var dailyTotalAmount: Int = 0
        
        for i in dailyExpenses[section].expenses {
            dailyTotalAmount += i.expenseAmount
        }
        
        header.configure(with: dailyExpenses[section].date, dailyTotalAmount: dailyTotalAmount)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "수정") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            let insertVC = InsertSpendingViewController()
            insertVC.modalPresentationStyle = .automatic
            insertVC.expenseToEdit = self.dailyExpenses[indexPath.section].expenses[indexPath.row]
            insertVC.editingIndexPath = indexPath
            insertVC.delegate = self
            self.present(insertVC, animated: true, completion: nil)
            
            success(true)
        }
        
        edit.backgroundColor = .systemBlue
        
        let delete = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            let deletedExpense = self.dailyExpenses[indexPath.section].expenses.remove(at: indexPath.row)
            
            if self.dailyExpenses[indexPath.section].expenses.isEmpty {
                self.dailyExpenses.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                self.updateTotalSpendingAmount()
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            self.updateHeaderView(forSection: indexPath.section, withDeletedExpense: deletedExpense)
            
            success(true)
        }
        
        delete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}

extension SpendingListViewController: SpendingEmptyViewDelegate {
    func didTapAddButton() {
        penButton.isEnabled = true
        let inputVC = InsertSpendingViewController()
        inputVC.delegate = self
        inputVC.modalPresentationStyle = .automatic
        self.present(inputVC, animated: true, completion: nil)
    }
}

// MARK: InsertSpendingViewControllerDelegate
extension SpendingListViewController: InsertSpendingViewControllerDelegate {
    func didUpdateExpense(_ expense: Expense, at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            dailyExpenses[indexPath.section].expenses[indexPath.row] = expense
            tableView.reloadRows(at: [indexPath], with: .automatic)
            updateHeaderView(forSection: indexPath.section, withDeletedExpense: expense)
        } else {
            NotificationCenter.default.post(name: .newExpenseData, object: nil, userInfo: ["expense": expense])
        }
        updateTotalSpendingAmount()
        tableView.reloadData()
        updateView()
    }
}
