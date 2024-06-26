//
//  SummaryViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/26/24.
//

import UIKit
import SnapKit

class SummaryViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var selectedCategory: String?
    var selectedDate: Date?
    var amount: Double?

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = " Title.."
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.layer.borderColor = UIColor.darkgray.cgColor
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let memoTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 10
        textView.layer.borderColor = UIColor.darkgray.cgColor
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = .babygray
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8

        let attributedString = NSAttributedString(string: "", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: paragraphStyle
        ])
        
        textView.attributedText = attributedString
        return textView
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.backgroundColor = .black
        button.tintColor = .white
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        populateData()
        
        titleTextField.delegate = self
        memoTextView.delegate = self
    }

    private func setupUI() {
        view.addSubview(categoryLabel)
        view.addSubview(dateLabel)
        view.addSubview(amountLabel)
        view.addSubview(titleTextField)
        view.addSubview(memoTextView)
        view.addSubview(saveButton)

        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        memoTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(160)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(memoTextView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        saveButton.setTitle("Save Expense", for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    private func populateData() {
        categoryLabel.text = " ✔︎ 지출 구분: \(selectedCategory ?? "")"
        if let date = selectedDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            dateLabel.text = " ✔︎ 지출 날짜: \(dateFormatter.string(from: date))"
        }
        if let amount = amount {
            amountLabel.text = " ✔︎ 지출 금액: \(Formatter.withSeparator.string(from: NSNumber(value: amount)) ?? "")"
        }
    }

    @objc private func saveButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            memoTextView.becomeFirstResponder()
        }
        return true
    }

    @objc func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Note.."
            textView.textColor = UIColor.white
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == UIColor.lightGray {
            textView.textColor = UIColor.black
            textView.text = nil
        }
    }
    
    @objc func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    @objc func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Note.."
            textView.textColor = UIColor.lightGray
        }
    }
}
