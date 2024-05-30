//
//  Formatter.swift
//  WanderBoard
//
//  Created by David Jang on 5/29/24.
//

import Foundation

// 숫자 단위 구분점
extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
