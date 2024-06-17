//
//  BaseViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/28/24.
//

import UIKit
import SnapKit
import Then

class BaseViewController: UIViewController {
    
    let logo = UIImageView()
    var transition: CATransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constraintLayout()
        configureUI()
        createTransition()
        updateColor()
    }
    func configureUI() {
        logo.image = UIImage(named: "logo")?.withTintColor(UIColor(named: "lightgray")!)
    }
    
    func constraintLayout() {
        view.addSubview(logo)
    }
    
    //화면전환 애니메이션 설정
    //애니메이션 방향 및 세부 설정을 해주고 transition이라고 정의
    //여기의 transition을 위에서 선언한 변수의 transition과 같다고 연결해주기
    func createTransition(){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromLeft
        self.transition = transition
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // 이전 trait collection과 현재 trait collection이 다를 경우 업데이트
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        let color = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "lightgray")
        logo.image = UIImage(named: "logo")?.withTintColor(color!)
        
    }
}

