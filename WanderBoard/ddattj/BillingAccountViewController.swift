//
//  BillingAccountViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit

class BillingAccountViewController: BaseViewController {
    
    let btn = backButton()
    let btn2 = actionButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        configureUI()
        constraintLayout()

    }
    
    override func configureUI() {
        super.configureUI()
        
        btn.label.text = "마이페이지"
        btn.addTarget(self, action: #selector(goToBack), for: .touchUpInside)
        
        btn2.icon.image = UIImage(systemName: "pencil.circle")
        btn2.icon.snp.makeConstraints(){
            $0.width.height.equalTo(25)
            $0.right.equalTo(view).offset(-25)
        }
        myTitle.text = "계좌연결"
    }
    
    override func constraintLayout() {
        super.constraintLayout()
        [btn, btn2].forEach(){
            view.addSubview($0)
        }
        btn.snp.makeConstraints {
            $0.top.equalTo(view).offset(65)
            $0.left.equalTo(view).offset(15)
            $0.width.equalTo(99)
            $0.height.equalTo(44)
        }
        btn2.snp.makeConstraints(){
            $0.top.equalTo(65)
            $0.right.equalTo(view).offset(-15)
            $0.width.height.equalTo(44)
        }
    }
    
    @objc func goToBack(){
        navigationController?.view.layer.add(transition ?? CATransition(), forKey: kCATransition)
        let myPageVC = MyPageViewController()
        navigationController?.pushViewController(myPageVC, animated: false)
    }

}
