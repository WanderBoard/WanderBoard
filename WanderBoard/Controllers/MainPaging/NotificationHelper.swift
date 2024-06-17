//
//  NotificationHelper.swift
//  WanderBoard
//
//  Created by Luz on 6/9/24.
//

import Foundation

class NotificationHelper {
    
    static func changePage(hidden: Bool, isEnabled: Bool) {
        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": hidden])
        NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": isEnabled])
    }
}


extension Notification.Name {
    static let setPageControlButtonVisibility = Notification.Name("setPageControlButtonVisibility")
    static let didChangePage = Notification.Name("didChangePage")
    static let setScrollEnabled = Notification.Name("setScrollEnabled")
}

