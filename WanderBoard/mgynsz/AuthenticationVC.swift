//
//  AuthenticationVC.swift
//  WanderBoard
//
//  Created by David Jang on 5/29/24.
//


//242번 연결 컨트롤러 바꿈

import UIKit
import GoogleSignIn
import AuthenticationServices
import SnapKit
import KakaoSDKUser

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
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupViews()
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
    
    @objc private func signInKakaoTapped() {
        Task {
            do {
                let helper = SignInWithKakaoHelper()
                let result = try await helper.signIn()
                if let email = result.email {
                    // 이미 존재하는 계정인지 확인하고, 없다면 새로 생성
                    do {
                        let authDataResult = try await signInWithEmailAndPassword(email: email, password: "임시비밀번호") // 임시비밀번호는 사용자에게 별도로 안내
                        // 로그인 성공 처리
                        // 사용자 정보를 Firestore에 저장
                        try await FirestoreManager.shared.saveUser(uid: authDataResult.uid, email: email, displayName: result.nickname, photoURL: result.profileImageUrl?.absoluteString, socialMediaLink: nil, authProvider: AuthProviderOption.kakao.rawValue)
                    } catch {
                        let authDataResult = try await createUserWithEmailAndPassword(email: email, password: "임시비밀번호")
                        // 회원가입 성공 처리
                        // 사용자 정보를 Firestore에 저장
                        try await FirestoreManager.shared.saveUser(uid: authDataResult.uid, email: email, displayName: result.nickname, photoURL: result.profileImageUrl?.absoluteString, socialMediaLink: nil, authProvider: AuthProviderOption.kakao.rawValue)
                    }
                } else {
                    // 이메일 정보가 없는 경우 처리
                    print("이메일 정보가 없습니다.")
                }
                //switchRootView(to: SignInViewController())
                switchRootView(to: MyPageViewController())
            } catch {
                print("카카오 로그인 실패: \(error)")
            }
        }
    }

    @objc private func signInGoogleTapped() {
        Task {
            do {
                guard let helper = SignInWithGoogleHelper() else {
                    print("Failed to initialize Google Sign-In Helper.")
                    return
                }
                let tokens = try await helper.signIn()
                let _ = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                switchRootView(to: SignInViewController())
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
                let _ = try await AuthenticationManager.shared.signInWithApple(tokens: result)
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                switchRootView(to: SignInViewController())
            } catch {
                print("Apple 로그인 실패: \(error)")
            }
        }
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
    
    private func switchRootView(to viewController: UIViewController) {
        guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else { return }
        // 네비게이션 컨트롤러 생성
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.tintColor = .font
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}


// 애플 인증 로그인 관련 프로토콜
extension AuthenticationVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

    }
}
