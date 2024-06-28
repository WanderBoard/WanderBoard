//
//  profileDetail.swift
//  WanderBoard
//
//  Created by 이시안 on 6/28/24.
//

import UIKit
import SnapKit
import Then

class profileDetail: UIViewController {
    
    let backGroundView = UIView().then(){
        $0.backgroundColor = UIColor(white: 1, alpha: 0.9)
    }
    let profileImage = UIImageView().then(){
        $0.backgroundColor = . font
        $0.layer.cornerRadius = 105.5
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    let nameLabel = UILabel().then(){
        $0.text = "닉네임"
        $0.textColor = .font
        $0.font = UIFont.boldSystemFont(ofSize: 17)
        $0.textAlignment = .center
    }
    let stackView = UIStackView().then(){
        $0.axis = .vertical
        $0.spacing = 30
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        constraintLayout()
        
    }
    func constraintLayout(){
        view.addSubview(backGroundView)
        backGroundView.addSubview(stackView)
        
        [profileImage, nameLabel].forEach(){
            stackView.addArrangedSubview($0)
        }
        
        backGroundView.snp.makeConstraints(){
            $0.edges.equalTo(view)
        }
        stackView.snp.makeConstraints(){
            $0.center.equalTo(backGroundView)
            $0.left.right.equalTo(backGroundView).inset(48)
        }
        profileImage.snp.makeConstraints(){
            $0.width.height.equalTo(211)
        }
        nameLabel.snp.makeConstraints(){
            $0.edges.equalToSuperview()
        }
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
        
        let subLabelColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightgray") : UIColor(named: "lightblack")

    }
}

