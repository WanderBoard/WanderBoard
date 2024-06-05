//
//  PinLog.swift
//  WanderBoard
//
//  Created by David Jang on 5/30/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

struct Media: Codable {
    var url: String
    var latitude: Double?
    var longitude: Double?
    var dateTaken: Date?

    var location: CLLocation? {
        get {
            guard let latitude = latitude, let longitude = longitude else { return nil }
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue?.coordinate.latitude
            longitude = newValue?.coordinate.longitude
        }
    }
}

struct PinLog: Identifiable, Codable {
    @DocumentID var id: String?
    var location: String
    var startDate: Date
    var endDate: Date
    var duration: Int
    var title: String
    var content: String
    var media: [Media]
    var authorId: String
    var attendeeIds: [String]
    var isPublic: Bool
    
    init(id: String? = nil, location: String, startDate: Date, endDate: Date, title: String, content: String, media: [Media], authorId: String, attendeeIds: [String], isPublic: Bool) {
        self.id = id
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.duration = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        self.title = title
        self.content = content
        self.media = media
        self.authorId = authorId
        self.attendeeIds = attendeeIds
        self.isPublic = isPublic
    }
}