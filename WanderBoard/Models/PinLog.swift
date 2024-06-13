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

//struct Media: Codable {
//    var url: String
//    var latitude: Double?
//    var longitude: Double?
//    var dateTaken: Date?
//    
//    func toDictionary() -> [String: Any] {
//        var dict: [String: Any] = ["url": url]
//        if let latitude = latitude {
//            dict["latitude"] = latitude
//        }
//        if let longitude = longitude {
//            dict["longitude"] = longitude
//        }
//        if let dateTaken = dateTaken {
//            dict["dateTaken"] = dateTaken.timeIntervalSince1970
//        }
//        return dict
//    }
//}

struct Media: Codable {
    var url: String
    var latitude: Double?
    var longitude: Double?
    var dateTaken: Date?
    var isRepresentative: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(String.self, forKey: .url)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        dateTaken = try container.decodeIfPresent(Date.self, forKey: .dateTaken)
        isRepresentative = try container.decodeIfPresent(Bool.self, forKey: .isRepresentative) ?? false // 기본 값을 false로 설정
    }

    init(url: String, latitude: Double?, longitude: Double?, dateTaken: Date?, isRepresentative: Bool = false) {
        self.url = url
        self.latitude = latitude
        self.longitude = longitude
        self.dateTaken = dateTaken
        self.isRepresentative = isRepresentative
    }
}


struct PinLog: Identifiable, Codable {
    @DocumentID var id: String?
    var location: String
    var address: String
    var latitude: Double
    var longitude: Double
    var startDate: Date
    var endDate: Date
    var duration: Int
    var title: String
    var content: String
    var media: [Media]
    var authorId: String
    var attendeeIds: [String]
    var isPublic: Bool
    var createdAt: Date?
    var pinCount: Int? //핀 갯수 추가 - 한빛
    var pinnedBy: [String]? // 핀 상태 확인 - 한빛
        var totalSpendingAmount: Double? //핀로그당 사용한 최종금액 - 시안
    
    init(id: String? = nil, location: String, address: String, latitude: Double, longitude: Double, startDate: Date, endDate: Date, title: String, content: String, media: [Media], authorId: String, attendeeIds: [String], isPublic: Bool, createdAt: Date?, pinCount:Int?, pinnedBy: [String]? = [],  totalSpendingAmount: Double?) {

        self.id = id
        self.location = location
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.startDate = startDate
        self.endDate = endDate
        self.duration = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        self.title = title
        self.content = content
        self.media = media
        self.authorId = authorId
        self.attendeeIds = attendeeIds
        self.isPublic = isPublic
        self.createdAt = createdAt
        self.pinCount = pinCount //핀 갯수 추가 - 한빛
        self.pinnedBy = pinnedBy // 핀 상태 확인 - 한빛
        self.totalSpendingAmount = totalSpendingAmount //핀로그당 사용한 최종금액 - 시안
    }
}

//
//import Foundation
//import FirebaseFirestore
//import FirebaseFirestoreSwift
//import CoreLocation
//
//struct Media: Codable {
//    var url: String
//    var latitude: Double?
//    var longitude: Double?
//    var dateTaken: Date?
//    var isRepresentative: Bool
//
//    var location: CLLocation? {
//        get {
//            guard let latitude = latitude, let longitude = longitude else { return nil }
//            return CLLocation(latitude: latitude, longitude: longitude)
//        }
//        set {
//            latitude = newValue?.coordinate.latitude
//            longitude = newValue?.coordinate.longitude
//        }
//    }
//}
//
//struct PinLog: Identifiable, Codable {
//    @DocumentID var id: String?
//    var location: String
//    var startDate: Date
//    var endDate: Date
//    var duration: Int
//    var title: String
//    var content: String
//    var media: [Media]
//    var authorId: String
//    var attendeeIds: [String]
//    var isPublic: Bool
//    var createdAt: Date?
//    
//    init(id: String? = nil, location: String, startDate: Date, endDate: Date, title: String, content: String, media: [Media], authorId: String, attendeeIds: [String], isPublic: Bool, createdAt: Date?) {
//        self.id = id
//        self.location = location
//        self.startDate = startDate
//        self.endDate = endDate
//        self.duration = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
//        self.title = title
//        self.content = content
//        self.media = media
//        self.authorId = authorId
//        self.attendeeIds = attendeeIds
//        self.isPublic = isPublic
//        self.createdAt = createdAt
//    }
//}
