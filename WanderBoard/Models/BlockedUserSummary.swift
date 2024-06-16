//
//  BlockedUserSummary.swift
//  WanderBoard
//
//  Created by Luz on 6/16/24.
//

import Foundation

struct BlockedUserSummary: Codable, Hashable {
  let uid: String
  let email: String
  let displayName: String
  let photoURL: String?
  var isBlocked: Bool // 차단 여부를 나타내는 속성
  func hash(into hasher: inout Hasher) {
    hasher.combine(uid)
  }
  static func == (lhs: BlockedUserSummary, rhs: BlockedUserSummary) -> Bool {
    return lhs.uid == rhs.uid
  }
}
