//
//  PinLogSummary.swift
//  WanderBoard
//
//  Created by Luz on 6/19/24.
//

import Foundation

struct RecentPinLogSummary: Codable, Hashable {
    let id: String?
    let authorId: String
    let startDate: Date
    let location: String
    let createdAt: Date?
    let representativeMediaUrl: String?
    let media: [Media]
    let pinnedBy: [String]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RecentPinLogSummary, rhs: RecentPinLogSummary) -> Bool {
        return lhs.id == rhs.id
    }
}
