//
//  InsertSpendingViewController.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 5/31/24.
//

import Foundation
import UIKit
import SnapKit

protocol InsertspendingviewcontrollerDelegate: AnyObject {
    func didUpdateExpense(_ expense: Expense, at indextPath: IndexPath)
}

class InsertSpendingViewController: UIViewController {
   
// MARK: Components
    var expenses: [Expense] = []
    var expenseToEdit: Expense?
    var editingIndexPath: IndexPath?
    weak var delegate: InsertspendingviewcontrollerDelegate?
    
    var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.text = "소비내역 직접 입력"
        
        return titleLabel
    }()
    
    lazy var dateButton: UIButton = {
        var dateButton = UIButton()
        dateButton.backgroundColor = .lightGray
        dateButton.layer.cornerRadius = 8
        dateButton.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)

        return dateButton
    }()
    
    var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        
        return datePicker
    }()
    
    let dateTextField: UITextField = {
        let textField = UITextField()
        textField.isHidden = true
        
        return textField
    }()
    
    
    var dateText: UILabel = {
        var dateText = UILabel()
        dateText.backgroundColor = .lightGray
        dateText.text = "Date"
        dateText.font = UIFont.systemFont(ofSize: 13)
        dateText.textColor = .gray
        
        return dateText
    }()
    
    var insertedDateLabel: UILabel = {
        var insertedDateLabel = UILabel()
        insertedDateLabel.backgroundColor = .lightGray
        insertedDateLabel.text = ""
        insertedDateLabel.font = UIFont.systemFont(ofSize: 17)
        
        return insertedDateLabel
    }()
    
    var calendarImage: UIImageView = {
        var calendarImage = UIImageView()
        calendarImage.image = UIImage(systemName: "calendar")
        calendarImage.tintColor = .black
        
        return calendarImage
    }()
    
    var contentView: UIView = {
        var contentView = UIView()
        contentView.backgroundColor = .lightGray
        contentView.layer.cornerRadius = 8
        
        return contentView
    }()
    
    var contentText: UILabel = {
        var contentText = UILabel()
        
        contentText.backgroundColor = .lightGray
        contentText.text = "Content"
        contentText.font = UIFont.systemFont(ofSize: 13)
        contentText.textColor = .gray
        
        return contentText
    }()
    
    var contentTextField: UITextField = {
        var contentTextField = UITextField()
        contentTextField.backgroundColor = .lightGray
        contentTextField.attributedPlaceholder = NSAttributedString(string: "소비 내역을 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        
        return contentTextField
    }()
    
    var expenseAmountView: UIView = {
        var expenseAmountView = UIView()
        expenseAmountView.backgroundColor = .lightGray
        expenseAmountView.layer.cornerRadius = 8
        
        return expenseAmountView
    }()
    
    var expenseAmountText: UILabel = {
        var expenseAmountText = UILabel()
        
        expenseAmountText.backgroundColor = .lightGray
        expenseAmountText.text = "Amount of Expense"
        expenseAmountText.font = UIFont.systemFont(ofSize: 13)
        expenseAmountText.textColor = .gray
        
        return expenseAmountText
    }()
    
    var expenseAmountTextField: UITextField = {
        var expenseAmountTextField = UITextField()
        expenseAmountTextField.backgroundColor = .lightGray
        expenseAmountTextField.attributedPlaceholder = NSAttributedString(string: "소비 금액을 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        
        return expenseAmountTextField
    }()
    
    lazy var categoryButton: UIButton = {
        var categoryButton = UIButton()
        categoryButton.backgroundColor = .lightGray
        categoryButton.layer.cornerRadius = 8
        categoryButton.addTarget(self, action: #selector(showCategoryPicker), for: .touchUpInside)
        
        return categoryButton
    }()
    
    
    let categories = ["식비", "교통비", "문화생활비", "기념품비", "숙박비", "기타"]
    let categoryImageMapping: [String: String] = [
        "식비": "fork.knife.circle",
        "교통비": "car.circle",
        "문화생활비": "theatermasks.circle",
        "기념품비": "gift.circle",
        "숙박비": "bed.double.circle",
        "기타": "ellipsis.circle"
    ]
    
    var toolbar: UIToolbar?
    var categoryPicker: UIPickerView = {
        let categoryPicker = UIPickerView()
        
        return categoryPicker
    }()
    
    var pickerContainer: UIView =  {
       var pickerContainer = UIView()
        pickerContainer.backgroundColor = .white
        return pickerContainer
    }()
    
    let categoryTextField: UITextField = {
        let categoryTextField = UITextField()
        categoryTextField.isHidden = true
        
        return categoryTextField
    }()
    
    var categoryText: UILabel = {
        var categoryText = UILabel()
        
        categoryText.backgroundColor = .lightGray
        categoryText.text = "Category"
        categoryText.font = UIFont.systemFont(ofSize: 13)
        categoryText.textColor = .gray
        
        return categoryText
    }()
    
    var insertedCategoryLabel: UILabel = {
        var insertedCategoryLabel = UILabel()
        insertedCategoryLabel.backgroundColor = .lightGray
        insertedCategoryLabel.text = ""
        insertedCategoryLabel.font = UIFont.systemFont(ofSize: 17)
        
        return insertedCategoryLabel
    }()
    
    
    var memoView: UIView = {
        var memoView = UIView()
        memoView.backgroundColor = .lightGray
        memoView.layer.cornerRadius = 8
        
        return memoView
    }()
    
    var memoText: UILabel = {
        var memoText = UILabel()
        
        memoText.backgroundColor = .lightGray
        memoText.text = "Memo"
        memoText.font = UIFont.systemFont(ofSize: 13)
        memoText.textColor = .gray
        
        return memoText
    }()
    
    var memoTextField: UITextField = {
        var memoTextField = UITextField()
        memoTextField.backgroundColor = .lightGray
        memoTextField.attributedPlaceholder = NSAttributedString(string: "메모를 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        
        return memoTextField
    }()
    
    lazy var saveDoneButton: UIButton = {
        var saveDoneButton = UIButton()
        saveDoneButton.backgroundColor = .black
        saveDoneButton.setTitle("Done", for: .normal)
        saveDoneButton.setTitleColor(.white, for: .normal)
        saveDoneButton.setTitle("Please fill in", for: .disabled)
        saveDoneButton.setTitleColor(.gray, for: .disabled)
        saveDoneButton.isEnabled = false
        saveDoneButton.addTarget(self, action: #selector(saveExpenseData), for: .touchUpInside)
        saveDoneButton.layer.cornerRadius = 15
        
        return saveDoneButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        contentTextField.delegate = self
        expenseAmountTextField.delegate = self
        
        configureUI()
        makeConstraints()
        setupDatePicker()
        setupCategoryPicker()
        
        if let expense = expenseToEdit {
            datePicker.date = expense.date
            insertedDateLabel.text = dateFormat(date: expense.date)
            contentTextField.text = expense.expenseContent
            expenseAmountTextField.text = String(expense.expenseAmount)
            insertedCategoryLabel.text = expense.category
            memoTextField.text = expense.memo
        }
        
        updateDoneButtonState()
        
        

    }
    
// MARK: DatePicker 구성
    
    func setupDatePicker() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        dateTextField.inputAccessoryView = toolBar
        dateTextField.inputView = datePicker
    }
    
// MARK: DateButton 클릭시 동작
    @objc func showDatePicker() {
        
        dateTextField.becomeFirstResponder()
    }
    
// MARK: DatePicker Done 버튼 클릭시 동작
    @objc func donePressed() {
        insertedDateLabel.text = dateFormat(date: datePicker.date)
        updateDoneButtonState()
        dateTextField.resignFirstResponder()
    }
    
    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        
        return formatter.string(from: date)
    }
  
// MARK: CategoryPicker 구성
    func setupCategoryPicker() {
        toolbar = UIToolbar()
        toolbar?.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePickingCategory))
        toolbar?.setItems([flexibleSpace, doneButton], animated: true)
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        pickerContainer.addSubview(toolbar!)
        pickerContainer.addSubview(categoryPicker)
        
        toolbar!.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        categoryPicker.snp.makeConstraints {
            $0.top.equalTo(toolbar!.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        pickerContainer.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300)
      
        view.addSubview(pickerContainer)
    }
    
// MARK: CategoryButton 클릭시 CategoryPicker 보여줌
    @objc func showCategoryPicker() {
        
        UIView.animate(withDuration: 0.3) {
            self.pickerContainer.frame = CGRect(x: 0, y: self.view.frame.height - 300, width: self.view.frame.width, height: 300)

        }
    }
 
//MARK: CategoryPicker Done 버튼 클릭시 동작
    @objc func donePickingCategory() {
        let selectedRow = categoryPicker.selectedRow(inComponent: 0)
        insertedCategoryLabel.text = categories[selectedRow]
        updateDoneButtonState()
        hideCategoryPicker()
    }

//MARK: 필수입력값 입력 완료시 저장Done버튼 활성화
    func updateDoneButtonState() {
        let isDateSet = !(insertedDateLabel.text?.isEmpty ?? true)
        let isContentSet = !(contentTextField.text?.isEmpty ?? true)
                let isAmountSet = !(expenseAmountTextField.text?.isEmpty ?? true) && Int(expenseAmountTextField.text ?? "") != nil
                let isCategorySet = !(insertedCategoryLabel.text?.isEmpty ?? true)
        
        saveDoneButton.isEnabled = isDateSet && isContentSet && isAmountSet && isCategorySet
    }
    
// MARK: Category선택 완료시 CategoryPicker 숨김
    func hideCategoryPicker() {
        UIView.animate(withDuration: 0.3) {
            self.pickerContainer.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 300)

        }
    }
    
    
// MARK: 저장Done 버튼 클릭시 SpendingListVC로 data 전달
    @objc func saveExpenseData() {
        guard saveDoneButton.isEnabled else { return }
        
        let content = contentTextField.text ?? ""
        let amount = expenseAmountTextField.text ?? ""
        let category = insertedCategoryLabel.text ?? ""
        let imageName = categoryImageMapping[category] ?? ""
        
            let expense = Expense(
                date: datePicker.date,
                expenseContent: content,
                expenseAmount: Int(amount) ?? 0,
                category: category,
                memo: memoTextField.text ?? "",
                imageName: imageName
            )
            
//        if let originalExpense = expenseToEdit {
//            if originalExpense == expense {
//                showAlert(title: "알림", message: "변경된 내용이 없습니다")
//                return
//            }
//        }
        if let indexPath = editingIndexPath {
            delegate?.didUpdateExpense(expense, at: indexPath)
        } else {
            NotificationCenter.default.post(name: .newExpenseData, object: nil, userInfo: ["expense" : expense])
        }
            self.dismiss(animated: true)
    }

    
// MARK: Components Set up
    func configureUI() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(dateButton)
        dateButton.addSubview(dateText)
        dateButton.addSubview(dateTextField)
        dateButton.addSubview(insertedDateLabel)
        dateButton.addSubview(calendarImage)
        self.view.addSubview(contentView)
        contentView.addSubview(contentText)
        contentView.addSubview(contentTextField)
        self.view.addSubview(expenseAmountView)
        expenseAmountView.addSubview(expenseAmountText)
        expenseAmountView.addSubview(expenseAmountTextField)
        self.view.addSubview(categoryButton)
        categoryButton.addSubview(categoryText)
        categoryButton.addSubview(categoryTextField)
        categoryButton.addSubview(insertedCategoryLabel)
        self.view.addSubview(memoView)
        memoView.addSubview(memoText)
        memoView.addSubview(memoTextField)
        self.view.addSubview(saveDoneButton)
    }
    
