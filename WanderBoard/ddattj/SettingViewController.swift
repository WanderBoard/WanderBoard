//
//  SettingViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit

class SettingViewController: BaseViewController {
    
    let scriptBackground1 = UIView()
    let scriptTitle1 = UILabel()
    let subTitle1 = UILabel()
    let connectButton = UIButton()
    let scriptBackground2 = UIView()
    let scriptTitle2 = UILabel()
    let lightMode = UIView()
    let phoneImageL = UIImageView()
    let titleL = UILabel()
    let iconL = UIImageView()
    let darkMode = UIButton()
    let phoneImageD = UIImageView()
    let titleD = UILabel()
    let iconD = UIImageView()
    let line = UIImageView()
    let subTitle2 = UILabel()
    let toggle = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        constraintLayout()
        
        //토글로 모드 자동전환 실행
        toggle.addTarget(self, action: #selector(modeChangedWithToggle), for: .valueChanged)
        
        let tapRecognizerL = UITapGestureRecognizer(target: self, action: #selector(viewTappedL(tapGestureRecognizer:)))
        // UIView가 상호작용할 수 있게 설정
        lightMode.isUserInteractionEnabled = true
        // 제스처 인식기 연결
        lightMode.addGestureRecognizer(tapRecognizerL)
        // lightMode의 배경색을 서서히 변경하는 애니메이션
        
        let tapRecognizerD
        = UITapGestureRecognizer(target: self, action: #selector(viewTappedD(tapGestureRecognizer:)))
        darkMode.isUserInteractionEnabled = true
        darkMode.addGestureRecognizer(tapRecognizerD)
    }
    
    override func configureUI() {
        super.configureUI()
        scriptBackground1.backgroundColor = .babygray
        scriptBackground1.layer.cornerRadius = 10
        
        scriptTitle1.text = "계정 연결"
        scriptTitle1.font = UIFont.boldSystemFont(ofSize: 15)
        scriptTitle1.textColor = .font
        
        subTitle1.text = "인스타그램"
        subTitle1.font = UIFont.boldSystemFont(ofSize: 13)
        subTitle1.textColor = .font
        
        connectButton.layer.borderWidth = 1
        connectButton.layer.cornerRadius = 10
        connectButton.layer.borderColor = CGColor(gray: 0, alpha: 1)
        connectButton.setTitle("인스타그램 계정 연결하기", for: .normal)
        connectButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        connectButton.setTitleColor(.font, for: .normal)
        connectButton.setImage(UIImage(named: "instagramLogo"), for: .normal)
        if let imageView = connectButton.imageView {
                   imageView.snp.makeConstraints {
                       $0.width.height.equalTo(24) // 이미지 크기를 24x24로 설정
                       $0.centerY.equalToSuperview()
                       let label = connectButton.titleLabel
                       $0.right.equalTo(label!.snp.left).offset(-8)
                   }
               }
        
        scriptBackground2.backgroundColor = .babygray
        scriptBackground2.layer.cornerRadius = 10
        
        scriptTitle2.text = "모드 적용"
        scriptTitle2.font = UIFont.boldSystemFont(ofSize: 15)
        scriptTitle2.textColor = .font
        
        phoneImageL.image = UIImage(named: "lightModePhone")
        phoneImageL.contentMode = .scaleAspectFit
        titleL.text = "라이트모드"
        titleL.textColor = .font
        titleL.font = UIFont.boldSystemFont(ofSize: 15)
        iconL.image = UIImage(systemName: "circle")
        iconL.tintColor = .font
        
        phoneImageD.image = UIImage(named: "darkModePhone")
        phoneImageD.contentMode = .scaleAspectFit
        titleD.text = "다크모드"
        titleD.textColor = .font
        titleD.font = UIFont.boldSystemFont(ofSize: 15)
        iconD.image = UIImage(systemName: "circle")
        iconD.tintColor = .font
        
        subTitle2.text = "자동"
        subTitle2.font = UIFont.boldSystemFont(ofSize: 16)
        subTitle2.textColor = .font
        
        toggle.thumbTintColor = UIColor(named: "textColor")
        toggle.onTintColor = .font
    }
    
    override func constraintLayout() {
        super.constraintLayout()
        [scriptBackground1, scriptTitle1, subTitle1, connectButton, scriptBackground2, scriptTitle2, lightMode, darkMode, line, subTitle2, toggle].forEach(){
            view.addSubview($0)
        }
        scriptBackground1.snp.makeConstraints(){
            $0.horizontalEdges.equalTo(view).inset(16)
            $0.top.equalTo(view).offset(112)
            $0.height.equalTo(44)
        }
        scriptTitle1.snp.makeConstraints(){
            $0.centerY.equalTo(scriptBackground1)
            $0.left.equalTo(scriptBackground1.snp.left).offset(29)
        }
        subTitle1.snp.makeConstraints(){
            $0.top.equalTo(scriptBackground1.snp.bottom).offset(26)
            $0.left.equalTo(scriptBackground1.snp.left).offset(16)
        }
        connectButton.snp.makeConstraints(){
            $0.top.equalTo(scriptBackground1.snp.bottom).offset(17)
            $0.left.equalTo(subTitle1.snp.right).offset(88)
            $0.right.equalTo(view).offset(-16)
            $0.height.equalTo(44)
            
        }
        scriptBackground2.snp.makeConstraints(){
            $0.horizontalEdges.equalTo(view).inset(16)
            $0.top.equalTo(connectButton.snp.bottom).offset(44)
            $0.height.equalTo(44)
        }
        scriptTitle2.snp.makeConstraints(){
            $0.centerY.equalTo(scriptBackground2)
            $0.left.equalTo(scriptBackground2.snp.left).offset(29)
        }
        lightMode.snp.makeConstraints(){
            $0.top.equalTo(scriptBackground2.snp.bottom).offset(21)
            $0.left.equalTo(view).offset(81)
            $0.width.equalTo(92)
            $0.height.equalTo(200)
        }
        
        [phoneImageL, titleL, iconL].forEach(){
            lightMode.addSubview($0)
        }
        phoneImageL.snp.makeConstraints(){
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(5)
            $0.height.equalTo(150)
        }
        titleL.snp.makeConstraints(){
            $0.centerX.equalToSuperview()
            $0.top.equalTo(phoneImageL.snp.bottom).offset(5)
        }
        iconL.snp.makeConstraints(){
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleL.snp.bottom).offset(8)
        }
        
        darkMode.snp.makeConstraints(){
            $0.top.equalTo(scriptBackground2.snp.bottom).offset(21)
            $0.right.equalTo(view).offset(-81)
            $0.width.equalTo(92)
            $0.height.equalTo(200)
        }
        
        [phoneImageD, titleD, iconD].forEach(){
            darkMode.addSubview($0)
        }
        
        phoneImageD.snp.makeConstraints(){
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(5)
            $0.height.equalTo(150)
        }
        titleD.snp.makeConstraints(){
            $0.centerX.equalToSuperview()
            $0.top.equalTo(phoneImageD.snp.bottom).offset(5)
        }
        iconD.snp.makeConstraints(){
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleD.snp.bottom).offset(8)
        }
        
        line.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.top.equalTo(darkMode.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(view).inset(16)
            $0.height.equalTo(1)
        }
        subTitle2.snp.makeConstraints(){
            $0.top.equalTo(line.snp.bottom).offset(21)
            $0.left.equalTo(scriptBackground2.snp.left).offset(16)
        }
        toggle.snp.makeConstraints(){
            $0.top.equalTo(line.snp.bottom).offset(16)
            $0.right.equalTo(view).offset(-32)
            $0.width.equalTo(52)
            $0.height.equalTo(32)
        }
        logo.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.width.equalTo(143)
            $0.height.equalTo(18.24)
            $0.bottom.equalTo(view).offset(-55)
        }
    }
    
    @objc func viewTappedL(tapGestureRecognizer: UITapGestureRecognizer){
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.overrideUserInterfaceStyle = .light
            self.iconL.image = UIImage(systemName: "checkmark.circle.fill")
            self.iconD.image = UIImage(systemName: "circle")
        }, completion: nil)
    }

    @objc func viewTappedD(tapGestureRecognizer: UITapGestureRecognizer){
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.overrideUserInterfaceStyle = .dark
            self.iconD.image = UIImage(systemName: "checkmark.circle.fill")
            self.iconL.image = UIImage(systemName: "circle")
        }, completion: nil)
    }
    
    @objc func modeChangedWithToggle(_ sender: UISwitch){
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.iconL.image = UIImage(systemName: "circle")
            self.iconD.image = UIImage(systemName: "circle")
            if sender.isOn {
                let hour = Calendar.current.component(.hour, from: Date())
                if hour >= 18 || hour < 6
                {
                    //저녁 6시부터 다음 날 아침 6시까진 다크모드
                    self.overrideUserInterfaceStyle = .dark
                } else {
                    self.overrideUserInterfaceStyle = .light
                }
            }
        }, completion: nil)
    }
    
    override func updateColor(){
        super.updateColor()
        let scriptBackgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
        scriptBackground1.backgroundColor = scriptBackgroundColor
        scriptBackground2.backgroundColor = scriptBackgroundColor
        
        let connectButtonColor = traitCollection.userInterfaceStyle == .dark ? CGColor(gray: 100, alpha: 1) : CGColor(gray: 0, alpha: 1)
        connectButton.layer.borderColor = connectButtonColor
    }

}
