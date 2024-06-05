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
        profile.backgroundColor = .babygray
        profile.layer.shadowRadius = 15
        profile.layer.shadowOpacity = 0.25
        
        myName.placeholder = previousName
        myName.clearButtonMode = .never // x 버튼 비활성화
        myName.delegate = self
        
        IDIcon.contentMode = .scaleAspectFit
        
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
        
        let myNameColor = traitCollection.userInterfaceStyle == .dark ? CGColor(gray: 100, alpha: 1) : CGColor(gray: 0, alpha: 1)
        self.myName.layer.borderColor = myNameColor
        
        let profileColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "babygray")
        self.profile.backgroundColor = profileColor
    }
}
