//
//  AuthenticationManager.swift
//  WanderBoard
//
//  Created by David Jang on 5/28/24.
//

import Foundation
import FirebaseAuth
import CoreData
import UIKit
import FirebaseFirestore
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKUser


// FireBase 데이터 저장 변수, 인증 로그인 후 받아오는 정보
struct AuthDataResultModel {
    let uid: String
    let email: String?
    let displayName: String?
    let photoURL: String?
    var socialMediaLink: String?
    let authProvider: AuthProviderOption
    
    init(user: FirebaseAuth.User, authProvider: AuthProviderOption) {
        self.uid = user.uid
        self.email = user.email
        self.displayName = user.displayName
        self.photoURL = user.photoURL?.absoluteString
        self.socialMediaLink = nil
        self.authProvider = authProvider
    }
}

// 인증 제공 식별자? FireBase providerID
enum AuthProviderOption: String, Codable {
    case google = "google.com"
    case apple = "apple.com"
    case kakao = "kakao.com"
    case email = "email"
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() {}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        // authProvider를 포함하여 초기화
        let providerData = user.providerData
        var authProvider: AuthProviderOption = .email // 기본값 설정
        for provider in providerData {
            if let providerType = AuthProviderOption(rawValue: provider.providerID) {
                authProvider = providerType
                break
            }
        }
        return AuthDataResultModel(user: user, authProvider: authProvider)
    }

    // 변경된 이메일 중복 확인 메서드
    func checkEmailExists(email: String) async -> Bool {
        do {
            _ = try await Auth.auth().createUser(withEmail: email, password: "temporaryPassword")
            // 임시 사용자가 생성되면 삭제
            let user = Auth.auth().currentUser
            try await user?.delete()
            return false
        } catch let error as NSError {
            if let errorCode = AuthErrorCode.Code(rawValue: error.code), errorCode == .emailAlreadyInUse {
                return true
            } else {
                // 다른 에러 발생 시 false 반환
                return false
            }
        }
    }
    
    // 현재 사용자 가져오기
    func getCurrentUser() -> AuthDataResultModel? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        
        let authProvider = AuthProviderOption(rawValue: currentUser.providerData.first?.providerID ?? "") ?? .google
        return AuthDataResultModel(user: currentUser, authProvider: authProvider)
    }

    // 코어 데이터 저장
    @MainActor
    private func saveUserToCoreData(uid: String, email: String, displayName: String?, photoURL: String?, socialMediaLink: String?, authProvider: AuthProviderOption) throws -> UserEntity {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            ErrorUtility.shared.presentErrorAlertAndTerminate(with: "앱 초기화 중 문제가 발생했습니다. 다시 시도해주세요. 🥲")
            throw NSError(domain: "AppDelegateError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not cast UIApplication delegate to AppDelegate"])
        }
        let context = appDelegate.persistentContainer.viewContext
        let userEntity = UserEntity(context: context)
        userEntity.uid = uid
        userEntity.email = email
        userEntity.displayName = displayName
        userEntity.photoURL = photoURL
        userEntity.socialMediaLink = socialMediaLink
        userEntity.authProvider = authProvider.rawValue
        
        try context.save()
        
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        
        return userEntity
    }
    
    func signInWithKakao(tokens: KakaoSignInResult) async throws -> AuthDataResultModel {
        do {
            let customToken = try await getCustomTokenFromServer(uid: tokens.token)
            let credential = OAuthProvider.credential(withProviderID: "oidc.kakao", idToken: customToken, accessToken: tokens.token)
            let authDataResult = try await signIn(credential: credential)
            
            await MainActor.run {
                do {
                    _ = try self.saveUserToCoreData(uid: authDataResult.uid, email: tokens.email ?? "", displayName: tokens.nickname, photoURL: tokens.profileImageUrl?.absoluteString, socialMediaLink: nil, authProvider: .kakao)
                } catch {
                    ErrorUtility.shared.presentErrorAlertAndTerminate(with: "사용자 정보를 저장하는 중 문제가 발생했습니다. 다시 시도해주세요.")
                }
            }
            
            do {
                try await FirestoreManager.shared.saveUser(uid: authDataResult.uid, email: tokens.email ?? "", displayName: tokens.nickname, photoURL: tokens.profileImageUrl?.absoluteString, socialMediaLink: nil, authProvider: AuthProviderOption.kakao.rawValue)
            } catch {
                print("Firestore save error: \(error)")
                await ErrorUtility.shared.presentErrorAlert(with: "서버에 사용자 정보를 저장하는 중 문제가 발생했습니다. 다시 시도해주세요.")
                throw error
            }
            
            try await updateUserProfileFromFirestore()
            return authDataResult
        } catch {
            await ErrorUtility.shared.presentErrorAlert(with: "Kakao 로그인 중 문제가 발생했습니다. 다시 시도해주세요.")
            throw error
        }
    }
    
    private func getCustomTokenFromServer(uid: String) async throws -> String {
        let url = URL(string: "https://YOUR_CLOUD_FUNCTIONS_URL/createCustomToken")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["uid": uid])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "FirebaseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get custom token from server"])
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        return json["token"] as! String
    }

    
    // 구글 로그인 결과 처리 및 코어데이터 저장
    func signInWithGoogle(tokens: GoogleSignInResult) async throws -> AuthDataResultModel {
        do {
            let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken) // 생성
            let authDataResult = try await signIn(credential: credential) // 인증
            
            // 코어데이터 저장
            await MainActor.run {
                do {
                    _ = try self.saveUserToCoreData(uid: authDataResult.uid, email: tokens.email ?? "", displayName: tokens.displayName, photoURL: tokens.profileImageUrl?.absoluteString, socialMediaLink: nil, authProvider: .google)
                } catch {
                    ErrorUtility.shared.presentErrorAlertAndTerminate(with: "사용자 정보를 저장하는 중 문제가 발생했습니다. 다시 시도해주세요.")
                }
            }
            
            // FireStore 저장
            do {
                try await FirestoreManager.shared.saveUser(uid: authDataResult.uid, email: tokens.email ?? "", displayName: tokens.displayName, photoURL: tokens.profileImageUrl?.absoluteString, socialMediaLink: nil, authProvider: AuthProviderOption.google.rawValue)
            } catch {
                await ErrorUtility.shared.presentErrorAlert(with: "서버에 사용자 정보를 저장하는 중 문제가 발생했습니다. 다시 시도해주세요.")
                throw error
            }
            
            try await updateUserProfileFromFirestore() // FireStore 정보 업데이트
            
            return authDataResult // 인증 결과 반환
        } catch {
            await ErrorUtility.shared.presentErrorAlert(with: "Google 로그인 중 문제가 발생했습니다. 다시 시도해주세요.")
            throw error
        }
    }
    
    // 애플 로그인 결과 처리 및 코어데이터 저장
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        do {
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokens.token, rawNonce: tokens.nonce) // 생성
            let authDataResult = try await signIn(credential: credential) // 인증
            
            // 코어데이터 저장
            await MainActor.run {
                do {
                    _ = try self.saveUserToCoreData(uid: authDataResult.uid, email: tokens.email ?? "", displayName: tokens.displayName, photoURL: nil, socialMediaLink: nil, authProvider: .apple)
                } catch {
                    ErrorUtility.shared.presentErrorAlertAndTerminate(with: "사용자 정보를 저장하는 중 문제가 발생했습니다. 다시 시도해주세요.")
                }
            }
            
            // FireStore 저장
            do {
                try await FirestoreManager.shared.saveUser(uid: authDataResult.uid, email: tokens.email ?? "", displayName: tokens.displayName, photoURL: nil, socialMediaLink: nil, authProvider: AuthProviderOption.apple.rawValue)
            } catch {
                await ErrorUtility.shared.presentErrorAlert(with: "서버에 사용자 정보를 저장하는 중 문제가 발생했습니다. 다시 시도해주세요.")
                throw error
            }
            
            try await updateUserProfileFromFirestore() // FireStore 정보 업데이트
            
            return authDataResult // 인증 결과 반환
        } catch {
            await ErrorUtility.shared.presentErrorAlert(with: "Apple 로그인 중 문제가 발생했습니다. 다시 시도해주세요.")
            throw error
        }
    }

    // 파이어베이스에 인증 요청
    private func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        do {
            let authDataResult = try await Auth.auth().signIn(with: credential)
            let providerData = authDataResult.user.providerData
            var authProvider: AuthProviderOption = .google
            for provider in providerData {
                if let providerType = AuthProviderOption(rawValue: provider.providerID) {
                    authProvider = providerType
                    break
                }
            }
            return AuthDataResultModel(user: authDataResult.user, authProvider: authProvider)
        } catch {
            await ErrorUtility.shared.presentErrorAlert(with: "로그인 중 문제가 발생했습니다. 다시 시도해주세요.")
            throw error
        }
    }
    
    // FireStore 연결, 사용자 데이터 가져옴
    func updateUserProfileFromFirestore() async throws {
        do {
            guard let user = Auth.auth().currentUser else {
                await ErrorUtility.shared.presentErrorAlert(with: "사용자 정보를 확인할 수 없습니다. 다시 로그인해 주세요.")
                throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch current user. User is nil."])
            }
            let userRef = Firestore.firestore().collection("users").document(user.uid)
            let document = try await userRef.getDocument()
            guard let data = document.data() else {
                await ErrorUtility.shared.presentErrorAlert(with: "사용자 데이터를 불러오는 중 문제가 발생했습니다. 다시 시도해 주세요.")
                throw NSError(domain: "FirestoreError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user data from Firestore. Data is nil."])
            }
            let displayName = data["displayName"] as? String
            let photoURL = data["photoURL"] as? String

            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.photoURL = URL(string: photoURL ?? "")
            try await changeRequest.commitChanges()
        } catch {
            await ErrorUtility.shared.presentErrorAlert(with: "프로필을 업데이트하는 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.")
            throw error
        }
    }

    // SignOut FireBase와 연결 해제
    @MainActor
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
        } catch {
            ErrorUtility.shared.presentErrorAlert(with: "로그아웃 중 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.")
            throw error
        }
    }
}
