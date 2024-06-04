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
        scriptTitle.font = UIFont.boldSystemFont(ofSize: 15)
        scriptTitle.textColor = .font
        
        scriptBackground.backgroundColor = .babygray
        scriptBackground.layer.cornerRadius = 10
        
        script.font = UIFont.systemFont(ofSize: 13)
        script.textColor = .font
    }
    
    func updateColor(){
        scriptBackground.backgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
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
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalToSuperview().inset(12)
        }
        scrollView.snp.makeConstraints(){
            $0.top.equalTo(scriptBackground.snp.top).offset(15)
            $0.horizontalEdges.equalTo(scriptBackground.snp.horizontalEdges).inset(15)
            $0.bottom.equalTo(scriptBackground.snp.bottom).offset(-17)
        }
        scrollView.addSubview(script)
        script.snp.makeConstraints(){
            $0.edges.equalTo(scrollView)
        }
    }
}
