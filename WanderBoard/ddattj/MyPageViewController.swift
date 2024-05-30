//
//  MyPageViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/28/24.
//

import UIKit
import SnapKit
import Then
import SwiftUI

//미리보기 화면
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
struct MyViewController_PreViews: PreviewProvider {
    static var previews: some View {
        MyPageViewController().toPreview() //원하는 VC를 여기다 입력하면 된다.
    }
}

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
        $0.backgroundColor = .blue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        constraintLayout()
        tableView.register(MyPageTableViewCell.self, forCellReuseIdentifier: MyPageTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func configureUI() {
        super.configureUI()
        btn.label.text = "My trips"
        btn2.icon.image = UIImage(systemName: "pencil.circle")
        btn2.icon.snp.makeConstraints(){
            $0.width.height.equalTo(25)
            $0.right.equalTo(view).offset(-25)
        }
//        btn2.addTarget(self, action: #selector(editMode), for: .touchUpInside)
        
        myTitle.text = "마이페이지"
        
        profile.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        profile.clipsToBounds = true
        profile.layer.cornerRadius = profile.frame.size.width / 2
        
        myName.text = "내이름"
        myName.font = UIFont.boldSystemFont(ofSize: 22)
        myID.textColor = .font
        
        myID.text = "@아이디 적는곳\(0)"
        myID.font = UIFont.systemFont(ofSize: 13)
        myID.textColor = .font
        
        //다크모드 색상까지 같이 지정
        statusB.backgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.darkgray : UIColor.customblack
        statusB.layer.shadowOffset = CGSize(width: 0, height: 4)
        statusB.layer.cornerRadius = 10
        statusB.layer.shadowRadius = 4
        statusB.layer.shadowOpacity = 0.25
        
        myWrite.text = "\(1)"
        myWrite.font = UIFont.systemFont(ofSize: 13)
        myWrite.textColor = .white
        myPin.text = "\(1)"
        myPin.font = UIFont.systemFont(ofSize: 13)
        myPin.textColor = .white
        myExpend.text = "\(1)"
        myExpend.font =  UIFont.systemFont(ofSize: 13)
        myExpend.textColor = .white
        
        status1.text = "작성한 글"
        status1.font = UIFont.systemFont(ofSize: 13)
        status1.textColor = .white
        status2.text = "핀 개수"
        status2.font = UIFont.systemFont(ofSize: 13)
        status2.textColor = .white
        status3.text = "평균사용금액"
        status3.font = UIFont.systemFont(ofSize: 13)
        status3.textColor = .white
        
        tableView.separatorStyle = .none //테이블뷰 구분선 없앨때 사용
        
        
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
            $0.top.equalTo(myName.snp.bottom).offset(5)
            $0.centerX.equalTo(view)
        }
        statusB.snp.makeConstraints(){
            $0.top.equalTo(myID.snp.bottom).offset(19)
            $0.centerX.equalTo(view)
            $0.width.equalTo(360)
            $0.height.equalTo(91)
        }
        myWrite.snp.makeConstraints(){
            $0.top.equalTo(statusB.snp.top).offset(23)
            $0.centerX.equalTo(status1.snp.centerX)
        }
        myPin.snp.makeConstraints(){
            $0.top.equalTo(statusB.snp.top).offset(23)
            $0.centerX.equalTo(view)
        }
        myExpend.snp.makeConstraints(){
            $0.top.equalTo(statusB.snp.top).offset(23)
            $0.centerX.equalTo(status3.snp.centerX)
        }
        status1.snp.makeConstraints(){
            $0.bottom.equalTo(statusB.snp.bottom).inset(23)
            $0.left.equalTo(statusB.snp.left).offset(31)
        }
        status2.snp.makeConstraints(){
            $0.bottom.equalTo(statusB.snp.bottom).inset(23)
            $0.centerX.equalTo(view)
        }
        status3.snp.makeConstraints(){
            $0.bottom.equalTo(statusB.snp.bottom).inset(23)
            $0.right.equalTo(statusB.snp.right).offset(-31)
        }
        tableView.snp.makeConstraints(){
            $0.top.equalTo(statusB.snp.bottom).offset(29)
            $0.width.equalTo(318)
            $0.centerX.equalTo(view)
            $0.bottom.equalTo(logo.snp.top).offset(-23)
        }
    }
    
    @objc func editMode(){
        let editStart = EditViewController()
        navigationController?.pushViewController(editStart, animated: true)
    }
    
}

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPageTableViewCell.identifier, for: indexPath) as? MyPageTableViewCell else {
            return UITableViewCell()
        }
        cell.configureContent(for: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        63
    }
    
    //각 셀마다 이동할 화면 지정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let pinListVC = PinListViewController()
            navigationController?.pushViewController(pinListVC, animated: true)
        case 1:
            let settingVC = SettingViewController()
            navigationController?.pushViewController(settingVC, animated: true)
        case 2:
            let billingVC = BillingAccountViewController()
            navigationController?.pushViewController(billingVC, animated: true)
        case 3:
            let policyVC = PrivacyPolicyViewController()
            navigationController?.pushViewController(policyVC, animated: true)
        case 4:
            func setAlert(){
                print("로그아웃")
            }
            
        default:
            print("Wrong Way!")
        }
    }
}
