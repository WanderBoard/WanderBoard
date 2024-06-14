//
//  UserSummary.swift
//  WanderBoard
//
//  Created by 김시종 on 6/13/24.
//

import Foundation

struct UserSummary: Codable, Hashable {
    let uid: String
    let email: String
    let displayName: String
    let photoURL: String?
    var isMate: Bool

    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
    
    static func == (lhs: UserSummary, rhs: UserSummary) -> Bool {
        return lhs.uid == rhs.uid
    }
}
