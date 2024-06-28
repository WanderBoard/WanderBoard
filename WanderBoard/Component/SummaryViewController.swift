//
//  SummaryViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/26/24.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

class SummaryViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var selectedCategory: String?
    var selectedDate: Date?
    var amount: Double?
    var pinLogId: String?

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
        textView.backgroundColor = .systemBackground
        
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
        button.backgroundColor = .font
        button.tintColor = UIColor(named: "textColor")
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
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
        guard let category = selectedCategory, !category.isEmpty else {
            showAlert(title: "카테고리 선택", message: "카테고리를 선택해주세요.")
            return
        }
        
        guard let date = selectedDate else {
            showAlert(title: "날짜 선택", message: "유효한 날짜를 선택해주세요.")
            return
        }
        
        guard let amount = amount, amount > 0 else {
            showAlert(title: "금액 입력", message: "유효한 금액을 입력해주세요.")
            return
        }
        
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(title: "제목 입력", message: "제목을 입력해주세요.")
            return
        }
        
        saveButton.isEnabled = false
        
        let expense = Expense(
            date: date,
            expenseContent: title,
            expenseAmount: Int(amount),
            category: category,
            memo: memoTextView.text,
            imageName: "" // 여기에 이미지 이름을 추가하거나 필요한 경우 수정
        )
        
        Task {
            do {
                if let pinLogId = pinLogId {
                    // 기존 pinLog에 Expense 추가
                    try await PinLogManager.shared.addExpenseToPinLog(pinLogId: pinLogId, expense: expense)
                } else {
                    // pinLog ID가 없는 경우 새로운 pinLog 생성 등의 로직 추가
                    // 예시: 새 pinLog 생성 후 expense 추가
                    var newPinLog = PinLog(
                        location: "새로운 위치", // 필요한 값으로 변경
                        address: "새로운 주소", // 필요한 값으로 변경
                        latitude: 0.0, // 필요한 값으로 변경
                        longitude: 0.0, // 필요한 값으로 변경
                        startDate: date,
                        endDate: date,
                        title: title,
                        content: memoTextView.text,
                        media: [],
                        authorId: Auth.auth().currentUser?.uid ?? "",
                        attendeeIds: [],
                        isPublic: true,
                        createdAt: Date(),
                        pinCount: 0,
                        pinnedBy: [],
                        totalSpendingAmount: Int(amount),
                        isSpendingPublic: true,
                        maxSpendingAmount: Int(amount),
                        expenses: [DailyExpenses(date: date, expenses: [expense])]
                    )
                    _ = try await PinLogManager.shared.createOrUpdatePinLog(pinLog: &newPinLog, images: [], imageLocations: [], isRepresentativeFlags: [])
                }
                
                saveButton.isEnabled = true
                dismiss(animated: true, completion: nil)
            } catch {
                showAlert(title: "오류", message: "데이터 저장에 실패했습니다.")
                saveButton.isEnabled = true
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true, completion: nil)
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
            textView.textColor = .darkgray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == UIColor.darkgray {
            textView.textColor = UIColor.font
            textView.text = nil
        }
    }
    
    @objc func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.darkgray {
            textView.text = nil
            textView.textColor = .font
        }
    }
    
    @objc func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Note.."
            textView.textColor = UIColor.darkgray
        }
    }
}
