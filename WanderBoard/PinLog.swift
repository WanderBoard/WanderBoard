//
//  PinLog.swift
//  WanderBoard
//
//  Created by David Jang on 5/30/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PinLog: Identifiable, Codable {
    @DocumentID var id: String?
    var location: String
    var startDate: Date
    var endDate: Date
    var duration: Int
    var title: String
    var content: String
    var mediaURL: [String]
    var authorId: String
    var attendeeIds: [String]
    var isPublic: Bool
    
    init(id: String? = nil, location: String, startDate: Date, endDate: Date, title: String, content: String, mediaURL: [String], authorId: String, attendeeIds: [String], isPublic: Bool) {
        self.id = id
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.duration = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        self.title = title
        self.content = content
        self.mediaURL = mediaURL
        self.authorId = authorId
        self.attendeeIds = attendeeIds
        self.isPublic = isPublic
    }
}
