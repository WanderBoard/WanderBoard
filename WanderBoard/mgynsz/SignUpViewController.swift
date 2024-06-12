//
//  SignUpViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/7/24.
//

import UIKit
import PhotosUI
import SnapKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, PHPickerViewControllerDelegate, UITextFieldDelegate {
    
    private let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 설정"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()

        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "person.fill", withConfiguration: configuration)
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.contentMode = .center
        imageView.tintColor = UIColor(named: "ButtonColor")
        imageView.isUserInteractionEnabled = true
//        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.layer.cornerRadius = 50
        imageView.layer.borderColor = UIColor(named: "ButtonColor")?.cgColor
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
     private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = " 닉네임을 입력하세요"
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.layer.borderColor = UIColor.black.cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 45))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        return textField
    }()
    
    private let nicknameHintLabel: UILabel = {
        let label = UILabel()
        label.text = "*2글자 이상, 16글자 이하, 공백과 특수문자 불가."
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .darkgray
        return label
    }()
    
    private let duplicateCheckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("중복확인", for: .normal)
//        button.backgroundColor = .orange
//        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true

        return button
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    private lazy var genderButtons: [UIButton] = {
        let titles = ["남성", "여성", "선택안함"]
        return titles.map { title in
            var configuration = UIButton.Configuration.filled()
            configuration.title = title
            configuration.baseBackgroundColor = title == "선택안함" ? .black : .babygray
            configuration.baseForegroundColor = title == "선택안함" ? .white : .black
            configuration.cornerStyle = .capsule

            let button = UIButton(configuration: configuration, primaryAction: nil)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            button.isSelected = title == "선택안함"
            button.configurationUpdateHandler = { button in
                var updatedConfiguration = button.configuration
                updatedConfiguration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                if button.isSelected {
                    updatedConfiguration?.baseBackgroundColor = .black
                    updatedConfiguration?.baseForegroundColor = .white
                } else {
                    updatedConfiguration?.baseBackgroundColor = .babygray
                    updatedConfiguration?.baseForegroundColor = .black
                }
                button.configuration = updatedConfiguration
            }
            return button
        }
    }()

    private let interestsLabel: UILabel = {
        let label = UILabel()
        label.text = "관심 여행지"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    private let interestsTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = " #관심 여행지를 입력해보세요"
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.layer.borderColor = UIColor.black.cgColor
        textField.isUserInteractionEnabled = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 45))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private let tagScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let tagContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let privacyCheckBox: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "square")
        configuration.imagePadding = 8
        configuration.baseForegroundColor = .black

        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.isEnabled = false
        
        let titleText = NSMutableAttributedString(
            string: " 개인정보 수집 및 이용",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
        )
        
        let mandatoryText = NSAttributedString(
            string: "(필수)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
        )
        
        titleText.append(mandatoryText)
        button.setAttributedTitle(titleText, for: .normal)
        
        button.configurationUpdateHandler = { button in
            let image = button.isSelected ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
            var updatedConfiguration = button.configuration
            updatedConfiguration?.image = image
            button.configuration = updatedConfiguration
        }

        return button
    }()

    private let privacyPolicyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인하기 ＞", for: .normal)
        button.titleLabel?.font.withSize(10)
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
//        button.backgroundColor = .black
//        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var selectedImage: UIImage?
    private var gender: String = "선택안함"
    private var interests: [String] = []
    private var isProfileComplete: Bool = false
    private var interestTags: [String] = []
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        checkProfileCompletion()
        interestsTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        interestsTextField.addTarget(self, action: #selector(interestsTextFieldDidChange(_:)), for: .editingChanged)
        updateDuplicateCheckButtonState()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let keyboardTop = self.view.frame.height - keyboardHeight
            let activeTextFieldBottom = activeTextField?.frame.maxY ?? 0
            
            if activeTextFieldBottom > keyboardTop {
                let offset = activeTextFieldBottom - keyboardTop + 70 // 키보드 위? 텍스트 필드 높이? 위치? 조정!!
                self.view.frame.origin.y = -offset
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if textField == interestsTextField, textField.text?.isEmpty ?? true {
            textField.text = "#"
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if activeTextField == textField {
            activeTextField = nil
            self.view.frame.origin.y = 0 // 스크롤 된 상태에서 상단 텍스트필드 다시 터치하면 뷰 원래 위치로 내려주는!
        }
    }
    
    private func setupViews() {
        
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = .babygray
        
        view.addSubview(topBar)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(profileImageView)
        view.addSubview(nickNameLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(nicknameHintLabel)
        view.addSubview(duplicateCheckButton)
        view.addSubview(genderLabel)
        genderButtons.forEach { view.addSubview($0) }
        view.addSubview(interestsLabel)
        view.addSubview(interestsTextField)
        view.addSubview(tagScrollView)
        tagScrollView.addSubview(tagContainerView)
        view.addSubview(privacyCheckBox)
        view.addSubview(privacyPolicyButton)
        view.addSubview(signUpButton)
        
        topBar.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(30)
            make.left.equalToSuperview().inset(34)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nickNameLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().inset(30)
            make.right.equalTo(duplicateCheckButton.snp.left).offset(-10)
            make.height.equalTo(43)
        }
        
        
        duplicateCheckButton.snp.makeConstraints { make in
            make.centerY.equalTo(nicknameTextField.snp.centerY)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(45)
            make.width.equalTo(100)
        }
        
        nicknameHintLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            make.left.equalToSuperview().inset(34)
        }
        
        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameHintLabel.snp.bottom).offset(50)
            make.left.equalToSuperview().inset(34)
        }
        
        var lastButton: UIButton?
        for (index, button) in genderButtons.enumerated() {
            view.addSubview(button)
            button.snp.makeConstraints { make in
                if index == 0 {
                    make.left.equalTo(genderLabel.snp.right).offset(36)
                    make.centerY.equalTo(genderLabel.snp.centerY)
                } else {
                    make.left.equalTo(lastButton!.snp.right).offset(10)
                    make.centerY.equalTo(genderLabel.snp.centerY)
                }
                if index == genderButtons.count - 1 {
                    make.right.equalToSuperview().inset(30)
                }
                make.height.equalTo(45)
            }
            lastButton = button
            button.addTarget(self, action: #selector(selectGender(_:)), for: .touchUpInside)
        }
        
        interestsLabel.snp.makeConstraints { make in
            make.top.equalTo(lastButton!.snp.bottom).offset(40)
            make.left.equalToSuperview().inset(34)
        }
        
        interestsTextField.snp.makeConstraints { make in
            make.top.equalTo(interestsLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().inset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(43)
        }
        
        tagScrollView.snp.makeConstraints { make in
            make.top.equalTo(interestsTextField.snp.bottom).offset(16)
            make.left.equalToSuperview()//.inset(30)
            make.right.equalToSuperview()//.inset(30)
            make.height.equalTo(50)
        }
        
        tagContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview() // tagScrollView의 높이에 맞춤
            make.left.equalToSuperview()
        }

        privacyCheckBox.snp.makeConstraints { make in
            make.bottom.equalTo(signUpButton.snp.top).offset(-20)
            make.left.equalToSuperview().inset(30)
        }
        
        privacyPolicyButton.snp.makeConstraints { make in
            make.bottom.equalTo(signUpButton.snp.top).offset(-20)
            make.right.equalToSuperview().inset(30)
        }
        
        signUpButton.snp.makeConstraints { make in
//            make.top.equalTo(privacyCheckBox.snp.bottom).offset(20)
            make.left.equalToSuperview().inset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(48)
        }
        
        privacyCheckBox.addTarget(self, action: #selector(privacyPolicyTapped), for: .touchUpInside)
        privacyPolicyButton.addTarget(self, action: #selector(privacyPolicyTapped), for: .touchUpInside)
        duplicateCheckButton.addTarget(self, action: #selector(duplicateCheckTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
    }
    
    private func checkProfileCompletion() {
        if let uid = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    self.isProfileComplete = data?["isProfileComplete"] as? Bool ?? false
                    if self.isProfileComplete {
                        self.switchToPageViewController()
                    }
                }
            }
        }
    }
    
    @objc private func profileImageTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let image = image as? UIImage else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = image
                self.selectedImage = image
            }
        }
    }
    
    @objc private func duplicateCheckTapped() {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            showAlert(title: "😗", message: "닉네임을 입력해주세요. \n입력하신 닉네임은 다른 사용자에게 노출됩니다.🤭")
            return
        }
        
        // 특수문자 검증
        let nicknamePattern = "^[a-zA-Z0-9가-힣]+$"
        let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknamePattern)
        if !nicknamePredicate.evaluate(with: nickname) {
            showAlert(title: "🤬", message: "닉네임에 특수문자를 포함할 수 없습니다.")
            return
        }
        
        Task {
            do {
                let isDuplicate = try await FirestoreManager.shared.checkDisplayNameExists(displayName: nickname)
                if isDuplicate {
                    showAlert(title: "😱", message: "아쉽네요. 다른 사용자가 먼저 등록했어요")
                } else {
                    showConfirmationAlert(title: "😁\n\(nickname)", message: "당신만의 멋진 닉네임이네요. \n이 닉네임을 사용하시겠습니까?", nickname: nickname)
                }
            } catch {
                showAlert(title: "😵‍💫", message: "닉네임 확인 중 오류가 발생했습니다: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: 관심여행지 관련 메서드
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateSignUpButtonState()
        updateDuplicateCheckButtonState()
    }

    @objc private func interestsTextFieldDidChange(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.hasPrefix("#"), isValidInterest(text) {
            addInterestTag(text)
            textField.text = "#"
        }
        textField.becomeFirstResponder() // 커서 유지
        return true
    }
    
    private func isValidInterest(_ text: String) -> Bool {
        let pattern = "^#[a-zA-Z0-9가-힣]+$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }
    
    private func addInterestTag(_ text: String) {
        let tagLabel = UILabel()
        tagLabel.text = text
        tagLabel.font = UIFont.systemFont(ofSize: 14)
        tagLabel.textColor = .white
        tagLabel.backgroundColor = .black
        tagLabel.layer.cornerRadius = 10
        tagLabel.clipsToBounds = true
        tagLabel.textAlignment = .center
        tagLabel.sizeToFit()
        let tagWidth = tagLabel.frame.width + 16

        tagLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(tagWidth)
        }

        tagContainerView.addSubview(tagLabel)

        let previousTagLabel = tagContainerView.subviews.dropLast().last
        tagLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            if let previous = previousTagLabel {
                make.left.equalTo(previous.snp.right).offset(8)
            } else {
                make.left.equalToSuperview().inset(30)
            }
        }

        tagContainerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.right.equalTo(tagLabel.snp.right).offset(8)
        }

        interestTags.append(text)
        updateSignUpButtonState()

        // Scroll to the added tag
        tagScrollView.layoutIfNeeded()
        let contentWidth = tagContainerView.frame.width
        let offsetX = max(contentWidth - tagScrollView.bounds.width, 0)
        tagScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }

    
    private func updateDuplicateCheckButtonState() {
        let nicknameLength = nicknameTextField.text?.count ?? 0
        let isValidLength = nicknameLength >= 2 && nicknameLength <= 16
        duplicateCheckButton.isEnabled = isValidLength
        duplicateCheckButton.backgroundColor = isValidLength ? .black : .babygray
        duplicateCheckButton.setTitleColor(isValidLength ? .white : .black, for: .normal)

    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }

    // 확인 및 취소
    private func showConfirmationAlert(title: String, message: String, nickname: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let useAction = UIAlertAction(title: "사용", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.nicknameTextField.isEnabled = false
            self.duplicateCheckButton.isEnabled = false
            self.duplicateCheckButton.backgroundColor = UIColor(named: "babygray")
            self.updateSignUpButtonState()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.nicknameTextField.text = ""
            self.nicknameTextField.isEnabled = true
            self.duplicateCheckButton.isEnabled = true
            self.duplicateCheckButton.backgroundColor = .babygray // 원래 색상으로 변경
            self.nicknameTextField.textColor = .black
        }
        
        alert.addAction(useAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func selectGender(_ sender: UIButton) {
        genderButtons.forEach { $0.isSelected = false }
        sender.isSelected = true
    }
    
    @objc private func privacyPolicyTapped() {
        let privacyVC = PrivacyPolicyViewController()
        privacyVC.completionHandler = { [weak self] in
            guard let self = self else { return }
            self.privacyCheckBox.isSelected = true
            self.updateSignUpButtonState()
        }
        privacyVC.modalPresentationStyle = .formSheet
        present(privacyVC, animated: true, completion: nil)
    }
    
    private func updateSignUpButtonState() {
        let isFormValid = nicknameTextField.isEnabled == false && privacyCheckBox.isSelected
        signUpButton.isEnabled = isFormValid
        signUpButton.backgroundColor = isFormValid ? .black : .babygray
        signUpButton.setTitleColor(isFormValid ? .white : .black, for: .normal )
    }
    
    @objc private func signUpTapped() {
        guard signUpButton.isEnabled else { return }
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            showAlert(title: "🧐", message: "닉네임을 입력하세요.")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let storageRef = Storage.storage().reference().child("profileImages/\(uid).jpg")
        
        let imageData: Data
        
        if let selectedImage = selectedImage {
            imageData = selectedImage.jpegData(compressionQuality: 0.75)!
        } else {
            let defaultImage = UIImage(systemName: "person.circle")!
            imageData = defaultImage.jpegData(compressionQuality: 0.75)!
        }
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading profile image: \(error)")
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                Firestore.firestore().collection("users").document(uid).updateData([
                    "displayName": nickname,
                    "photoURL": downloadURL.absoluteString,
                    "gender": self.gender,
                    "interests": self.interestTags,
                    "isProfileComplete": true,
                    "isLoggedIn": true
                ]) { error in
                    if let error = error {
                        print("Error updating user data: \(error)")
                        return
                    }
                    self.switchToPageViewController()
                }
            }
        }
    }
    
    private func switchToPageViewController() {
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            window.rootViewController = PageViewController()
            window.makeKeyAndVisible()
        }
    }
}

extension SignUpViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == interestsTextField {
            let regex = "^#\\w*$" // 유효한 입력은 #으로 시작하고 문자나 숫자가 뒤따름
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            return predicate.evaluate(with: updatedText)
        }
        
        return true
    }
}

extension UIViewController {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
