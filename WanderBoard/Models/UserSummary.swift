//
//  UserSummary.swift
//  WanderBoard
//
//  Created by 김시종 on 6/13/24.
//

import Foundation

struct UserSummary: Codable {
    let uid: String
    let displayName: String
    let photoURL: String?
    var isMate: Bool
}
