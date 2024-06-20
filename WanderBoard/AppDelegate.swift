//
//  AppDelegate.swift
//  WanderBoard
//
//  Created by 김시종 on 5/28/24.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import KakaoSDKCommon
import KakaoSDKAuth


@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        if FirebaseApp.app() == nil {
            ErrorUtility.shared.presentErrorAlertAndTerminate(with: "앱 초기화에 실패했습니다. 나중에 다시 시도해 주세요.")
            
            return false
        }
        
        KakaoSDK.initSDK(appKey: "bc1969cc0cd1ae85004329699d424b47")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        configureInitialViewController()
        applySavedUserInterfaceStyle()
        
        return true
    }
    
    //세팅뷰컨에서 설정해준 키값을 가져와 앱이 실행될때 반영되도록 설정하는 함수
    //프린트 넣어보고 어떤 설정값인지 확인
    private func applySavedUserInterfaceStyle() {
        let isAutomatic = UserDefaults.standard.bool(forKey: "isAutomatic")
        let selectedMode = UserDefaults.standard.string(forKey: "modeSelected") ?? "light"
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = windowScene.windows.first
            if isAutomatic {
                let hour = Calendar.current.component(.hour, from: Date())
                if hour >= 18 || hour < 6 {
                    window?.overrideUserInterfaceStyle = .dark
                } else {
                    window?.overrideUserInterfaceStyle = .light
                }
            } else {
                if selectedMode == "dark" {
                    window?.overrideUserInterfaceStyle = .dark
                } else {
                    window?.overrideUserInterfaceStyle = .light
                }
            }
        }
    }
    
     private func configureInitialViewController() {
         let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
         let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
         let initialViewController: UIViewController
         
         if !hasLaunchedBefore {
             UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
             initialViewController = TutorialViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
         } else if isLoggedIn, let currentUser = Auth.auth().currentUser {
             let uid = currentUser.uid
             Firestore.firestore().collection("users").document(uid).getDocument { (document, error) in
                 if let document = document, document.exists {
                     let data = document.data()
                     let isProfileComplete = data?["isProfileComplete"] as? Bool ?? false
                     DispatchQueue.main.async {
                         if isProfileComplete {
                             self.window?.rootViewController = PageViewController()
                         } else {
                             self.window?.rootViewController = AuthenticationVC()
                         }
                         self.window?.makeKeyAndVisible()
                     }
                 } else {
                     DispatchQueue.main.async {
                         self.window?.rootViewController = AuthenticationVC()
                         self.window?.makeKeyAndVisible()
                     }
                 }
             }
             return
         } else {
             // 사용자 로그아웃 상태 시 LaunchViewController를 3초 동안 보여준 후 AuthenticationVC로 이동
             initialViewController = LaunchViewController()
             window?.rootViewController = initialViewController
             window?.makeKeyAndVisible()
             
             DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                 self.window?.rootViewController = AuthenticationVC()
                 self.window?.makeKeyAndVisible()
             }
             return
         }
         
         window?.rootViewController = initialViewController
         window?.makeKeyAndVisible()
     }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WanderBoard")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
