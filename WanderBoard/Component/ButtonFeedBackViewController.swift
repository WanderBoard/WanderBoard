//
//  ButtonFeedBackViewController.swift
//  WanderBoard
//
//  Created by David Jang on 7/1/24.
//

import UIKit
import SwiftUI
import SnapKit

class ButtonFeedBackViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let completedView = UIHostingController(rootView: ButtonFeedBack())
        addChild(completedView)
        view.addSubview(completedView.view)
        completedView.view.backgroundColor = .clear
        
        completedView.view.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        completedView.didMove(toParent: self)
    }
}


