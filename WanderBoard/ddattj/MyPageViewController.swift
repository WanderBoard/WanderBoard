//
//  MyPageViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/28/24.
//

import UIKit
import SnapKit
import Then
import CoreData
import FirebaseAuth
import FirebaseFirestore

class MyPageViewController: BaseViewController, PageIndexed {
    var pageIndex: Int?
    
    let editButton = UIButton()
    var profile = UIImageView()
    var myName = UILabel()
    var myID = UILabel()
    let statusB = UIView()
    var myPin = UILabel()
    var tagPin = UILabel()
    var wanderPin = UILabel()
    let status1 = UILabel()
    let status2 = UILabel()
    let status3 = UILabel()
    let tableView = UITableView().then(){
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false //스크롤 비활성화
    }
    var userData: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.register(MyPageTableViewCell.self, forCellReuseIdentifier: MyPageTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        configureUI()
        fetchUserData()
        fetchAndDisplayUserPinCount() // 핀 개수 가져오기 및 UI 업데이트
        fetchInvitationCount()
    }
    
    
    func fetchUserData() {
        Task {
            do {
                if let authUser = try? AuthenticationManager.shared.getAuthenticatedUser(), let email = authUser.email {
                    userData = try await FirestoreManager.shared.checkUserExists(email: email)
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                }
            } catch {
                print("유저데이터를 받아오는데 실패했습니다")
            }
        }
    }
    
