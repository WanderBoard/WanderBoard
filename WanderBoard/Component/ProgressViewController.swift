//
//  ProgressViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/16/24.
//

import UIKit
import SwiftUI
import SnapKit

class ProgressViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let progressView = UIHostingController(rootView: ProgressView())
        addChild(progressView)
        view.addSubview(progressView.view)
        
        progressView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        progressView.didMove(toParent: self)
    }
}

