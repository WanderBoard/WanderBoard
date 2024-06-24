//
//  LoginDirectorView.swift
//  WanderBoard
//
//  Created by 이시안 on 6/24/24.
//

import UIKit
import SnapKit
import Then
import SwiftUI

struct LoginDirectorViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LoginDirectorView {
        return LoginDirectorView()
    }

    func updateUIViewController(_ uiViewController: LoginDirectorView, context: Context) {
        // 업데이트 로직을 여기에 작성할 수 있습니다 (필요한 경우)
    }
}

struct LoginDirectorViewPreview: PreviewProvider {
    static var previews: some View {
        LoginDirectorViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all) // 필요에 따라 수정 가능
    }
}

class LoginDirectorView: UIViewController {
    let logo = UIImageView().then(){
        $0.image = UIImage(named: "login")
    }
    var titleLabel = UILabel().then(){
        $0.text = "로그인이 필요합니다"
        $0.textColor = .font
        $0.font = UIFont.boldSystemFont(ofSize: 17)
        $0.textAlignment = .center
    }
    var subLable = UILabel().then(){
        $0.text = "로그인을 통해 당신의 여행 기록을 추가하고 \n 사람들과 소중한 순간을 공유해보세요"
        $0.textColor = .darkgray
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    var loginButton = UIButton().then(){
        $0.setTitle("로그인 하러가기", for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        $0.backgroundColor = UIColor(named: "textColor")
        $0.setTitleColor(.font, for: .normal)
        $0.layer.cornerRadius = 23
        $0.addTarget(LoginDirectorView.self, action: #selector(moveToLogin), for: .touchUpInside)
        
    }
    let stackView = UIStackView().then(){
        $0.axis = .vertical
        $0.spacing = 5
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.15)
        constraintLayout()
    }
    func constraintLayout(){
        [logo, stackView, loginButton].forEach(){
            view.addSubview($0)
        }
        [titleLabel, subLable].forEach(){
            stackView.addArrangedSubview($0)
        }
        
        stackView.snp.makeConstraints(){
            $0.center.equalTo(view)
            $0.horizontalEdges.equalTo(view).inset(48)
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
    //백그라운드 블러
    func addBlurEffect() {
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            view.insertSubview(blurEffectView, at: 0)
            
            blurEffectView.snp.makeConstraints {
                $0.edges.equalTo(view)
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
        let Bcolor = traitCollection.userInterfaceStyle == .dark ? UIColor(white: 1, alpha: 0.15) : UIColor(white: 0, alpha: 0.15)
        view.backgroundColor = Bcolor
    }
}
