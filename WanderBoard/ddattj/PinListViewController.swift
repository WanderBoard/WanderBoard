//
//  PinListViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit

class PinListViewController: BaseViewController {
    
    let btn = backButton()
    let btn2 = actionButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        configureUI()
        constraintLayout()
    }
    
    override func configureUI() {
        super.configureUI()
        
        btn.label.text = "마이페이지"
        btn.addTarget(self, action: #selector(goToBack), for: .touchUpInside)
        btn2.icon.image = UIImage(systemName: "trash")
        btn2.icon.snp.makeConstraints(){
            $0.width.equalTo(24)
            $0.height.equalTo(30)
            $0.right.equalTo(view).offset(-35)
        }
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
            $0.top.equalTo(61)
            $0.right.equalTo(view).offset(-15)
            $0.width.height.equalTo(44)
        }
    }
    @objc func goToBack(){
        // 저장된 애니메이션 객체를 사용하여 애니메이션 적용
        //애니메이션은 레이어 개념으로 분류하기 때문에 내가 설정한 커스텀 레이어(애니메이션)를 올려준다는 느낌 -> 기존의 애니메이션은 false로 바꿔주자
        //transition이 없다면 CATransition(디폴트 애니메이션)를 실행하라
        navigationController?.view.layer.add(transition ?? CATransition(), forKey: kCATransition)
        let myPageVC = MyPageViewController()
        navigationController?.pushViewController(myPageVC, animated: false)
    }
}



