//
//  EditViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import CoreData

class EditViewController: BaseViewController, UITextFieldDelegate, PHPickerViewControllerDelegate {
    
    let doneButton = UIButton()
    let addImage = UIImageView()
    let profile = UIImageView()
    var myName = UITextField().then(){
        $0.textColor = .font
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = CGColor(gray: 0, alpha: 1)
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .clear
        $0.textAlignment = .center
        $0.clearButtonMode = .whileEditing
        $0.keyboardType = .default
        $0.returnKeyType = .done
    }
    let nameAlert = UILabel()
    var IDArea = UIView()
    var IDIcon = UIImageView()
    var myID = UILabel()
    let subLine = UIView()
    let subTitle = UILabel()
    let connectButton = UIButton()
    let iconImageView = UIImageView()
    let subLine2 = UIView()
    let withdrawalB = UIButton()
    var previousImage: UIImage?
    var previousName: String = ""
    var ID: String = ""
    var userData: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIcon()
        view.backgroundColor = .systemBackground
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(tapGestureRecognizer:)))
        profile.isUserInteractionEnabled = true
        profile.addGestureRecognizer(tapGestureRecognizer)
        
        //마이컨트롤러에 이미지가 있는지 확인. 존재하면 불러오고 없으면 회색배경에 +아이콘
        if let existingImage = previousImage {
            profile.image = existingImage
            addImage.tintColor = UIColor.clear
        } else {
            addImage.tintColor = UIColor.font
        }
    }
    
    override func configureUI(){
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.font, for: .normal)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        doneButton.addTarget(self, action: #selector(moveToMyPage), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: doneButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        addImage.image = UIImage(systemName: "plus")
        addImage.tintColor = UIColor(named: "textColorSub")
        
        profile.clipsToBounds = true
        profile.contentMode = .scaleAspectFill
        profile.layer.cornerRadius = 53
        profile.backgroundColor = .lightgray
        
        myName.placeholder = previousName
        myName.clearButtonMode = .never // x 버튼 비활성화
        myName.delegate = self
        
        IDIcon.contentMode = .scaleAspectFit
        
        nameAlert.text = "😗 글자 수를 맞춰주세요 (2자 이상, 16자 이하)"
        nameAlert.font = UIFont.systemFont(ofSize: 12)
        nameAlert.textColor = .darkgray
        
        myID.text = ID
        myID.font = UIFont.systemFont(ofSize: 13)
        myID.textColor = .font
        
        subLine.backgroundColor = .babygray
        subLine.layer.cornerRadius = 10
        
        subTitle.text = "인스타그램"
        subTitle.font = UIFont.boldSystemFont(ofSize: 15)
        subTitle.textColor = .font
        
        connectButton.backgroundColor = .clear
        connectButton.setTitle("연결하기", for: .normal)
        connectButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        connectButton.setTitleColor(.font, for: .normal)
        connectButton.setImage(UIImage(named: "instagramLogo"), for: .normal)
        if let imageView = connectButton.imageView {
            imageView.snp.makeConstraints {
                $0.width.height.equalTo(24) // 이미지 크기를 24x24로 설정
                $0.left.equalToSuperview().offset(10)
                $0.centerY.equalToSuperview()
                let label = connectButton.titleLabel
                $0.right.equalTo(label!.snp.left).offset(-10)
            }
        }
        
        iconImageView.image = UIImage(systemName: "chevron.right")
        iconImageView.tintColor = .font
        iconImageView.contentMode = .scaleAspectFit
        
        subLine2.backgroundColor = .babygray
        subLine2.layer.cornerRadius = 10
        
        withdrawalB.setTitle("회원탈퇴", for: .normal)
        withdrawalB.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        withdrawalB.setTitleColor(UIColor(named: "lightgray"), for: .normal)
        withdrawalB.addTarget(self, action: #selector(TappedWithdrawalB), for: .touchUpInside)
    }
    
    func getUserLogin() -> AuthDataResultModel? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        
        let authProvider = AuthProviderOption(rawValue: currentUser.providerData.first?.providerID ?? "") ?? .email
        return AuthDataResultModel(user: currentUser, authProvider: authProvider)
    }
    
    func setIcon() {
        let iconColor: UIColor
        if traitCollection.userInterfaceStyle == .dark {
            iconColor = UIColor(red: 254/255, green: 229/255, blue: 0, alpha: 1)
        } else {
            iconColor = UIColor(red: 60/255, green: 29/255, blue: 30/255, alpha: 1)
        }
        
        guard let userData = self.userData else {
            print("등록된 로그인 정보가 없습니다")
            return
        }
        
        switch userData.authProvider {
        case AuthProviderOption.google.rawValue:
            self.IDIcon.image = UIImage(named: "googleLogo")
        case AuthProviderOption.apple.rawValue:
            self.IDIcon.image = UIImage(named: "appleLogo")?.withTintColor(UIColor.font)
        case AuthProviderOption.kakao.rawValue:
            self.IDIcon.image = UIImage(named: "kakaoLogo")?.withRenderingMode(.alwaysTemplate)
            self.IDIcon.tintColor = iconColor
        case AuthProviderOption.email.rawValue:
            self.IDIcon.image = UIImage(named: "kakaoLogo")?.withRenderingMode(.alwaysTemplate)
            self.IDIcon.tintColor = iconColor // 이메일 로그인은 추가 안함, 카카오랑 같은 아이콘 뜨도록 설정
        default:
            print("등록된 로그인 정보가 없습니다")
        }
    }
    
    override func constraintLayout() {
        super.constraintLayout() //부모뷰의 설정을 가져온다
        [profile, addImage, myName, nameAlert, IDArea, subLine, subTitle, connectButton, subLine2, withdrawalB].forEach(){
            view.addSubview($0)
        }
        logo.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.width.equalTo(143)
            $0.height.equalTo(18.24)
            $0.bottom.equalTo(view).offset(-55)
        }
        
        profile.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.top.equalTo(view).offset(112)
            $0.width.height.equalTo(106)
        }
        
        profile.addSubview(addImage)
        addImage.snp.makeConstraints(){
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(21)
            $0.centerY.equalToSuperview()
            
        }
        
        myName.snp.makeConstraints(){
            $0.top.equalTo(profile.snp.bottom).offset(27)
            $0.horizontalEdges.equalTo(view).inset(95)
            $0.height.equalTo(44)
            $0.centerX.equalTo(view)
        }
        nameAlert.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.top.equalTo(myName.snp.bottom).offset(9)
        }
        IDArea.snp.makeConstraints(){
            $0.top.equalTo(nameAlert.snp.bottom).offset(30)
            $0.centerX.equalTo(view)
            $0.width.lessThanOrEqualTo(view).inset(30)
        }
        IDArea.addSubview(myID)
        IDArea.addSubview(IDIcon)
        IDIcon.snp.makeConstraints(){
            $0.left.equalTo(IDArea)
            $0.centerY.equalTo(IDArea)
            $0.width.height.equalTo(22)
        }
        myID.snp.makeConstraints(){
            $0.centerY.equalTo(IDArea)
            $0.left.equalTo(IDIcon.snp.right).offset(10)
            $0.right.equalTo(IDArea)
        }
        subLine.snp.makeConstraints(){
            $0.left.right.equalTo(view).inset(16)
            $0.height.equalTo(1)
            $0.top.equalTo(IDIcon.snp.bottom).offset(15)
        }
        subTitle.snp.makeConstraints(){
            $0.top.equalTo(subLine.snp.bottom).offset(25)
            $0.left.equalTo(subLine.snp.left).offset(16)
        }
        connectButton.snp.makeConstraints(){
            $0.centerY.equalTo(subTitle)
            $0.right.equalTo(subLine.snp.right).inset(16)
            $0.width.equalTo(121)
            $0.height.equalTo(44)
        }
        connectButton.addSubview(iconImageView)
        iconImageView.snp.makeConstraints(){
            $0.left.equalTo(connectButton.titleLabel!.snp.right).offset(5)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20)
        }
        subLine2.snp.makeConstraints(){
            $0.left.right.equalTo(view).inset(16)
            $0.height.equalTo(1)
            $0.top.equalTo(connectButton.snp.bottom).offset(15)
        }
        withdrawalB.snp.makeConstraints(){
            $0.top.equalTo(subLine2.snp.bottom).offset(15)
            $0.right.equalTo(subLine.snp.right).inset(16)
        }
    }
    
    @objc func moveToMyPage() {
        // 이미지와 이름 저장
        let nameToSave = myName.text?.isEmpty ?? true ? previousName : myName.text
        
        Task {
            do {
                // Firebase 사용자 프로필 업데이트
                try await updateProfile(displayName: nameToSave, photoURL: profile.image)
                
                // 사용자 정보를 Firestore에 저장
                guard let user = Auth.auth().currentUser else {
                    throw NSError(domain: "UserError", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인 되어있지 않습니다"])
                }
                
                var dataToSave: [String: Any] = [
                    "email": user.email ?? "",
                    "displayName": nameToSave ?? "",
                    "authProvider": user.providerData.first?.providerID ?? "",
                    "isProfileComplete": true
                ]
                
                if let photoURL = user.photoURL?.absoluteString {
                    dataToSave["photoURL"] = photoURL
                }
                
                let userRef = Firestore.firestore().collection("users").document(user.uid)
                try await userRef.setData(dataToSave, merge: true)
                
                // MyPageViewController에 업데이트된 정보 반영
                if let navigationController = navigationController, let myPageVC = navigationController.viewControllers.first(where: { $0 is MyPageViewController }) as? MyPageViewController {
                    myPageVC.updateUserData(name: nameToSave!, image: profile.image)
                }
                
                let alert = UIAlertController(title: "", message: "수정이 완료되었습니다", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(confirm)
                present(alert, animated: true, completion: nil)
            } catch {
                print("프로필 업데이트 실패: \(error.localizedDescription)")
                let alert = UIAlertController(title: "오류", message: "프로필 업데이트 중 오류가 발생했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default)
                alert.addAction(confirm)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // Firestore에 사용자 프로필 정보 업데이트
    func updateProfile(displayName: String?, photoURL: UIImage?) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "UserError", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인 되어있지 않습니다"])
        }
        
        let changeRequest = user.createProfileChangeRequest()
        
        if let displayName = displayName {
            changeRequest.displayName = displayName
        }
        
        if let photoURL = photoURL, let photoData = photoURL.jpegData(compressionQuality: 0.75) {
            let storageRef = Storage.storage().reference().child("profileimages/\(user.uid).jpg")
            do {
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let _ = try await storageRef.putDataAsync(photoData, metadata: metadata)
                let downloadURL = try await storageRef.downloadURL()
                changeRequest.photoURL = downloadURL
                print("이미지 업로드 성공")
            } catch {
                throw NSError(domain: "StorageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 업로드 실패: \(error.localizedDescription)"])
            }
        }
        
        do {
            try await changeRequest.commitChanges()
            print("사용자 프로필 업데이트 성공")
        } catch {
            throw NSError(domain: "ProfileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "프로필 업데이트 실패: \(error.localizedDescription)"])
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // Step 1: 글자 수 체크
        if updatedText.isEmpty {
            nameAlert.text = "😗 닉네임을 입력해주세요\n입력하신 닉네임은 다른 사용자에게 노출됩니다"
            nameAlert.textColor = .darkgray
            doneButton.isEnabled = false
            return true
        }
        
        if updatedText.count < 2 || updatedText.count > 16 {
            nameAlert.text = "😗 글자 수를 맞춰주세요 (2자 이상, 16자 이하)"
            nameAlert.textColor = .darkgray
            doneButton.isEnabled = false
            return true
        }
        
        // Step 2: 특수문자 포함 여부 체크 (공백과 특수문자만 체크)
        let nicknamePattern = "^[a-zA-Z0-9가-힣]*$"
        let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknamePattern)
        if !nicknamePredicate.evaluate(with: updatedText) {
            nameAlert.text = "🤬 닉네임에 특수문자나 공백을 포함할 수 없습니다"
            nameAlert.textColor = .red
            doneButton.titleLabel?.textColor = .lightGray
            doneButton.isEnabled = false
            return true
        }
        
        nameAlert.text = ""
        doneButton.isEnabled = false
        
        // 중복 체크는 텍스트 편집이 끝난 후에 수행합니다.
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let nickname = textField.text ?? ""
        
        // 글자 수 및 특수문자 체크 통과한 후 Firestore에서 닉네임 중복 체크
        if nickname.count >= 2 && nickname.count <= 16 {
            let nicknamePattern = "^[a-zA-Z0-9가-힣]+$"
            let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknamePattern)
            
            if nicknamePredicate.evaluate(with: nickname) {
                Task {
                    do {
                        let isDuplicate = try await FirestoreManager.shared.checkDisplayNameExists(displayName: nickname)
                        if isDuplicate {
                            nameAlert.text = "😱 아쉬워요.. 다른 사용자가 먼저 등록했어요"
                            nameAlert.textColor = .red
                            doneButton.titleLabel?.textColor = .lightGray
                            doneButton.isEnabled = false
                        } else {
                            nameAlert.text = "😁 사용할 수 있는 닉네임입니다!"
                            nameAlert.textColor = .font
                            doneButton.isEnabled = true
                        }
                    } catch {
                        let alert = UIAlertController(title: "😵‍💫", message: "닉네임 확인 중 오류가 발생했습니다: \(error.localizedDescription)", preferredStyle: .alert)
                        let confirm = UIAlertAction(title: "확인", style: .default)
                        alert.addAction(confirm)
                        present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //작성완료시 엔터 누르면 키보드 내려가기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @objc func imageViewTapped(tapGestureRecognizer: UITapGestureRecognizer){
        //하단에서 이미지선택지 알람 등장(액션시트)
        let alert = UIAlertController(title: "프로필 사진 변경", message: nil, preferredStyle: .actionSheet)
        let changeToDefault = UIAlertAction(title: "기본으로 변경", style: .default) { _ in
            self.profile.image = nil
            self.addImage.tintColor = UIColor.textColorSub
        }
        let selectImage = UIAlertAction(title: "새로운 사진 등록", style: .default) { _ in
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 1
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        [changeToDefault, selectImage, cancel].forEach(){
            alert.addAction($0)
        }
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let selectedImage = image as? UIImage {
                        self?.profile.image = selectedImage
                        self?.addImage.tintColor = UIColor.clear
                    }
                }
            }
        }
    }
    
    override func updateColor() {
        super.updateColor()
        let lineBackgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "babygray")
        subLine.backgroundColor = lineBackgroundColor
        subLine2.backgroundColor = lineBackgroundColor
        
        let nameAlertColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightgray") : UIColor(named: "darkgray")
        nameAlert.textColor = nameAlertColor
        
        let myNameColor = traitCollection.userInterfaceStyle == .dark ? CGColor(gray: 100, alpha: 1) : CGColor(gray: 0, alpha: 1)
        myName.layer.borderColor = myNameColor
        
        let profileColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "lightgray")
        profile.backgroundColor = profileColor
        
        //카카오톡 한정으로 다크모드시 아이콘 색상 변경
        let iconColor = traitCollection.userInterfaceStyle == .dark ? UIColor(red: 254/255, green: 229/255, blue: 0, alpha: 1) : UIColor(red: 60/255, green: 29/255, blue: 30/255, alpha: 1)
        IDIcon.tintColor = iconColor
        setIcon()
        
        let connectButtonColor = traitCollection.userInterfaceStyle == .dark ? CGColor(gray: 100, alpha: 1) : CGColor(gray: 0, alpha: 1)
        connectButton.layer.borderColor = connectButtonColor
        
        let withdrawalColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "lightgray")
        withdrawalB.setTitleColor(withdrawalColor, for: .normal)
    }
    
    // ManagedObjectContext 가져오기
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // 회원 탈퇴 액션
    @objc func TappedWithdrawalB(_ sender: UIButton) {
        let confirmAlert = UIAlertController(title: "회원 탈퇴", message: "정말로 회원 탈퇴하시겠습니까? \n 지금까지의 모든 기록이 사라집니다.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .destructive) { _ in
            self.performAccountDeletion()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        confirmAlert.addAction(confirmAction)
        confirmAlert.addAction(cancelAction)
        
        self.present(confirmAlert, animated: true, completion: nil)
    }

    private func performAccountDeletion() {
        guard let user = Auth.auth().currentUser else { return }
        let userId = user.uid
        
        Task {
            do {
                // 모든 사용자 데이터 삭제
                try await AccountDeletionManager.shared.deleteUser(uid: userId, context: context)
                
                // 모든 데이터 삭제가 성공하면 로그아웃
                try Auth.auth().signOut()
                
                // 성공 알림 및 로그인 화면으로 이동
                showAlert(title: "회원 탈퇴 완료", message: "회원 탈퇴가 완료되었습니다. \n 지금까지의 모든 기록이 삭제되었습니다.") {
                    self.navigateToLoginScreen()
                }
            } catch {
                print("회원 탈퇴 실패: \(error.localizedDescription)")
                showAlert(title: "오류", message: "회원 탈퇴 중 오류가 발생했습니다. \n 데이터가 정상적으로 삭제되지 않았을 가능성이 있습니다.") {
                    self.navigateToLoginScreen()
                }
            }
        }
    }

    // 로그인 화면으로 이동하는 함수
    func navigateToLoginScreen() {
        DispatchQueue.main.async {
            let loginVC = AuthenticationVC()
            let navigationController = UINavigationController(rootViewController: loginVC)
            navigationController.modalPresentationStyle = .fullScreen
            self.view.window?.rootViewController = navigationController
            self.view.window?.makeKeyAndVisible()
        }
    }

    // 오류 메시지를 표시하는 함수
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                completion?()
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
