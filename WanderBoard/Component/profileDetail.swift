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
        $0.backgroundColor = .font
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        constraintLayout()
        updateColor()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissModal))
    }
    
    func constraintLayout(){
        view.addSubview(backGroundView)
        [profileImage, nameLabel].forEach(){
            backGroundView.addSubview($0)
        }
        backGroundView.snp.makeConstraints(){
            $0.edges.equalTo(view)
        }
        profileImage.snp.makeConstraints(){
            $0.centerY.equalToSuperview().offset(-70)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(211)
            $0.left.right.equalToSuperview().inset(90)
        }
        nameLabel.snp.makeConstraints(){
            $0.top.equalTo(profileImage.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
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
    }
    
    @objc func dismissModal() {
            dismiss(animated: true, completion: nil)
        }
    
    func configureUI(with nickname: String) {
        nameLabel.text = nickname
        fetchProfileData(for: nickname)
    }
    
    //닉네임을 uid로 사용해 같은 닉네임을 가진 유저가 존재하면 유저의 닉네임과 이미지를 가져오는 메서드
    private func fetchProfileData(for nickname: String) {
        Task {
            do {
                let user = try await FirestoreManager.shared.checkUserExistsByUID(uid: nickname)
                if let user = user, let imageUrlString = user.photoURL, let imageUrl = URL(string: imageUrlString) {
                    DispatchQueue.global().async {
                        if let imageData = try? Data(contentsOf: imageUrl) {
                            DispatchQueue.main.async {
                                self.profileImage.image = UIImage(data: imageData)
                            }
                        }
                    }
                }
            } catch {
                print("Error fetching user data: \(error)")
            }
        }
    }
}

