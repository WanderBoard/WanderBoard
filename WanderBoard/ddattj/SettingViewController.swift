//
//  SettingViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit
import SwiftUI

//미리보기 화면
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
struct MyViewController_PreViews: PreviewProvider {
    static var previews: some View {
        SettingViewController().toPreview() //원하는 VC를 여기다 입력하면 된다.
    }
}

class SettingViewController: BaseViewController {
    
    let scriptBackground1 = UIView()
    let scriptTitle1 = UILabel()
    let subTitle1 = UILabel()
    let connectButton = UIButton()
    let scriptBackground2 = UIView()
    let scriptTitle2 = UILabel()
    let lightMode = UIButton()
    let darkMode = UIButton()
    let line = UIImageView()
    let subTitle2 = UILabel()
    let toggle = UISwitch()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        constraintLayout()
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
        
        connectButton.setImage(UIImage(named: "instagramLogo"), for: .normal)
        connectButton.setTitle("인스타그램 계정 연결하기", for: .normal)
        connectButton.setTitleColor(.font, for: .normal)
        
        scriptBackground2.backgroundColor = .babygray
        scriptBackground2.layer.cornerRadius = 10
        
        scriptTitle2.text = "모드 적용"
        scriptTitle2.font = UIFont.boldSystemFont(ofSize: 15)
        scriptTitle2.textColor = .font
        
        subTitle2.text = "자동"
        subTitle2.font = UIFont.boldSystemFont(ofSize: 13)
        subTitle2.textColor = .font
        
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
            $0.top.equalTo(scriptBackground1.snp.bottom).offset(23)
            $0.left.equalTo(scriptBackground1.snp.left).offset(16)
        }
        connectButton.snp.makeConstraints(){
            $0.top.equalTo(scriptBackground1.snp.bottom).offset(17)
            $0.right.equalTo(view).offset(-16)
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
        darkMode.snp.makeConstraints(){
            $0.top.equalTo(scriptBackground2.snp.bottom).offset(21)
            $0.right.equalTo(view).offset(-81)
            $0.width.equalTo(92)
            $0.height.equalTo(200)
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

}
