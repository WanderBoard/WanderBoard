//
//  MyPageTableViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit

class MyPageTableViewCell: UITableViewCell {
    static let identifier = "MyPageTableViewCell"
    let icon = UIImageView()
    let label = UILabel()
    let arrow = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        constraintLayout()//두번째로 init에 함수호출
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func configureContent(for index: Int) {
        switch index {

            case 0:
                icon.image = UIImage(systemName: "gearshape.fill")
                icon.tintColor = .font
                label.text = "환경설정"
                label.font = UIFont.systemFont(ofSize: 15)
                label.textColor = .font
                arrow.image = UIImage(systemName: "chevron.right")
                arrow.tintColor = .font
                
            case 1:
                icon.image = UIImage(systemName: "info.circle")
                icon.tintColor = .font
                label.font = UIFont.systemFont(ofSize: 15)
                label.textColor = .font
                label.text = "이용약관 및 개인정보처리방침"
                arrow.image = UIImage(systemName: "chevron.right")
                arrow.tintColor = .font
                
            case 2:
                icon.image = UIImage(systemName: "info.circle.fill")
                icon.tintColor = .font
                label.font = UIFont.systemFont(ofSize: 15)
                label.textColor = .font
                label.text = "마케팅활용동의 및 광고 수신동의"
                arrow.image = UIImage(systemName: "chevron.right")
                arrow.tintColor = .font
                
          
            case 3:
                icon.image = UIImage(systemName: "nosign")
                icon.tintColor = .font
                label.font = UIFont.systemFont(ofSize: 15)
                label.textColor = .font
                label.text = "차단관리"
                arrow.image = UIImage(systemName: "chevron.right")
                arrow.tintColor = .font
          
            case 4:
            icon.isHidden = true
            arrow.isHidden = true
                label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textAlignment = .right
                label.textColor = UIColor(named: "PageCtrlUnselectedText")
                label.text = "로그아웃"
            label.snp.remakeConstraints(){
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().offset(-17)
            }
                
            default:
                print("셀의 내용이 없습니다")
        }
    }
    
    
    func constraintLayout(){
        self.contentView.addSubview(icon)
        self.contentView.addSubview(label)
        self.contentView.addSubview(arrow)
        
        icon.snp.makeConstraints(){
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
            $0.left.equalToSuperview().offset(17)
            
        }
        label.snp.makeConstraints(){
            $0.centerY.equalToSuperview()
            $0.left.equalTo(icon.snp.right).offset(23)
        }
        arrow.snp.makeConstraints(){
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-22)
        }
    }
    
}
