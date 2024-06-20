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
        
        return createButton(withImageName: "x.circle", target: target, action: action)
    }
    
    static func createPenButton(target: Any?, action: Selector) -> UIButton {
        return createButton(withImageName: "pencil.circle", target: target, action: action)
    }
    
    static func createBackButton(target: Any?, action: Selector) -> UIButton {
        return createButton(withImageName: "lessthan.circle", target: target, action: action)
    }
    
    static func createSaveButton(target: Any?, action: Selector) -> UIButton {
        return createButton(withImageName: "square.and.arrow.down", target: target, action: action)
    }
    
    static func createPinButton(target: Any?, action: Selector) -> UIButton {
        return createButton(withImageName: "pin.circle", target: target, action: action)
    }
    
    private static func createButton(withImageName imageName: String, target: Any?, action: Selector) -> UIButton {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        let image = UIImage(systemName: imageName, withConfiguration: imageConfig)
        
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
    
}

func createSearchButton(target: Any?, action: Selector) -> UIButton {
    return createButton(withImageName: "magnifyingglass", target: target, action: action)
}

private func createButton(withImageName imageName: String, target: Any?, action: Selector) -> UIButton {
    let button = UIButton()
    let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .light)
    let image = UIImage(systemName: imageName, withConfiguration: imageConfig)
    
    button.setImage(image, for: .normal)
    button.tintColor = .black
    button.addTarget(target, action: action, for: .touchUpInside)
    return button
}





