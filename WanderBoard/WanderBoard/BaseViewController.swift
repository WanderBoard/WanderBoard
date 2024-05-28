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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constraintLayout()
        configureUI()
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
        label.font = UIFont.systemFont(ofSize: 17)
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
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor(named: "font")
    }
    
    func constraintLayout(){
        self.addSubview(icon)
        self.addSubview(label)
    }
}
