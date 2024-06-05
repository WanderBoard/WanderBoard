//
//  InsertSpendingViewController.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 5/31/24.
//

import Foundation
import UIKit

class InsertSpendingViewController: UIViewController {
    
    var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.text = "소비내역 직접 입력"
        
        return titleLabel
    }()
    
    var dateButton: UIButton = {
        var dateButton = UIButton()
        dateButton.backgroundColor = .lightGray
        dateButton.layer.cornerRadius = 8
        dateButton.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        
        
        return dateButton
    }()
    
    var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        return datePicker
    }()
    
    let dateTextField: UITextField = {
        let textField = UITextField()
        textField.isHidden = true
        
        return textField
    }()
    
   
//    {
//
//        datePicker.addTarget(self, action: #selector(chooseDate), for: .valueChanged)
//        insertedDateLabel.text = dateFormat(date: )
//        dateButton.inputView = datePicker
//    }
    
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white

        setupDatePicker()
        configureUI()
        makeConstraints()
        
    }
    
    
    func setupDatePicker() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        
        toolBar.setItems([doneButton], animated: true)
        
        dateTextField.inputAccessoryView = toolBar
        dateTextField.inputView = datePicker
    }
    
    @objc func showDatePicker() {
        
        dateTextField.becomeFirstResponder()
    }
    
    @objc func donePressed() {
        insertedDateLabel.text = dateFormat(date: datePicker.date)
        dateButton.resignFirstResponder()
    }
    
    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        
        return formatter.string(from: date)
    }
    
    func configureUI() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(dateButton)
        dateButton.addSubview(dateText)
        dateButton.addSubview(dateTextField)
        dateButton.addSubview(insertedDateLabel)
        dateButton.addSubview(calendarImage)
//        self.view.addSubview(datePicker)
        self.view.addSubview(contentView)
        contentView.addSubview(contentText)
        contentView.addSubview(contentTextField)
        self.view.addSubview(expenseAmountView)
        expenseAmountView.addSubview(expenseAmountText)
        expenseAmountView.addSubview(expenseAmountTextField)


    }
    
    
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
        
//        datePicker.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(200)
//        }
//        
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
        
        
        
    }
    
    
    
}
