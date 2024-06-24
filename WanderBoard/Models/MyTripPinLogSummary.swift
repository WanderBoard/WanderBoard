//
//  MyTripPinLogSummary.swift
//  WanderBoard
//
//  Created by Luz on 6/23/24.
//

import Foundation

struct MyTripPinLogSummary: Codable {
    var id: String?
    var location: String
    var startDate: Date
    var endDate: Date
    var representativeMediaURL: String?
    var isPublic: Bool
    var authorId: String
    var createdAt: Date
}

