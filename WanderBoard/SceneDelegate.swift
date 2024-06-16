//
//  SceneDelegate.swift
//  WanderBoard
//
//  Created by 김시종 on 5/28/24.
//

import UIKit
import SwiftUI
import GoogleSignIn
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            // 사용자가 로그인된 상태
            window?.rootViewController = PageViewController()
        } else {
            // 사용자 로그아웃 상태 시 LaunchViewController를 2초 동안 보여준 후 AuthenticationVC로 이동
            let launchViewController = LaunchViewController()
            window?.rootViewController = launchViewController
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.window?.rootViewController = AuthenticationVC()
                self.window?.makeKeyAndVisible()
            }
        }
        
        window?.makeKeyAndVisible()
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    func sceneWillResignActive(_ scene: UIScene) { }
    
    func sceneWillEnterForeground(_ scene: UIScene) { }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