//MARK: Components Layout
    func makeConstraints() {
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(44)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(130)
            $0.height.equalTo(22)
            
        }
        
        dateButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(44)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(49.5)
            $0.height.equalTo(74)
            
        }
        
        dateText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10.5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            
        }
        
        insertedDateLabel.snp.makeConstraints {
            $0.top.equalTo(dateText.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            
        }
        
        calendarImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28.67)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.width.equalTo(20)
        }
               
        contentView.snp.makeConstraints {
            $0.top.equalTo(dateButton.snp.bottom).offset(22)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(49.5)
            $0.height.equalTo(74)
            
        }
        
        contentText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10.5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            
        }
        
        contentTextField.snp.makeConstraints {
            $0.top.equalTo(contentText.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            
        }
        
        expenseAmountView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom).offset(22)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(49.5)
            $0.height.equalTo(74)
            
        }
        
        expenseAmountText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10.5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            
        }
        
        expenseAmountTextField.snp.makeConstraints {
            $0.top.equalTo(expenseAmountText.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            
        }
        
        categoryButton.snp.makeConstraints {
            $0.top.equalTo(expenseAmountView.snp.bottom).offset(22)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(49.5)
            $0.height.equalTo(74)
            
        }
        
        categoryText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10.5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            
        }
        
        insertedCategoryLabel.snp.makeConstraints {
            $0.top.equalTo(categoryText.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            
        }
        
        
     
        memoView.snp.makeConstraints {
            $0.top.equalTo(categoryButton.snp.bottom).offset(22)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(49.5)
            $0.height.equalTo(74)
            
        }
        
        memoText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10.5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            
        }
        
        memoTextField.snp.makeConstraints {
            $0.top.equalTo(memoText.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            
        }
     
        saveDoneButton.snp.makeConstraints {
            $0.top.equalTo(memoView.snp.bottom).offset(59)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(49.5)
            $0.height.equalTo(50)
            
        }
        
    }
    
}


// MARK: UIPickerViewDelegate, UIPickerViewDataSource
extension InsertSpendingViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
}

// MARK: Notification name extension
extension Notification.Name {
    static let newExpenseData = Notification.Name("newExpenseData")
}

// MARK: TextFieldDelegate
extension InsertSpendingViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        updateDoneButtonState()
    }
    
}
       
//// MARK: Alert
//extension UIViewController {
//    func showAlert(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)
//    }
//}
    

