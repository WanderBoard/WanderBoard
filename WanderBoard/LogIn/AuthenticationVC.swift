//
//  AuthenticationVC.swift
//  WanderBoard
//
//  Created by David Jang on 5/29/24.
//

import UIKit
import GoogleSignIn
import AuthenticationServices
import SnapKit
import KakaoSDKUser
import FirebaseFirestore

class AuthenticationVC: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let text = "발걸음마다 기록하는\n나만의 여행 일지."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // 줄간격 설정
        
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                .paragraphStyle: paragraphStyle
            ]
        )
        
        label.attributedText = attributedText
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    private lazy var kakaoLoginButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "카카오 로그인"
        configuration.image = UIImage(named: "kakaoLogo")?.withRenderingMode(.alwaysOriginal)
        configuration.imagePadding = 8
        configuration.imagePlacement = .all
        configuration.baseBackgroundColor = UIColor(named: "kakaoYellow")
        configuration.baseForegroundColor = .black
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
        
        if let imageView = button.imageView, let titleLabel = button.titleLabel {
            
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(20) // 이미지 크기 조절
                make.centerY.equalTo(button.snp.centerY)
                make.trailing.equalTo(titleLabel.snp.leading).inset(-16)
            }
            titleLabel.snp.makeConstraints { make in
                make.centerX.equalTo(button.snp.centerX).offset(16)
                make.centerY.equalTo(button.snp.centerY)
            }
        }
        
        return button
    }()
    
    private lazy var googleSignInButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "구글 로그인"
        configuration.image = UIImage(named: "googleLogo")?.withRenderingMode(.alwaysOriginal)
        configuration.imagePadding = 8
        configuration.imagePlacement = .all
        configuration.baseBackgroundColor = UIColor(named: "babygray")
        configuration.baseForegroundColor = .black
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
        
        if let imageView = button.imageView, let titleLabel = button.titleLabel {
            
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(20) // 이미지 크기 조절
                make.centerY.equalTo(button.snp.centerY)
                make.trailing.equalTo(titleLabel.snp.leading).inset(-16)
            }
            titleLabel.snp.makeConstraints { make in
                make.centerX.equalTo(button.snp.centerX).offset(16)
                make.centerY.equalTo(button.snp.centerY)
            }
        }
        
        return button
    }()
    
    private lazy var appleSignInButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Apple 로그인"
        configuration.image = UIImage(named: "appleLogo")?.withRenderingMode(.alwaysOriginal)
        configuration.imagePadding = 8
        configuration.imagePlacement = .all
        configuration.baseBackgroundColor = UIColor(named: "ButtonColor")
        configuration.baseForegroundColor = UIColor(named: "textColor")
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
        
        if let imageView = button.imageView, let titleLabel = button.titleLabel {
            
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(20) // 이미지 크기 조절
                make.centerY.equalTo(button.snp.centerY)
                make.trailing.equalTo(titleLabel.snp.leading).inset(-16)
            }
            titleLabel.snp.makeConstraints { make in
                make.centerX.equalTo(button.snp.centerX).offset(16)
                make.centerY.equalTo(button.snp.centerY)
            }
        }
        
        return button
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        let text = "By clicking continue, you agree to our \nTerms of Service and Privacy Policy"
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.foregroundColor, value: UIColor(named: "textColorSub") ?? .red, range: (text as NSString).range(of: "Terms of Service"))
        attributedText.addAttribute(.foregroundColor, value: UIColor(named: "textColorSub") ?? .red, range: (text as NSString).range(of: "Privacy Policy"))
        label.attributedText = attributedText
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupViews()
        addGestureRecognizers()
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(logoImageView)
        view.addSubview(kakaoLoginButton)
        view.addSubview(appleSignInButton)
        view.addSubview(googleSignInButton)
        view.addSubview(termsLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.left.equalToSuperview().inset(47)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(42)
            //            make.right.equalToSuperview().inset(39)
            make.height.equalTo(34)
            //            make.width.equalTo(logoImageView.snp.width).multipliedBy(0.8)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.bottom.equalTo(appleSignInButton.snp.top).offset(-16)
            make.left.right.equalToSuperview().inset(47)
            make.height.equalTo(50)
        }
        
        appleSignInButton.snp.makeConstraints { make in
            make.bottom.equalTo(googleSignInButton.snp.top).offset(-16)
            make.left.right.equalToSuperview().inset(47)
            make.height.equalTo(50)
        }
        
        googleSignInButton.snp.makeConstraints { make in
            make.bottom.equalTo(termsLabel.snp.top).offset(-16)
            make.left.right.equalToSuperview().inset(47)
            make.height.equalTo(50)
        }
        
        termsLabel.snp.makeConstraints { make in
            //            make.top.equalTo(googleSignInButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(47)
            make.bottom.equalToSuperview().inset(48)
        }
        
        kakaoLoginButton.addTarget(self, action: #selector(signInKakaoTapped), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(signInAppleTapped), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(signInGoogleTapped), for: .touchUpInside)
    }
    
    private func addGestureRecognizers() {
//        _ = (termsLabel.text! as NSString).range(of: "Terms of Service")
//        _ = (termsLabel.text! as NSString).range(of: "Privacy Policy")

        let termsTapGesture = UITapGestureRecognizer(target: self, action: #selector(termsOfServiceTapped))
        termsLabel.addGestureRecognizer(termsTapGesture)

        let privacyTapGesture = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyTapped))
        termsLabel.addGestureRecognizer(privacyTapGesture)
    }
    
    @objc private func termsOfServiceTapped() {
        let termsVC = TermsOfServiceViewController()
        termsVC.modalPresentationStyle = .formSheet
        present(termsVC, animated: true, completion: nil)
    }

    @objc private func privacyPolicyTapped() {
        let termsVC = TermsOfServiceViewController()
        termsVC.modalPresentationStyle = .formSheet
        present(termsVC, animated: true, completion: nil)    }
    
    @objc private func signInKakaoTapped() {
        Task {
            do {
                let helper = SignInWithKakaoHelper()
                let result = try await helper.signIn()
                if let email = result.email {
                    var authDataResult: AuthDataResultModel
                    do {
                        authDataResult = try await AuthenticationManager.shared.signInWithEmailAndPassword(email: email, password: "임시비밀번호")
                        // Firestore에서 사용자 문서 확인
                        let existingUser = try await FirestoreManager.shared.checkUserExists(email: email)
                        let isProfileComplete = existingUser?.isProfileComplete ?? false
                        
                        if existingUser != nil {
                            // 기존 사용자라면 displayName을 업데이트하지 않음
                            try await FirestoreManager.shared.saveUser(
                                uid: authDataResult.uid,
                                email: email,
                                displayName: nil,
                                photoURL: result.profileImageUrl?.absoluteString,
                                socialMediaLink: nil,
                                authProvider: AuthProviderOption.kakao.rawValue,
                                gender: "선택안함",
                                interests: [],
                                isProfileComplete: isProfileComplete, 
                                blockedAuthors: authDataResult.blockedAuthors,
                                hiddenPinLogs: []
                            )
                        } else {
                            // 새로운 사용자라면 displayName을 포함하여 저장
                            try await FirestoreManager.shared.saveUser(
                                uid: authDataResult.uid,
                                email: email,
                                displayName: result.nickname,
                                photoURL: result.profileImageUrl?.absoluteString,
                                socialMediaLink: nil,
                                authProvider: AuthProviderOption.kakao.rawValue,
                                gender: "선택안함",
                                interests: [],
                                isProfileComplete: isProfileComplete, 
                                blockedAuthors: authDataResult.blockedAuthors,
                                hiddenPinLogs: []
                            )
                        }
                        // Firestore 정보 업데이트
                        try await UserProfileManager.shared.updateUserProfileFromFirestore()
                        await handleSignInResult(authDataResult, isProfileComplete: isProfileComplete)
                    } catch {
                        authDataResult = try await AuthenticationManager.shared.createUserWithEmailAndPassword(email: email, password: "임시비밀번호")
                        // 새로운 사용자라면 displayName을 포함하여 저장
                        try await FirestoreManager.shared.saveUser(
                            uid: authDataResult.uid,
                            email: email,
                            displayName: result.nickname,
                            photoURL: result.profileImageUrl?.absoluteString,
                            socialMediaLink: nil,
                            authProvider: AuthProviderOption.kakao.rawValue,
                            gender: "선택안함",
                            interests: [],
                            isProfileComplete: false, 
                            blockedAuthors: authDataResult.blockedAuthors,
                            hiddenPinLogs: []
                        )
                        await handleSignUpResult(authDataResult, isProfileComplete: false)
                    }
                } else {
                    print("이메일 정보가 없습니다.")
                }
            } catch {
                print("카카오 로그인 실패: \(error)")
            }
        }
    }
  
    @objc private func signInGoogleTapped() {
        Task {
            do {
                guard let helper = SignInWithGoogleHelper() else { return }
                
                let tokens = try await helper.signIn()
                let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
                let existingUser = try await FirestoreManager.shared.checkUserExists(email: tokens.email ?? "")
                let isProfileComplete = existingUser?.isProfileComplete ?? false
                if let existingUser = existingUser {
                    await handleSignInResult(AuthDataResultModel(user: existingUser, authProvider: .google), isProfileComplete: isProfileComplete)
                } else {
                    try await FirestoreManager.shared.saveUser(uid: authDataResult.uid, email: tokens.email ?? "", authProvider: AuthProviderOption.google.rawValue, gender: "선택안함", interests: [], isProfileComplete: false, blockedAuthors: authDataResult.blockedAuthors, hiddenPinLogs: [])
                    await handleSignUpResult(authDataResult, isProfileComplete: false)
                }
            } catch {
                print("구글 로그인 실패: \(error)")
            }
        }
    }
    
    @objc private func signInAppleTapped() {
        Task {
            do {
                let helper = SignInWithAppleHelper()
                let result = try await helper.startSignInWithAppleFlow()
                let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: result)
                let existingUser = try await FirestoreManager.shared.checkUserExists(email: result.email ?? "")
                let isProfileComplete = existingUser?.isProfileComplete ?? false
                if let existingUser = existingUser {
                    await handleSignInResult(AuthDataResultModel(user: existingUser, authProvider: .apple), isProfileComplete: isProfileComplete)
                } else {
                    try await FirestoreManager.shared.saveUser(uid: authDataResult.uid, email: result.email ?? "", authProvider: AuthProviderOption.apple.rawValue, gender: "선택안함", interests: [], isProfileComplete: false, blockedAuthors: authDataResult.blockedAuthors, hiddenPinLogs: [])
                    await handleSignUpResult(authDataResult, isProfileComplete: false)
                }
            } catch {
                print("Apple 로그인 실패: \(error)")
            }
        }
    }
    
    // 로그인 결과 처리
    private func handleSignInResult(_ authDataResult: AuthDataResultModel, isProfileComplete: Bool) async {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        if isProfileComplete,
           let email = authDataResult.email, !email.isEmpty,
           let gender = authDataResult.gender, !gender.isEmpty,
           let interests = authDataResult.interests, !interests.isEmpty {
            switchRootView(to: PageViewController())
        } else {
            presentSignUpViewController()
        }
    }
    
    private func handleSignUpResult(_ authDataResult: AuthDataResultModel, isProfileComplete: Bool) async {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        presentSignUpViewController()
    }
    
    private func presentSignUpViewController() {
        let signUpVC = SignUpViewController()
        let navController = UINavigationController(rootViewController: signUpVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    private func switchRootView(to viewController: UIViewController) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }
        window.rootViewController = UINavigationController(rootViewController: viewController)
        window.makeKeyAndVisible()
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        animateButton(sender, transform: CGAffineTransform(scaleX: 0.95, y: 0.95))
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        animateButton(sender, transform: CGAffineTransform.identity)
    }
    
    private func animateButton(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = transform
        })
    }
}

// 애플 인증 로그인 관련 프로토콜
extension AuthenticationVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
}
