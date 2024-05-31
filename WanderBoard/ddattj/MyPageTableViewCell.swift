//
//  MyPageTableViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit

class MyPageTableViewCell: UITableViewCell {
    static let identifier = "MyPageTableViewCell"
    let background = UIView().then(){
        $0.backgroundColor = .babygray
        $0.layer.cornerRadius = 10
    }
    let icon = UIImageView()
    let label = UILabel()
    
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
            icon.image = UIImage(systemName: "pin.circle.fill")
            icon.tintColor = .tintColor
            label.text = "핀 목록"
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .tintColor
            
        case 1:
            icon.image = UIImage(systemName: "gearshape.fill")
            icon.tintColor = .tintColor
            label.text = "환경설정"
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .tintColor
            
        case 2:
            icon.image = UIImage(systemName: "creditcard.fill")
            icon.snp.remakeConstraints(){
                $0.centerY.equalTo(background)
                $0.width.equalTo(20)
                $0.height.equalTo(14.74)
                $0.left.equalTo(background).offset(17)
            }
            icon.tintColor = .tintColor
            label.text = "계좌연결"
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .tintColor
            
        case 3:
            icon.image = UIImage(systemName: "info.circle.fill")
            icon.tintColor = .tintColor
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .tintColor
            label.text = "개인정보처리방침"

        case 4:
            icon.image = UIImage(systemName: "door.left.hand.open")
            icon.snp.remakeConstraints(){ //오토레이아웃 리메이크
                $0.centerY.equalTo(background)
                $0.width.equalTo(16)
                $0.height.equalTo(22.59)
                $0.left.equalTo(background).offset(19)
            }
            icon.tintColor = .tintColor
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .tintColor
            label.text = "로그아웃"
            
        default:
            print("셀의 내용이 없습니다")
        }
    }
    
    func constraintLayout(){
        self.contentView.addSubview(background) //셀안에 들어가는 서브뷰는 contentView 앞에 붙여주기 //이것때문에 오류났다 우선적으로 contentView 붙여주고
        self.contentView.addSubview(icon)
        self.contentView.addSubview(label)
        
        background.snp.makeConstraints(){
            $0.left.right.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        icon.snp.makeConstraints(){
            $0.centerY.equalTo(background)
            $0.width.height.equalTo(20)
            $0.left.equalTo(background).offset(17)
            
        }
        label.snp.makeConstraints(){
            $0.centerY.equalTo(background)
            $0.left.equalTo(icon.snp.right).offset(23)
        }
        
    }
}
