//
//  ErrorUtility.swift
//  WanderBoard
//
//  Created by David Jang on 5/29/24.
//

import UIKit

@MainActor
final class ErrorUtility {

    static let shared = ErrorUtility()

    private init() {}

    // 사용자에게 에러 알리기 (앱 종료 되지 않음)
    func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        
        if let topViewController = Utilities.shared.topViewController() {
            topViewController.present(alert, animated: true, completion: nil)
        }
    }

    // 사용자에게 에러 알리고 앱 종료
    func presentErrorAlertAndTerminate(with message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            exit(0) // 앱 종료 메서드 호출
        }))
        
        if let topViewController = Utilities.shared.topViewController() {
            topViewController.present(alert, animated: true, completion: nil)
        }
    }
}

