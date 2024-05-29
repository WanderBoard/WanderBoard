//
//  Numeric.swift
//  WanderBoard
//
//  Created by David Jang on 5/29/24.
//

import Foundation

// Int -> String
extension Numeric {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}
