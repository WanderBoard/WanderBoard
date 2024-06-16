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
        progressView.view.frame = view.bounds//프로그래스 뷰가 화면 다 덮도록
        //기존의 디테일 인풋에서 프로그래스 뷰로 넘어오는거기 때문에 이걸 추가해주지 않으면 아무리 프로그래스 뷰의 투명도를 설정해도 배경색이 시스템상에 저장되어 있어서 위에 투명하게 덮인효과 못 냄
        progressView.view.backgroundColor = .clear
        progressView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        progressView.didMove(toParent: self)
    }
}

