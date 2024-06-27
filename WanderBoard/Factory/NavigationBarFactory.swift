//
//  ButtonManager.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 6/14/24.
//

import UIKit

class ButtonFactory {
    static func createBackButton(title: String = "Back") -> UIBarButtonItem {
        let backButton = UIBarButtonItem()
        backButton.title = title
        return backButton
    }
}

