//
//  InsertSpendingViewController.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 5/31/24.
//

import Foundation
import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

protocol InsertSpendingViewControllerDelegate: AnyObject {
    func didUpdateExpense(_ expense: Expense, at indexPath: IndexPath?)
}

class InsertSpendingViewController: UIViewController {
    
    // MARK: Components
    var expenses: [Expense] = []
    var pinLog: PinLog?
    var expenseToEdit: Expense?
    var editingIndexPath: IndexPath?
    weak var delegate: InsertSpendingViewControllerDelegate?
    
    var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.bounces = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
    }
    
    var scrollContentView = UIView().then {
        $0.backgroundColor = UIColor(named: "textColor")
    }
    
    var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = "지출 내역 입력"
        titleLabel.textAlignment = .center
        
        return titleLabel
    }()
    
    lazy var dateButton: UIButton = {
        var dateButton = UIButton()
        dateButton.backgroundColor = .babygray
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
        textField.attributedPlaceholder = NSAttributedString(string: "지출 날짜를 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightgray])
        textField.textColor = .font
        
        return textField
    }()
    
    var dateText: UILabel = {
        var dateText = UILabel()
        dateText.text = "날짜*"
        dateText.font = UIFont.systemFont(ofSize: 13)
        dateText.textColor = .lightblack
        
        return dateText
    }()
    
    var insertedDateLabel: UILabel = {
        var insertedDateLabel = UILabel()
        insertedDateLabel.text = "yyyy.mm.dd"
        insertedDateLabel.textColor = .lightgray
        insertedDateLabel.font = UIFont.systemFont(ofSize: 17)
        
        return insertedDateLabel
    }()
    
    var calendarImage: UIImageView = {
        var calendarImage = UIImageView()
        calendarImage.image = UIImage(systemName: "calendar")
        calendarImage.tintColor = .font
        
        return calendarImage
    }()
    
    var contentView: UIView = {
        var contentView = UIView()
        contentView.backgroundColor = .babygray
        contentView.layer.cornerRadius = 8
        
        return contentView
    }()
    
    var contentText: UILabel = {
        var contentText = UILabel()
        contentText.text = "내용*"
        contentText.font = UIFont.systemFont(ofSize: 13)
        contentText.textColor = .lightblack
        
        return contentText
    }()
    
    var contentTextField: UITextField = {
        var contentTextField = UITextField()
        contentTextField.attributedPlaceholder = NSAttributedString(string: "지출 내역을 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightgray])
        contentTextField.textColor = .font
        
        return contentTextField
    }()
    
    var expenseAmountView: UIView = {
        var expenseAmountView = UIView()
        expenseAmountView.backgroundColor = .babygray
        expenseAmountView.layer.cornerRadius = 8
        
        return expenseAmountView
    }()
    
    var expenseAmountText: UILabel = {
        var expenseAmountText = UILabel()
        expenseAmountText.text = "금액*"
        expenseAmountText.font = UIFont.systemFont(ofSize: 13)
        expenseAmountText.textColor = .lightblack
        
        return expenseAmountText
    }()
    
    var expenseAmountTextField: UITextField = {
        var expenseAmountTextField = UITextField()
        expenseAmountTextField.attributedPlaceholder = NSAttributedString(string: "지출 금액을 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        expenseAmountTextField.textColor = .font
        expenseAmountTextField.keyboardType = .numberPad
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let amountDoneButton = UIBarButtonItem(title: "Done", style: .done, target: InsertSpendingViewController.self, action: #selector(amountDoneButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, amountDoneButton]
        
        expenseAmountTextField.inputAccessoryView = toolbar
        
        return expenseAmountTextField
    }()
    
    lazy var categoryButton: UIButton = {
        var categoryButton = UIButton()
        categoryButton.backgroundColor = .babygray
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
        pickerContainer.backgroundColor = .systemBackground
        return pickerContainer
    }()
    
    let categoryTextField: UITextField = {
        let categoryTextField = UITextField()
        categoryTextField.isHidden = true
        
        return categoryTextField
    }()
    
    var categoryText: UILabel = {
        var categoryText = UILabel()
        categoryText.text = "분류*"
        categoryText.font = UIFont.systemFont(ofSize: 13)
        categoryText.textColor = .lightblack
        
        return categoryText
    }()
    
    var insertedCategoryLabel: UILabel = {
        var insertedCategoryLabel = UILabel()
        insertedCategoryLabel.text = "식비 / 교통비 / 숙박비 등"
        insertedCategoryLabel.textColor = .lightgray
        insertedCategoryLabel.font = UIFont.systemFont(ofSize: 17)
        
        return insertedCategoryLabel
    }()
    
    var memoView: UIView = {
        var memoView = UIView()
        memoView.backgroundColor = .babygray
        memoView.layer.cornerRadius = 8
        
        return memoView
    }()
    
    var memoText: UILabel = {
        var memoText = UILabel()
        memoText.text = "메모"
        memoText.font = UIFont.boldSystemFont(ofSize: 13)
        memoText.textColor = .darkgray
        
        return memoText
    }()
    
    var memoTextField: UITextField = {
        var memoTextField = UITextField()
        memoTextField.attributedPlaceholder = NSAttributedString(string: "메모를 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        memoTextField.textColor = .font
        
        return memoTextField
    }()
    
    lazy var saveDoneButton: UIButton = {
        var saveDoneButton = UIButton()
        saveDoneButton.backgroundColor = .font
        saveDoneButton.setTitle("저장", for: .normal)
        saveDoneButton.setTitleColor(UIColor(named: "textColor"), for: .normal)
        saveDoneButton.setTitle("필수 값을 입력해주세요", for: .disabled)
        saveDoneButton.setTitleColor(.darkgray, for: .disabled)
        saveDoneButton.isEnabled = false
        saveDoneButton.addTarget(self, action: #selector(saveExpenseData), for: .touchUpInside)
        saveDoneButton.layer.cornerRadius = 15
        
        return saveDoneButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .systemBackground
        
        contentTextField.delegate = self
        expenseAmountTextField.delegate = self
        
        configureUI()
        makeConstraints()
        updateColor()
        setupDatePicker()
        setupCategoryPicker()
        setupKeyboard()
        
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        //베이비그레이-커스텀블랙
        let babyGTocustomB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
        dateButton.backgroundColor = babyGTocustomB
        contentView.backgroundColor = babyGTocustomB
        expenseAmountView.backgroundColor = babyGTocustomB
        categoryButton.backgroundColor = babyGTocustomB
        memoView.backgroundColor = babyGTocustomB
        
        //라이트그레이-라이트블랙
        let lightGTolightB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "lightgray")
        insertedDateLabel.textColor = lightGTolightB
        dateTextField.attributedPlaceholder = NSAttributedString(string: "지출 날짜를 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : lightGTolightB!])
        contentTextField.attributedPlaceholder = NSAttributedString(string: "지출 내역을 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : lightGTolightB!])
        expenseAmountTextField.attributedPlaceholder = NSAttributedString(string: "지출 금액을 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : lightGTolightB!])
        insertedCategoryLabel.textColor = lightGTolightB
        memoText.textColor = lightGTolightB
        memoTextField.attributedPlaceholder = NSAttributedString(string: "메모를 입력하세요", attributes: [NSAttributedString.Key.foregroundColor : lightGTolightB!])
        
        //라이트블랙-다크그레이
        let lightBTodarkG = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "darkgray") : UIColor(named: "lightblack")
        dateText.textColor = lightBTodarkG
        contentText.textColor = lightBTodarkG
        expenseAmountText.textColor = lightBTodarkG
        categoryText.textColor = lightBTodarkG
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
    
    func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        contentTextField.delegate = self
        expenseAmountTextField.delegate = self
        memoTextField.delegate = self
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let activeField = view.currentFirstResponder() as? UITextField else { return }
        
        let keyboardHeight = keyboardFrame.height
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        var visibleRect = view.frame
        visibleRect.size.height -= keyboardHeight
        
        let activeFieldFrame = activeField.convert(activeField.bounds, to: view)
        if !visibleRect.contains(activeFieldFrame.origin) {
            scrollView.scrollRectToVisible(activeFieldFrame, animated: true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: DateButton 클릭시 동작
    @objc func showDatePicker() {
        
        dateTextField.becomeFirstResponder()
    }
    
    // MARK: DatePicker Done 버튼 클릭시 동작
    @objc func donePressed() {
        insertedDateLabel.text = dateFormat(date: datePicker.date)
        insertedDateLabel.textColor = .font
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
        insertedCategoryLabel.textColor = .font
        updateDoneButtonState()
        hideCategoryPicker()
    }
    
// MARK: 금액 입력 키보드 Done 누르고 닫기
    @objc func amountDoneButtonTapped() {
        expenseAmountTextField.resignFirstResponder()
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
        
        delegate?.didUpdateExpense(expense, at: editingIndexPath)
        
        // Firestore 저장 코드 추가
        guard let pinLogId = pinLog?.id else {
            self.dismiss(animated: true)
            return
        }
        
        Task {
            do {
                try await PinLogManager.shared.addExpenseToPinLog(pinLogId: pinLogId, expense: expense)
                print("Expense successfully added to pin log")
                self.dismiss(animated: true)
                NotificationCenter.default.post(name: .newExpenseData, object: nil, userInfo: ["expense": expense])
            } catch {
                print("Error saving expense: \(error)")
                self.dismiss(animated: true)
            }
        }
    }
    
    func saveExpenseToFirestore(_ expense: Expense) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let pinLogRef = db.collection("pinLogs").document(userId)
        
        let expenseData: [String: Any] = [
            "date": Timestamp(date: expense.date),
            "expenseContent": expense.expenseContent,
            "expenseAmount": expense.expenseAmount,
            "category": expense.category,
            "memo": expense.memo,
            "imageName": expense.imageName
        ]
        
        pinLogRef.updateData([
            "expenses": FieldValue.arrayUnion([expenseData])
        ]) { error in
            if let error = error {
                print("Error saving expense: \(error)")
            } else {
                NotificationCenter.default.post(name: .newExpenseData, object: nil, userInfo: ["expense" : expense])
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: Components Set up
    func configureUI() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(titleLabel)
        
        scrollContentView.addSubview(dateButton)
        dateButton.addSubview(dateText)
        dateButton.addSubview(dateTextField)
        dateButton.addSubview(insertedDateLabel)
        dateButton.addSubview(calendarImage)
        
        scrollContentView.addSubview(contentView)
        contentView.addSubview(contentText)
        contentView.addSubview(contentTextField)
        
        scrollContentView.addSubview(expenseAmountView)
        expenseAmountView.addSubview(expenseAmountText)
        expenseAmountView.addSubview(expenseAmountTextField)
        
        scrollContentView.addSubview(categoryButton)
        categoryButton.addSubview(categoryText)
        categoryButton.addSubview(categoryTextField)
        categoryButton.addSubview(insertedCategoryLabel)
        
        scrollContentView.addSubview(memoView)
        memoView.addSubview(memoText)
        memoView.addSubview(memoTextField)
        
        scrollContentView.addSubview(saveDoneButton)
    }
    
    //MARK: Components Layout
    func makeConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollContentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(scrollContentView).offset(44)
            $0.leading.trailing.equalTo(scrollContentView)
            $0.height.equalTo(22)
        }
        
        dateButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(44)
            $0.leading.trailing.equalTo(scrollContentView).inset(50)
            $0.height.equalTo(74)
        }
        
        dateText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        
        insertedDateLabel.snp.makeConstraints {
            $0.top.equalTo(dateText.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        
        calendarImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(21)
            $0.height.width.equalTo(20)
        }
        
        categoryButton.snp.makeConstraints {
            $0.top.equalTo(dateButton.snp.bottom).offset(22)
            $0.leading.trailing.equalTo(scrollContentView).inset(50)
            $0.height.equalTo(74)
        }
        
        categoryText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        
        insertedCategoryLabel.snp.makeConstraints {
            $0.top.equalTo(categoryText.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(categoryButton.snp.bottom).offset(22)
            $0.leading.trailing.equalTo(scrollContentView).inset(50)
            $0.height.equalTo(74)
        }
        
        contentText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
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
            $0.leading.trailing.equalTo(scrollContentView).inset(50)
            $0.height.equalTo(74)
        }
        
        expenseAmountText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        
        expenseAmountTextField.snp.makeConstraints {
            $0.top.equalTo(expenseAmountText.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        
        memoView.snp.makeConstraints {
            $0.top.equalTo(expenseAmountView.snp.bottom).offset(22)
            $0.leading.trailing.equalTo(scrollContentView).inset(50)
            $0.height.equalTo(74)
        }
        memoText.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        memoTextField.snp.makeConstraints {
            $0.top.equalTo(memoText.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        saveDoneButton.snp.makeConstraints {
            $0.top.equalTo(memoView.snp.bottom).offset(60)
            $0.leading.trailing.equalTo(scrollContentView).inset(50)
            $0.height.equalTo(50)
            $0.bottom.equalTo(scrollContentView).offset(-20)
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
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let activeField = view.currentFirstResponder() as? UITextField else { return }
        let keyboardHeight = view.frame.height / 3
        let contentOffset = CGPoint(x: 0, y: activeField.frame.origin.y - keyboardHeight)
        scrollView.setContentOffset(contentOffset, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case contentTextField:
            expenseAmountTextField.becomeFirstResponder()
        case expenseAmountTextField:
            memoTextField.becomeFirstResponder()
        case memoTextField:
            memoTextField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            if let responder = subview.currentFirstResponder() {
                return responder
            }
        }
        return nil
    }
}

