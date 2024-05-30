//
//  MyPageViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/28/24.
//

import UIKit
import SnapKit
import Then

class MyPageViewController: BaseViewController {
    
    let btn = backButton()
    let btn2 = actionButton()
    let profile = UIImageView()
    let myName = UILabel()
    let myID = UILabel()
    let statusB = UIView()
    let myWrite = UILabel()
    let myPin = UILabel()
    let myExpend = UILabel()
    let status1 = UILabel()
    let status2 = UILabel()
    let status3 = UILabel()
    let tableView = UITableView().then(){
        $0.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        constraintLayout()
    }
    
    override func configureUI() {
        super.configureUI()
        btn.label.text = "My trips"
        btn2.icon.image = UIImage(systemName: "pencil.circle")
        btn2.icon.snp.makeConstraints(){
            $0.width.height.equalTo(25)
            $0.right.equalTo(view).offset(-25)
        }
        myTitle.text = "마이페이지"
        
        profile.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
    }
    
    override func constraintLayout() {
        super.constraintLayout()
        [btn, btn2, profile, myName, myID, statusB, myWrite, myPin, myExpend, status1, status2, status3, tableView].forEach(){
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
        logo.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.bottom.equalTo(view).offset(-48)
        }
        profile.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.top.equalTo(myTitle.snp.bottom).offset(29)
            $0.width.height.equalTo(view.snp.height).multipliedBy(1.0/8.0)
        }
        myName.snp.makeConstraints(){
            $0.top.equalTo(profile.snp.bottom).offset(17)
            $0.centerX.equalTo(view)
        }
        myID.snp.makeConstraints(){
            $0.top.equalTo(myName.snp.bottom).offset(2)
            $0.centerX.equalTo(view)
        }
        statusB.snp.makeConstraints(){
            $0.top.equalTo(myID.snp.bottom).offset(19)
            $0.centerX.equalTo(view)
        }
    }
}

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageTableViewCell", for: indexPath) as? MyPageTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    
}
