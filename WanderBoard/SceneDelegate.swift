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
        
        let initialViewController: UIViewController
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            // 사용자가 로그인된 상태
            initialViewController = PageViewController()
        } else {
            initialViewController = LaunchViewController()
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                self.window?.rootViewController = PageViewController()
                self.window?.makeKeyAndVisible()
            }
            return
        }
        
        window?.rootViewController = initialViewController
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

