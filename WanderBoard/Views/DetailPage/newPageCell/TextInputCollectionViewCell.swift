//
//  TextInputCollectionViewCell.swift
//  WanderBoard
//
//  Created by 김시종 on 6/26/24.
//

import UIKit
import SnapKit
import Then

class TextInputCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: TextInputCollectionViewCell.self)
    
    lazy var titleTextField = UITextField().then {
        $0.delegate = self
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.borderStyle = .none
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = UIColor.darkgray.cgColor
        $0.autocapitalizationType = .none
        $0.returnKeyType = .next
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftView = paddingView
        $0.rightView = paddingView
        $0.leftViewMode = .always
        $0.rightViewMode = .always
        
        // 플레이스홀더 텍스트 색상 설정
        $0.attributedPlaceholder = NSAttributedString(
            string: "제목을 입력하세요",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightgray]
        )
    }
    
    lazy var contentTextView = UITextView().then {
        $0.delegate = self
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
        $0.layer.borderColor = UIColor.darkgray.cgColor
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        $0.textContainer.lineFragmentPadding = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        $0.typingAttributes = [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: paragraphStyle
        ]
    }
    
    let placeholderLabel = UILabel().then {
        $0.text = "내용을 입력하세요"
        $0.textColor = .lightgray
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraint() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(contentTextView)
        
        contentView.addSubview(placeholderLabel)
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.horizontalEdges.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().inset(5)
        }
        
        titleTextField.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.top).offset(contentTextView.textContainerInset.top)
            $0.leading.equalTo(contentTextView.snp.leading).offset(contentTextView.textContainerInset.left)
            $0.height.equalTo(14)
        }
        placeholderLabel.isHidden = !contentTextView.text.isEmpty
    }
    
    private func provideHapticFeedback() {
        print("Haptic feedback triggered")
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

extension TextInputCollectionViewCell: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let newText = currentText.replacingCharacters(in: range, with: text)
        if newText.count <= 220 {
            return true
        } else {
            provideHapticFeedback()
            return false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholderLabel.isHidden = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else { return true }
        let newText = currentText.replacingCharacters(in: range, with: string)
        if newText.count <= 26 { //공백 포함 26자
            return true
        } else {
            provideHapticFeedback()
            return false
        }
    }
}
