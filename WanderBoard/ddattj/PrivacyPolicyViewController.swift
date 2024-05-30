//
//  PrivacyPolicyViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit

class PrivacyPolicyViewController: BaseViewController {
    
    let btn = backButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .magenta
        configureUI()
        constraintLayout()
    }
    
    override func configureUI() {
        super.configureUI()
        
        btn.label.text = "마이페이지"
        btn.addTarget(self, action: #selector(goToBack), for: .touchUpInside)
        
        myTitle.text = "개인정보처리방침"
    }
    
    override func constraintLayout() {
        super.constraintLayout()
        [btn].forEach(){
            view.addSubview($0)
        }
        btn.snp.makeConstraints {
            $0.top.equalTo(view).offset(65)
            $0.left.equalTo(view).offset(15)
            $0.width.equalTo(99)
            $0.height.equalTo(44)
        }
    }
    
    @objc func goToBack(){
        navigationController?.view.layer.add(transition ?? CATransition(), forKey: kCATransition)
        let myPageVC = MyPageViewController()
        navigationController?.pushViewController(myPageVC, animated: false)
    }

}
