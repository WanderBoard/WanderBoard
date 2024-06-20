//
//  LaunchViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/16/24.
//

import SwiftUI
import SnapKit
import UIKit

class LaunchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue // 배경색 설정

        
        let wavesView = WavesView()
        let hostingController = UIHostingController(rootView: wavesView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // SnapKit을 사용하여 제약 조건 설정
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        hostingController.didMove(toParent: self)
    }
}

