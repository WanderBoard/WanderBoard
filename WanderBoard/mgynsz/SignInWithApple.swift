//
//  SignInWithApple.swift
//  WanderBoard
//
//  Created by David Jang on 5/28/24.
//

import Foundation
import CryptoKit
import AuthenticationServices
import UIKit

struct SignInWithAppleResult {
    let token: String
    let nonce: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let fullName: String?

    var displayName: String? {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else {
            return firstName ?? lastName
        }
    }

    init?(authorization: ASAuthorization, nonce: String) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let token = String(data: appleIDToken, encoding: .utf8)
        else {
            return nil
        }

        self.token = token
        self.nonce = nonce
        self.email = appleIDCredential.email
        self.firstName = appleIDCredential.fullName?.givenName
        self.lastName = appleIDCredential.fullName?.familyName
        self.fullName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName].compactMap { $0 }.joined(separator: " ")
    }
}

final class SignInWithAppleHelper: NSObject {
        
    private var currentNonce: String? = nil
    private var continuation: CheckedContinuation<SignInWithAppleResult, Error>?
    
    @MainActor
    func startSignInWithAppleFlow(viewController: UIViewController? = nil) async throws -> SignInWithAppleResult {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.startSignInWithAppleFlow(viewController: viewController)
        }
    }
    
    @MainActor
    private func startSignInWithAppleFlow(viewController: UIViewController? = nil) {
        guard let topVC = viewController ?? Utilities.shared.topViewController() else {
            continuation?.resume(throwing: SignInWithAppleError.noViewController)
            return
        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        showOSPrompt(nonce: nonce, on: topVC)
    }
}

// MARK: PRIVATE
private extension SignInWithAppleHelper {
        
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func showOSPrompt(nonce: String, on viewController: UIViewController) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = viewController

        authorizationController.performRequests()
    }
    
    private enum SignInWithAppleError: LocalizedError {
        case noViewController
        case invalidCredential
        case badResponse
        case unableToFindNonce
        
        var errorDescription: String? {
            switch self {
            case .noViewController:
                return "Could not find top view controller."
            case .invalidCredential:
                return "Invalid sign in credential."
            case .badResponse:
                return "Apple Sign In had a bad response."
            case .unableToFindNonce:
                return "Apple Sign In token expired."
            }
        }
    }
    
}

extension SignInWithAppleHelper: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        do {
            guard let currentNonce else {
                throw SignInWithAppleError.unableToFindNonce
            }
            
            guard let result = SignInWithAppleResult(authorization: authorization, nonce: currentNonce) else {
                throw SignInWithAppleError.badResponse
            }
            
            continuation?.resume(returning: result)
        } catch {
            continuation?.resume(throwing: error)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