    func fetchInvitationCount() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        FirestoreManager.shared.fetchInvitations(for: userId) { [weak self] result in
            switch result {
            case .success(let invitations):
                DispatchQueue.main.async {
                    self?.tagPin.text = "\(invitations.count)"
                }
            case .failure(_):
                print("태그된 게시물을 받아오지 못했습니다.")
            }
        }
    }
    
    
    //파이어스토어 -> 아이디 확인 -> 내가 핀 한 게시글 수 구하는 함수를 거친 myPinCount의 정보 가져옥 -> 마이핀에 저장
    func fetchAndDisplayUserPinCount() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                let pinCount = try await FirestoreManager.shared.fetchUserPinCount(userId: currentUserId)
                DispatchQueue.main.async {
                    self.wanderPin.text = "\(pinCount)"
                }
                try await FirestoreManager.shared.updateUserPinCount(userId: currentUserId, pinCount: pinCount)
            } catch {
                print("핀 개수를 가져오거나 업데이트하는 데 실패했습니다: \(error)")
            }
        }
    }

    
    //페이지 컨트롤러 때문에 추가했습니다 -한빛

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": false])
        NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": true])
    }
    
    override func constraintLayout() {
        [profile, myName, myID, statusB, myPin, tagPin, wanderPin, status1, status2, status3, tableView].forEach(){
            view.addSubview($0)
        }
        profile.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.top.equalTo(view).offset(112)
            $0.width.height.equalTo(106)
        }
        myName.snp.makeConstraints(){
            $0.top.equalTo(profile.snp.bottom).offset(19)
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
        myPin.snp.makeConstraints(){
            $0.top.equalTo(statusB.snp.top).offset(23)
            $0.centerX.equalTo(status1.snp.centerX)
        }
        tagPin.snp.makeConstraints(){
            $0.top.equalTo(statusB.snp.top).offset(23)
            $0.centerX.equalTo(view)
        }
        wanderPin.snp.makeConstraints(){
            $0.top.equalTo(statusB.snp.top).offset(23)
            $0.centerX.equalTo(status3.snp.centerX)
        }
        status1.snp.makeConstraints(){
            $0.bottom.equalTo(statusB.snp.bottom).inset(24)
            $0.left.equalTo(statusB.snp.left).offset(46)
        }
        status2.snp.makeConstraints(){
            $0.bottom.equalTo(statusB.snp.bottom).inset(24)
            $0.centerX.equalTo(view)
        }
        status3.snp.makeConstraints(){
            $0.bottom.equalTo(statusB.snp.bottom).inset(24)
            $0.right.equalTo(statusB.snp.right).offset(-28)
        }
        tableView.snp.makeConstraints(){
            $0.top.equalTo(statusB.snp.bottom).offset(33)
            $0.horizontalEdges.equalToSuperview().inset(32)
            $0.bottom.equalTo(view).offset(-173)

        }
    }
    
    override func configureUI() {
        
        editButton.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        editButton.tintColor = .font
        editButton.imageView?.snp.makeConstraints(){
            $0.width.height.equalTo(30)
        }
        editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: editButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        profile.layer.cornerRadius = 53
        profile.clipsToBounds = true
        profile.backgroundColor = .lightgray
        
        myName.font = UIFont.boldSystemFont(ofSize: 20)
        myName.textColor = .font
        
        myID.font = UIFont.systemFont(ofSize: 13)
        myID.textColor = .font
        
        statusB.backgroundColor = .customblack
        statusB.layer.cornerRadius = 10
        statusB.layer.shadowOffset = CGSize(width: 0, height: 4)
        statusB.layer.shadowRadius = 4
        statusB.layer.shadowOpacity = 0.25
        
        myPin.text = "\(MyTripsViewController.tripLogs.count)"
        myPin.font = UIFont.boldSystemFont(ofSize: 15)
        myPin.textColor = .white
        tagPin.font = UIFont.boldSystemFont(ofSize: 15)
        tagPin.textColor = .white
        wanderPin.font =  UIFont.boldSystemFont(ofSize: 15)
        wanderPin.textColor = .white
        
        status1.text = "My Pin"
        status1.font = UIFont.systemFont(ofSize: 13)
        status1.textColor = .white
        status2.text = "Tag Pin"
        status2.font = UIFont.systemFont(ofSize: 13)
        status2.textColor = .white
        status3.text = "Wander Pin"
        status3.font = UIFont.systemFont(ofSize: 13)
        status3.textColor = .white
        
        tableView.backgroundColor = .clear
        
        // userData가 있으면 userData에 맞게 업데이트
        //userData가 없을 경우 위의 기능은 정상적으로 수행하고 만약 값이 있을 경우엔 중괄호 내부의 역할을 수행해줄것을 요청
        if let userData = userData {
            profile.image = UIImage(named: "\(String(describing: userData.photoURL))")
            myName.text = userData.displayName
            myID.text = userData.email
        }
    }
    
    
    func updateUI() {
        guard let userData = userData else { return }
        myName.text = userData.displayName
        myID.text = userData.email
        
        //URLSession 사용해서 URL 이미지 다운로드 후 프로필 이미지에 설정해준다.
        if let photoURLString = userData.photoURL, let photoURL = URL(string: photoURLString) {
            downloadImage(from: photoURL) { [weak self] image in
                DispatchQueue.main.async {
                    self?.profile.image = image
                }
            }
        } else {
            profile.image = UIImage(named: "defaultProfileImage")
        }
    }
    
    //이미지 다운로드 메서드
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }.resume()
    }
    
    
    @objc func edit(){
        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": true]) // 페이지 컨트롤러 때문에.. - 한빛
        NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": false]) // 화면 전환 스크롤 제거 - 한빛
        let editVC = EditViewController()
        editVC.previousName = myName.text ?? "no Name"
        editVC.ID = myID.text ?? "No ID"
        editVC.previousImage = profile.image
        editVC.userData = self.userData //여기서 쓰인 userData, editVC의 userData로 넘겨주기
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    override func updateColor(){
        let profileColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "lightgray")
        profile.backgroundColor = profileColor
        
        //다크모드 변경시 네비게이션 바도 색상을 배경과 같게 만들어주기
        let navbarAppearance = UINavigationBarAppearance()
        navbarAppearance.configureWithOpaqueBackground()
        let navBarColor = traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.clear
        navbarAppearance.backgroundColor = navBarColor
        navigationController?.navigationBar.standardAppearance = navbarAppearance
    }
    
    //에딧창에서 추가해준 이름과 사진 불러오기
    func updateUserData(name: String, image: UIImage?) {
        myName.text = name
        profile.image = image ?? UIImage(named: "defaultProfileImage")
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
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    //각 셀마다 이동할 화면 지정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 버튼과 같은 느낌을 주기 위해 튀어오르는 효과 애니메이션 추가
        // 다음엔 그렇게 많지 않다면 버튼으로 하자..
        // 우선 '셀'은 테이블뷰의 셀이라고 알려주기
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        // 눌렀을 때 셀의 사이즈를 확대했다가 다시 원상태로 돌아가는 효과 넣기
        UIView.animate(withDuration: 0.05, animations: {
            cell.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: { _ in
            UIView.animate(withDuration: 0.05, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: { _ in
                // 애니메이션이 완료된 후에 ViewController를 푸시
                switch indexPath.row {

                    case 0:
                        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": true]) // 페이지 컨트롤러.. -한빛
                        NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": false]) // 화면전환 스크롤 false - 한빛
                        let settingVC = SettingViewController()
                        self.navigationController?.pushViewController(settingVC, animated: true)
                        settingVC.navigationItem.title = "환경설정"
                    case 1:
                        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": true]) // 페이지 컨트롤러.. -한빛
                        NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": false]) // 화면전환 스크롤 false - 한빛
                        let policyVC = ConsentStatusViewController()
                        self.navigationController?.pushViewController(policyVC, animated: true)
                        policyVC.navigationItem.title = "이용약관 및 개인정보처리방침"
                    case 2:
                        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": true]) // 페이지 컨트롤러.. -한빛
                        NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": false]) // 화면전환 스크롤 false - 한빛
                        let policyVC = ConsentStatusViewController()
                        self.navigationController?.pushViewController(policyVC, animated: true)
                        policyVC.navigationItem.title = "마케팅활용동의 및 광고수신동의"
                     case 3:
                         NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": true]) // 페이지 컨트롤러.. -한빛
                         NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": false]) // 화면전환 스크롤 false - 한빛
                         let blockVC = BlockViewController()
                         self.navigationController?.pushViewController(blockVC, animated: true)
                         blockVC.navigationItem.title = "차단관리"
                    case 4:
                        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": true]) // 페이지 컨트롤러.. -한빛
                        NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": false]) // 화면전환 스크롤 false - 한빛
                        let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: "로그인 창으로 이동합니다", preferredStyle: .alert)
                        let confirm = UIAlertAction(title: "확인", style: .default) { _ in
                            let logOutVC = AuthenticationVC()
                            if let transition = self.transition {
                                self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                            }
                            self.navigationController?.pushViewController(logOutVC, animated: false)
                            self.navigationController?.navigationBar.isHidden = true

                        }
                        let close = UIAlertAction(title: "취소", style: .destructive, handler: nil)
                        
                        alert.addAction(close)
                        alert.addAction(confirm)
                        self.present(alert, animated: true, completion: nil)
                    default:
                        print("Wrong Way!")
                }
            })
        })
    }
    
}
