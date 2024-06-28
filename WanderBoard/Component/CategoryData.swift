//
//  CategoryData.swift
//  WanderBoard
//
//  Created by David Jang on 6/28/24.
//

import Foundation

struct CategoryData {
    static let categories = [
        ("food", "식비"),
        ("car", "교통비"),
        ("hotel", "숙박비"),
        ("gift", "기념품비"),
        ("entertain", "문화생활비"),
        ("etc", "기타")
    ]
    
    static let categoryImageMapping: [String: String] = [
        "식비": "food",
        "교통비": "car",
        "문화생활비": "entertain",
        "기념품비": "gift",
        "숙박비": "hotel",
        "기타": "etc"
    ]
}
