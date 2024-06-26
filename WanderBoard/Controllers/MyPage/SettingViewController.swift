//
//  SettingViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit

class SettingViewController: BaseViewController {
    
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
        // 저장된 사용자 인터페이스 스타일 적용
        applySavedUserInterfaceStyle()
        
        toggle.addTarget(self, action: #selector(modeChangedWithToggle), for: .valueChanged)//토글로 모드 자동전환 실행
        
        let tapRecognizerL = UITapGestureRecognizer(target: self, action: #selector(viewTappedL(tapGestureRecognizer:)))
        lightMode.isUserInteractionEnabled = true  // UIView가 상호작용할 수 있게 설정
        lightMode.addGestureRecognizer(tapRecognizerL) // 제스처 인식기 연결
        
        let tapRecognizerD
        = UITapGestureRecognizer(target: self, action: #selector(viewTappedD(tapGestureRecognizer:)))
        darkMode.isUserInteractionEnabled = true
        darkMode.addGestureRecognizer(tapRecognizerD)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func configureUI() {
        super.configureUI()
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
        [lightMode, darkMode, line, subTitle2, toggle].forEach(){
            view.addSubview($0)
        }
        lightMode.snp.makeConstraints(){
            $0.top.equalTo(view).offset(112)
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
            $0.top.equalTo(view).offset(112)
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
            $0.top.equalTo(line.snp.bottom).offset(20)
            $0.left.equalTo(view).offset(32)
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
    
    func applySavedUserInterfaceStyle() {
        let selectedMode = UserDefaults.standard.string(forKey: "modeSelected") ?? "light"
        let isAutomatic = UserDefaults.standard.bool(forKey: "isAutomatic")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = windowScene.windows.first
            if isAutomatic {
                toggle.isOn = true
                self.iconL.image = UIImage(systemName: "circle")
                self.iconL.tintColor = .babygray
                self.iconD.image = UIImage(systemName: "circle")
                self.iconD.tintColor = .babygray
                lightMode.isUserInteractionEnabled = false
                darkMode.isUserInteractionEnabled = false
                applyAutomaticMode(window: window)
            } else {
                toggle.isOn = false
                lightMode.isUserInteractionEnabled = true
                darkMode.isUserInteractionEnabled = true
                self.iconL.tintColor = .font
                self.iconD.tintColor = .font
                if selectedMode == "dark" {
                    window?.overrideUserInterfaceStyle = .dark
                    self.iconL.image = UIImage(systemName: "circle")
                    self.iconD.image = UIImage(systemName: "checkmark.circle.fill")
                } else {
                    window?.overrideUserInterfaceStyle = .light
                    self.iconL.image = UIImage(systemName: "checkmark.circle.fill")
                    self.iconD.image = UIImage(systemName: "circle")
                }
            }
        }
    }
    
    func applyAutomaticMode(window: UIWindow?) {
            let hour = Calendar.current.component(.hour, from: Date())
            if hour >= 18 || hour < 6 {
                window?.overrideUserInterfaceStyle = .dark
            } else {
                window?.overrideUserInterfaceStyle = .light
            }
    }
    
    @objc func viewTappedL(tapGestureRecognizer: UITapGestureRecognizer){
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let appDelegate = windowScene.windows.first
                appDelegate?.overrideUserInterfaceStyle = .light
                self.iconL.image = UIImage(systemName: "checkmark.circle.fill")
                self.iconD.image = UIImage(systemName: "circle")
                self.toggle.isOn = false
                self.lightMode.isUserInteractionEnabled = true
                self.darkMode.isUserInteractionEnabled = true
                self.iconL.tintColor = .font
                self.iconD.tintColor = .font
                UserDefaults.standard.set("light", forKey: "modeSelected")
                UserDefaults.standard.set(false, forKey: "isAutomatic")
            }
        }, completion: nil)
    }
    
    @objc func viewTappedD(tapGestureRecognizer: UITapGestureRecognizer){
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let appDelegate = windowScene.windows.first
                appDelegate?.overrideUserInterfaceStyle = .dark
                self.iconL.image = UIImage(systemName: "circle")
                self.iconD.image = UIImage(systemName: "checkmark.circle.fill")
                self.toggle.isOn = false
                self.lightMode.isUserInteractionEnabled = true
                self.darkMode.isUserInteractionEnabled = true
                self.iconL.tintColor = .font
                self.iconD.tintColor = .font
                UserDefaults.standard.set("dark", forKey: "modeSelected")
                UserDefaults.standard.set(false, forKey: "isAutomatic")
            }
        }, completion: nil)
    }
    
    @objc func modeChangedWithToggle(_ sender: UISwitch){
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let appDelegate = windowScene.windows.first
                if sender.isOn {
                    self.iconL.image = UIImage(systemName: "circle")
                    self.iconL.tintColor = .babygray
                    self.iconD.image = UIImage(systemName: "circle")
                    self.iconD.tintColor = .babygray
                    self.lightMode.isUserInteractionEnabled = false
                    self.darkMode.isUserInteractionEnabled = false
                    self.applyAutomaticMode(window: appDelegate)
                    //키값 오타때문에....오타에 유의하자
                    UserDefaults.standard.set(true, forKey: "isAutomatic")
                    print("자동모드 사용중")
                } else {
                    // 토글이 꺼져 있을 때, 기본 모드를 설정합니다 (라이트 모드)
                    self.lightMode.isUserInteractionEnabled = true
                    self.darkMode.isUserInteractionEnabled = true
                    self.iconL.tintColor = .font
                    self.iconD.tintColor = .font
                    appDelegate?.overrideUserInterfaceStyle = .light
                    self.iconL.image = UIImage(systemName: "checkmark.circle.fill")
                    self.iconD.image = UIImage(systemName: "circle")
                    UserDefaults.standard.set("light", forKey: "modeSelected")
                    UserDefaults.standard.set(false, forKey: "isAutomatic")
                }
            }
        }, completion: nil)
    }
}
