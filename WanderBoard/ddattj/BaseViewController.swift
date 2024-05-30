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
    
    let myTitle = UILabel()
    let logo = UIImageView()
    var transition: CATransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constraintLayout()
        configureUI()
        createTransition()
    }
    func configureUI() {
        myTitle.font = UIFont.systemFont(ofSize: 22)
        myTitle.textColor = UIColor(named: "font")
        logo.image = UIImage(named: "logoFinal")
    }
    
    func constraintLayout() {
        view.addSubview(myTitle)
        view.addSubview(logo)
        myTitle.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.top.equalTo(view).offset(87)
        }
    }
    
    //화면전환 애니메이션 설정
    //애니메이션 방향 및 세부 설정을 해주고 transition이라고 정의
    //여기의 transition을 위에서 선언한 변수의 transition과 같다고 연결해주기
    func createTransition(){
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .push
        transition.subtype = .fromLeft
        self.transition = transition
    }
}


class backButton: UIButton {
    let backIcon = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constraintLayout()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(){
        backIcon.image = UIImage(systemName: "chevron.backward")
        backIcon.tintColor = UIColor(named: "font")
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(named: "font")
    }
    
    func constraintLayout(){
        self.addSubview(backIcon)
        self.addSubview(label)
        
        backIcon.snp.makeConstraints {
            $0.width.equalTo(17)
            $0.height.equalTo(22)
        }
        label.snp.makeConstraints {
            $0.left.equalTo(backIcon.snp.right).offset(3)
            $0.centerY.equalTo(backIcon)
        }
    }
}

class actionButton: UIButton {
    let icon = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constraintLayout()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(){
        icon.tintColor = UIColor(named: "font")
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(named: "font")
    }
    
    func constraintLayout(){
        self.addSubview(icon)
        self.addSubview(label)
    }
}
