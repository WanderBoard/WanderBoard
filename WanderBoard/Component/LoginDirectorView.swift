//
//  LoginDirectorView.swift
//  WanderBoard
//
//  Created by 이시안 on 6/24/24.
//

import UIKit
import SnapKit
import Then

class LoginDirectorView: UIViewController {
    let backGroundView = UIView().then(){
        $0.backgroundColor = UIColor(white: 1, alpha: 0.9)
    }
    let logo = UIImageView().then(){
        $0.image = UIImage(named: "login")
    }
    let titleLabel = UILabel().then(){
        $0.text = "로그인이 필요합니다"
        $0.textColor = .font
        $0.font = UIFont.boldSystemFont(ofSize: 17)
        $0.textAlignment = .center
    }
    let subLabel = UILabel().then(){
        $0.text = "로그인을 통해 당신의 여행 기록을 추가하고 \n 사람들과 소중한 순간을 공유해보세요"
        $0.textColor = .darkgray
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    let loginButton = UIButton().then(){
        $0.setTitle("로그인 하러가기", for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        $0.backgroundColor = .font
        $0.setTitleColor(UIColor(named: "textColor"), for: .normal)
        $0.layer.cornerRadius = 23
    }
    let stackView = UIStackView().then(){
        $0.axis = .vertical
        $0.spacing = 5
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        constraintLayout()
        
        loginButton.addTarget(self, action: #selector(moveToLogin), for: .touchUpInside)
    }
    func constraintLayout(){
        view.addSubview(backGroundView)
        [logo, stackView, loginButton].forEach(){
            backGroundView.addSubview($0)
        }
        [titleLabel, subLabel].forEach(){
            stackView.addArrangedSubview($0)
        }
        
        backGroundView.snp.makeConstraints(){
            $0.edges.equalTo(view)
        }
        stackView.snp.makeConstraints(){
            $0.center.equalTo(backGroundView)
            $0.horizontalEdges.equalTo(backGroundView).inset(48)
        }
        logo.snp.makeConstraints(){
            $0.bottom.equalTo(stackView.snp.top).offset(-10)
            $0.centerX.equalTo(view)
            $0.width.height.equalTo(45)
        }
        loginButton.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.horizontalEdges.equalTo(view).inset(80)
            $0.top.equalTo(stackView.snp.bottom).offset(30)
            $0.height.equalTo(44)
        }
    }
    
    @objc func moveToLogin(){
        let loginVC = AuthenticationVC()
        present(loginVC, animated: true, completion: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor() {
        let Bcolor = traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0, alpha: 0.9) : UIColor(white: 1, alpha: 0.9)
        backGroundView.backgroundColor = Bcolor
        
        let subLabelColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightgray") : UIColor(named: "darkgray")
        subLabel.textColor = subLabelColor
    }
}
