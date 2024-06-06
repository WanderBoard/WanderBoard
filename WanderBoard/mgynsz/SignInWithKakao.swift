//
//  SignInWithKakao.swift
//  WanderBoard
//
//  Created by David Jang on 5/29/24.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import FirebaseAuth

struct KakaoSignInResult {
    let token: String
    let email: String?
    let nickname: String?
    let profileImageUrl: URL?
    
    init?(oauthToken: OAuthToken, user: KakaoSDKUser.User?) {
        self.token = oauthToken.accessToken
        self.email = user?.kakaoAccount?.email
        self.nickname = user?.kakaoAccount?.profile?.nickname
        self.profileImageUrl = user?.kakaoAccount?.profile?.profileImageUrl
    }
}

final class SignInWithKakaoHelper {
    @MainActor
    func signIn() async throws -> KakaoSignInResult {
        return try await withCheckedThrowingContinuation { continuation in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        UserApi.shared.me { (user, error) in
                            if let user = user, let oauthToken = oauthToken {
                                if let result = KakaoSignInResult(oauthToken: oauthToken, user: user) {
                                    continuation.resume(returning: result)
                                } else {
                                    continuation.resume(throwing: NSError(domain: "SignInWithKakaoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize KakaoSignInResult"]))
                                }
                            } else {
                                continuation.resume(throwing: NSError(domain: "SignInWithKakaoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user information"]))
                            }
                        }
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        UserApi.shared.me { (user, error) in
                            if let user = user, let oauthToken = oauthToken {
                                if let result = KakaoSignInResult(oauthToken: oauthToken, user: user) {
                                    continuation.resume(returning: result)
                                } else {
                                    continuation.resume(throwing: NSError(domain: "SignInWithKakaoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize KakaoSignInResult"]))
                                }
                            } else {
                                continuation.resume(throwing: NSError(domain: "SignInWithKakaoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user information"]))
                            }
                        }
                    }
                }
            }
        }
    }
}

// Firebase 인증과 연동
//func signInWithKakao(kakaoToken: String) async throws -> AuthDataResultModel {
//    let credential = OAuthProvider.credential(withProviderID: "kakao.com", idToken: kakaoToken, rawNonce: nil)
//    let authDataResult = try await Auth.auth().signIn(with: credential)
//    let authProvider = AuthProviderOption.kakao
//    return AuthDataResultModel(user: authDataResult.user, authProvider: authProvider)
//}
//
//func signInWithEmailAndPassword(email: String, password: String) async throws -> AuthDataResultModel {
//    let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
//    let authProvider = AuthProviderOption.email
//    return AuthDataResultModel(user: authDataResult.user, authProvider: authProvider)
//}
//
//func createUserWithEmailAndPassword(email: String, password: String) async throws -> AuthDataResultModel {
//    let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
//    let authProvider = AuthProviderOption.email
//    return AuthDataResultModel(user: authDataResult.user, authProvider: authProvider)
//}
