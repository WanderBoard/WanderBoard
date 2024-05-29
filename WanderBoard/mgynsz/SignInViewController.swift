//
//  SignInViewController.swift
//  WanderBoard
//
//  Created by David Jang on 5/28/24.
//

import UIKit
import SnapKit
import SwiftUI
import FirebaseAuth

class SignInViewController: UIViewController {

    private let successLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인 성공"
        label.font = UIFont.systemFont(ofSize: 34, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        button.setTitleColor(.red, for: .normal)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }

    private func setupViews() {
        view.addSubview(successLabel)
        view.addSubview(logoutButton)

        successLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            make.left.right.equalToSuperview().inset(20)
        }

        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(successLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
    }

    @objc private func logoutButtonTapped() {
        Task {
            do {
                try AuthenticationManager.shared.signOut()
                switchRootView(to: AuthenticationVC())
            } catch {
                
            }
        }
    }

    private func switchRootView(to viewController: UIViewController) {
        guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else { return }
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
