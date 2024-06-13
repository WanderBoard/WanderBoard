//
//  PrivacyPolicyCollectionViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 6/3/24.
//

import UIKit

class PrivacyPolicyCollectionViewCell: UICollectionViewCell {
    static let identifier = "PrivacyPolicyCollectionViewCell"
    let scriptTitle = UILabel()
    let scriptBackground = UIView()
    let scrollView = UIScrollView()
    let script = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constraintLayout()
        configureUI()
        updateColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(){
        scriptTitle.text = "----------"
        scriptTitle.font = UIFont.boldSystemFont(ofSize: 15)
        scriptTitle.textColor = .font
        
        scriptBackground.backgroundColor = .babygray
        scriptBackground.layer.cornerRadius = 10
        
        script.text = "신용 제35조 제2항에 따라 신용정보주체가 신용정보회사등에게 자신의 개인신용정보를 이용하거나 제공한 내용에 대하여 정기적인 통지를 요청할 수 있음을 알려주는 것은 인터넷 홈페이지의 개인정보처리방침 등에 게시하여 알릴 수 있습니다. 신용정보법 제35조 제2항에 따라 신용정보주체가 신용정보회사등에게 자신의 개인신용정보를 이용하거나 제공한 내용에 대하여 정기적인 통지를 요청할 수 있음을 알려주는 것은 인터넷 홈페이지의 개인정보처리방침 등에 게시하여 알릴 수 있습니다. 신용정보법 제35조 제2항에 따라 신용정보주체가 신용정보회사등에게 자신의 개인신용정보를 이용하거나 제공한 내용에 대하여 정기적인 통지를 요청할 수 있음을 알려주는 것은 인터넷 홈페이지의 개인정보처리방침 등에 게시하여 알릴 수 있습니다. 신용정보법 제35조 제2항에 따라 신용정보주체가 신용정보회사등에게 자신의 개인신용정보를 이용하거나 제공한 내용에 대하여 정기적인 통지를 요청할 수 있음을 알려주는 것은 인터넷 홈페이지의 개인정보처리방침 등에 게시하여 알릴 수 있습니다.신용정보법 제35조 제2항에 따라 신용정보주체가 신용정보회사등에게 자신의 개인신용정보를 이용하거나 제공한 내용에 대하여 정기적인 통지를 요청할 수 있음을 알려주는 것은 인터넷 홈페이지의 개인정보처리방침 등에 게시하여 알릴 수 있습니다."
        script.font = UIFont.systemFont(ofSize: 13)
        script.textColor = .font
        script.numberOfLines = 0
    }
    
    func constraintLayout(){
        [scriptTitle, scriptBackground, scrollView].forEach(){
            contentView.addSubview($0)
        }
        
        scriptTitle.snp.makeConstraints(){
            $0.top.equalToSuperview().offset(8)
            $0.left.equalToSuperview().offset(8)
        }
        scriptBackground.snp.makeConstraints(){
            $0.top.equalTo(scriptTitle.snp.bottom).offset(7)
            $0.left.right.equalToSuperview()
            $0.height.equalToSuperview().inset(12)
        }
        scrollView.snp.makeConstraints(){
            $0.top.equalTo(scriptBackground.snp.top).offset(20)
            $0.left.equalTo(scriptBackground.snp.left).offset(20)
            $0.right.equalTo(scriptBackground.snp.right).offset(-20)
            $0.bottom.equalTo(scriptBackground.snp.bottom).offset(-22)
        }
        scrollView.addSubview(script)
        script.snp.makeConstraints(){
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView.snp.width)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // 이전 trait collection과 현재 trait collection이 다를 경우 업데이트
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        let scriptBackgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
        scriptBackground.backgroundColor = scriptBackgroundColor
    }
}
