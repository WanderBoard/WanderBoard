//
//  EditViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit
import PhotosUI

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
    let subTitleBackground = UIView()
    let subTitle = UILabel()
    let withdrawalB = UIButton()
    var previousName = String()
    var ID = String()
    var userData: AuthDataResultModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIcon()
        view.backgroundColor = .systemBackground
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(tapGestureRecognizer:)))
        profile.isUserInteractionEnabled = true
        profile.addGestureRecognizer(tapGestureRecognizer)
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
        
        subTitleBackground.backgroundColor = .babygray
        subTitleBackground.layer.cornerRadius = 10
        
        subTitle.text = "관리"
        subTitle.font = UIFont.boldSystemFont(ofSize: 15)
        subTitle.textColor = .font
        
        withdrawalB.setTitle("회원탈퇴", for: .normal)
        withdrawalB.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        withdrawalB.setTitleColor(UIColor(named: "lightgray"), for: .normal)
    }
    
    func setIcon() {
        let iconColor: UIColor
        if traitCollection.userInterfaceStyle == .dark {
            iconColor = UIColor(red: 254/255, green: 229/255, blue: 0, alpha: 1)
        } else {
            iconColor = UIColor(red: 60/255, green: 29/255, blue: 30/255, alpha: 1)
        }
        
        switch self.userData?.authProvider {
        case .google:
            self.IDIcon.image = UIImage(named: "googleLogo")
        case .apple:
            self.IDIcon.image = UIImage(named: "appleLogo")?.withTintColor(UIColor.font)
        case .kakao:
            self.IDIcon.image = UIImage(named: "kakaoLogo")?.withRenderingMode(.alwaysTemplate)
            self.IDIcon.tintColor = iconColor
        case .email:
            self.IDIcon.image = UIImage(named: "kakaoLogo")?.withRenderingMode(.alwaysTemplate)
            self.IDIcon.tintColor = iconColor // 이메일 로그인은 추가 안함, 카카오랑 같은 아이콘 뜨도록 설정
        case nil:
            print("등록된 로그인 정보가 없습니다")
        }
    }
    
    override func constraintLayout() {
        super.constraintLayout() //부모뷰의 설정을 가져온다
        [profile, addImage, myName, nameAlert, IDArea, subTitleBackground, subTitle, withdrawalB].forEach(){
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
            $0.left.equalTo(IDIcon.snp.right).offset(11)
            $0.right.equalTo(IDArea)
        }
        subTitleBackground.snp.makeConstraints(){
            $0.left.right.equalTo(view).inset(16)
            $0.height.equalTo(44)
            $0.top.equalTo(IDArea.snp.bottom).offset(50)
        }
        subTitle.snp.makeConstraints(){
            $0.centerY.equalTo(subTitleBackground)
            $0.left.equalTo(subTitleBackground.snp.left).offset(29)
        }
        withdrawalB.snp.makeConstraints(){
            $0.top.equalTo(subTitleBackground.snp.bottom).offset(18)
            $0.left.equalTo(subTitleBackground.snp.left).offset(16)
        }
    }
    
    @objc func moveToMyPage(){
        let alert = UIAlertController(title: "", message: "수정이 완료되었습니다", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) { _ in
            let myPageVC = MyPageViewController()
            self.navigationController?.pushViewController(myPageVC, animated: false)
        }
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
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
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
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
        let scriptBackgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
        subTitleBackground.backgroundColor = scriptBackgroundColor
        
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
    }
}
