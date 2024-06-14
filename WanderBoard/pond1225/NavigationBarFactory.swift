//
//  ButtonManager.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 6/14/24.
//

import UIKit

class NavigationBarFactory {
    static func createNavigationBar(withTitle title: String, target: Any?, leftButtons: [UIButton] = [], rightButtons: [UIButton] = []) -> UINavigationBar {
            let navigationBar = UINavigationBar()
            let navItem = UINavigationItem(title: title)
            
            if !leftButtons.isEmpty {
                navItem.leftBarButtonItems = leftButtons.map { UIBarButtonItem(customView: $0) }
            }
            
            if !rightButtons.isEmpty {
                navItem.rightBarButtonItems = rightButtons.map { UIBarButtonItem(customView: $0) }
            }
            
            navigationBar.setItems([navItem], animated: false)
        
        navigationBar.backgroundColor = .white
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        
            return navigationBar
        }
    
}


class ButtonFactory {
    
    static func createXButton(target: Any?, action: Selector) -> UIButton {
            return createButton(systemName: "x.circle", target: target, action: action)
        }
        
        static func createPenButton(target: Any?, action: Selector) -> UIButton {
            return createButton(systemName: "pencil.circle", target: target, action: action)
        }
        
        static func createBackButton(target: Any?, action: Selector) -> UIButton {
            return createButton(systemName: "lessthan.circle", target: target, action: action)
        }
        
        static func createSaveButton(target: Any?, action: Selector) -> UIButton {
            return createButton(systemName: "square.and.arrow.down", target: target, action: action)
        }
        
        static func createPinButton(target: Any?, action: Selector) -> UIButton {
            return createButton(systemName: "pin.circle", target: target, action: action)
        }
        
        private static func createButton(systemName: String, target: Any?, action: Selector) -> UIButton {
            let button = UIButton()
            button.setImage(UIImage(systemName: systemName), for: .normal)
            button.tintColor = .black
            button.addTarget(target, action: action, for: .touchUpInside)
            return button
        }
    }
    
    


