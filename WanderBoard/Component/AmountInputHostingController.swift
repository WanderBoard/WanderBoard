//
//  AmountInputHostingController.swift
//  WanderBoard
//
//  Created by David Jang on 6/26/24.
//

import SwiftUI
import UIKit
import SnapKit

protocol AmountInputHostingControllerDelegate: AnyObject {
    func didEnterAmount(_ amount: Double)
}

class AmountInputHostingController: UIViewController {
    weak var delegate: AmountInputHostingControllerDelegate?

    private lazy var hostingController: UIHostingController<AmountInputView> = {
        let amountView = AmountInputView(onAmountEntered: { [weak self] amount in
            guard let self = self else { return }
            self.delegate?.didEnterAmount(amount)
            self.dismiss(animated: true)
        })
        let controller = UIHostingController(rootView: amountView)
        addChild(controller)
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
//            make.height.equalTo(460)
        }
    }
}

