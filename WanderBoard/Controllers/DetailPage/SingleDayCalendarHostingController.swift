//
//  SingleDayCalendarHostingController.swift
//  WanderBoard
//
//  Created by David Jang on 6/20/24.
//

import SwiftUI
import UIKit
import SnapKit

protocol SingleDayCalendarHostingControllerDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

class SingleDayCalendarHostingController: UIViewController {
    weak var delegate: SingleDayCalendarHostingControllerDelegate?

    private lazy var hostingController: UIHostingController<SingleDayCalendarView> = {
        let calendarView = SingleDayCalendarView(onDateSelected: { [weak self] date in
            self?.delegate?.didSelectDate(date)
//            self?.dismiss(animated: true, completion: nil)
        })
        let controller = UIHostingController(rootView: calendarView)
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
