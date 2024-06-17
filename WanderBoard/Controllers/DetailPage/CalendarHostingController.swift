//
//  CalendarHostingController.swift
//  WanderBoard
//
//  Created by David Jang on 6/16/24.
//

import SwiftUI
import UIKit
import SnapKit


protocol CalendarHostingControllerDelegate: AnyObject {
    func didSelectDates(startDate: Date, endDate: Date)
}

class CalendarHostingController: UIViewController {
    weak var delegate: CalendarHostingControllerDelegate?
//    var onDatesSelected: ((Date, Date) -> Void)?

    private lazy var hostingController: UIHostingController<CalendarView> = {
        let calendarView = CalendarView(onDatesSelected: { [weak self] startDate, endDate in
            self?.delegate?.didSelectDates(startDate: startDate, endDate: endDate)
            self?.dismiss(animated: true, completion: nil)
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
            make.height.equalTo(460)
        }
    }
}

