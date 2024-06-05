//
//  EditViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit


class EditViewController: BaseViewController, UITextFieldDelegate {
    
    let doneButton = UIButton()
    var profile = UIImageView()
    var myName = UITextField().then(){
        $0.textColor = .font
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.font.cgColor
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
    }
    
    override func configureUI(){
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.font, for: .normal)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        doneButton.addTarget(self, action: #selector(moveToMyPage), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: doneButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        profile.clipsToBounds = true
        profile.layer.cornerRadius = profile.frame.size.width / 2
        profile.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        profile.layer.shadowRadius = 15
        profile.layer.shadowOpacity = 0.25
        
        
        myName.placeholder = previousName
        myName.clearButtonMode = .never // x 버튼 비활성화
        myName.delegate = self
        
        nameAlert.text = "* 닉네임은 3글자 이상, 16글자 이하여야 합니다"
        nameAlert.font = UIFont.systemFont(ofSize: 12)
        nameAlert.textColor = .lightgray
        
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
        switch self.userData?.authProvider {
        case .google:
            self.IDIcon.image = UIImage(named: "googleLogo")
        case .apple:
            self.IDIcon.image = UIImage(named: "appleLogo")!.withTintColor(UIColor.font)
        case .kakao:
            self.IDIcon.image = UIImage(named: "kakaoLogo")
        case .email:
            self.IDIcon.image = UIImage(systemName: "envelope.fill")!.withTintColor(UIColor.font)
        case nil:
            print("등록된 로그인 정보가 없습니다")
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
    
//    @objc func selectProfileImage() {
//            let picker = UIImagePickerController()
//            picker.delegate = self
//            picker.sourceType = .photoLibrary
//            picker.allowsEditing = true
//            present(picker, animated: true, completion: nil)
//        }
//    
//    // UIImagePickerControllerDelegate 메서드
//       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//           if let editedImage = info[.editedImage] as? UIImage {
//               profile.image = editedImage
//           } else if let originalImage = info[.originalImage] as? UIImage {
//               profile.image = originalImage
//           }
//           dismiss(animated: true, completion: nil)
//       }
//       
//       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//           dismiss(animated: true, completion: nil)
//       }
    
    override func constraintLayout() {
        super.constraintLayout() //부모뷰의 설정을 가져온다
        [profile, myName, nameAlert, IDArea, subTitleBackground, subTitle, withdrawalB].forEach(){
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
    
    //텍스트필드 글자수제한에 관한 코드
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count >= 3 && updatedText.count <= 16 {
            nameAlert.textColor = .lightgray
            doneButton.isEnabled = true
        } else {
            //글자수를 맞추지 못할 시 안내문 빨갛게 변하며 이동버튼도 비활성화
            nameAlert.textColor = .red
            doneButton.titleLabel?.textColor = .lightgray
            doneButton.isEnabled = false
        }
        return true
    }
}

