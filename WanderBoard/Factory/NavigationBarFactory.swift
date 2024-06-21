//
//  ButtonManager.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 6/14/24.
//

import UIKit

class ButtonFactory {
    static func createXButton(target: Any?, action: Selector) -> UIButton {
        return createButton(withImageName: "x.circle.fill", target: target, action: action, tintColor: UIColor(named: "textColor")!, alpha: 0.5)
    }
    
    private static func createButton(withImageName imageName: String, target: Any?, action: Selector, tintColor: UIColor = .darkgray, alpha: CGFloat = 1.0) -> UIButton {
        let button = UIButton(type: .system)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: imageName, withConfiguration: imageConfig)
        
        button.setImage(image, for: .normal)
        button.tintColor = tintColor
        button.alpha = alpha
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
}

