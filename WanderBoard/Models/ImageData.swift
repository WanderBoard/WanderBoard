//
//  ImageData.swift
//  WanderBoard
//
//  Created by 김시종 on 5/28/24.
//

import Foundation
import CoreLocation

struct ImageData {
    let url: String
    let isRepresentative: Bool
    let location: CLLocationCoordinate2D?
    
    init(url: String, isRepresentative: Bool, location: CLLocationCoordinate2D?) {
        self.url = url
        self.isRepresentative = isRepresentative
        self.location = location
    }
}

// MARK: - ImageData Extensions
extension ImageData: Equatable {
    static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        return lhs.url == rhs.url && 
               lhs.isRepresentative == rhs.isRepresentative &&
               lhs.location?.latitude == rhs.location?.latitude &&
               lhs.location?.longitude == rhs.location?.longitude
    }
}

extension ImageData: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(isRepresentative)
        hasher.combine(location?.latitude)
        hasher.combine(location?.longitude)
    }
}
