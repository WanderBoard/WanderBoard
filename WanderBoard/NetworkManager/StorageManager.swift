//
//  StorageManager.swift
//  WanderBoard
//
//  Created by David Jang on 6/4/24.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit
import CoreLocation
import ImageIO
import Photos


class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    private init() {}
    
//    func extractLocationFromImage(image: UIImage) -> CLLocationCoordinate2D? {
//        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
//            print("Failed to convert image to data")
//            return nil
//        }
//        
//        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
//            print("Failed to create image source")
//            return nil
//        }
//        
//        // 이미지 전체 속성 가져오는
////        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
////            print("No properties found in image data")
////            return nil
////        }
//        
////        print("Properties: \(properties)")
//        
////        guard let gpsData = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any] else {
////            print("No GPS data found in properties")
////            return nil
////        }
//        
////        print("GPS Data: \(gpsData)")
//        
//        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
//              let gpsData = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any] else {
//            return nil
//        }
//        
//        guard let latitude = gpsData[kCGImagePropertyGPSLatitude] as? Double,
//              let longitude = gpsData[kCGImagePropertyGPSLongitude] as? Double,
//              let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef] as? String,
//              let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef] as? String else {
//            print("Incomplete GPS data")
//            return nil
//        }
//        
//        let lat = latitudeRef == "S" ? -latitude : latitude
//        let lon = longitudeRef == "W" ? -longitude : longitude
//        
//        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
//    }
    
    func extractLocation(from data: Data) -> CLLocationCoordinate2D? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("Failed to create image source")
            return nil
        }
        
//        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
//            print("No properties found in image data")
//            return nil
//        }
        
//        print("Properties: \(properties)")
        
//        guard let gpsData = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any] else {
//            print("No GPS data found in properties")
//            return nil
//        }
//        
//        print("GPS Data: \(gpsData)")
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let gpsData = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any] else {
            print("No GPS data found in properties")
            return nil
        }
        
        guard let latitude = gpsData[kCGImagePropertyGPSLatitude] as? Double,
              let longitude = gpsData[kCGImagePropertyGPSLongitude] as? Double,
              let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef] as? String,
              let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef] as? String else {
                  print("Incomplete GPS data")
                  return nil
              }

        let lat = latitudeRef == "S" ? -latitude : latitude
        let lon = longitudeRef == "W" ? -longitude : longitude
        
        // GPS 정밀도 확인
        if gpsData[kCGImagePropertyGPSHPositioningError] is Double {
        }

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    // 이미지와 위치 메타데이터를 업로드하는 메서드
    func uploadImage(image: UIImage, userId: String, isRepresentative: Bool = false) async throws -> Media {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 데이터를 변환하는 데 실패했습니다."])
        }
        
        let fileName = UUID().uuidString
        let storageRef = storage.reference().child("images/\(userId)/\(fileName).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 이미지 업로드
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        
        // 다운로드 URL 가져오기
        let downloadURL = try await storageRef.downloadURL()
        
        // 위치 메타데이터 추출
        var media: Media
        if let location = extractLocation(from: imageData) {
            let customMetadata = [
                "latitude": "\(location.latitude)",
                "longitude": "\(location.longitude)"
            ]
            
            let updatedMetadata = StorageMetadata()
            updatedMetadata.customMetadata = customMetadata
            
            // 메타데이터를 업데이트
            _ = try await storageRef.updateMetadataAsync(updatedMetadata)
            print("😃", updatedMetadata.customMetadata ?? "No metadata")
            
            media = Media(url: downloadURL.absoluteString, latitude: location.latitude, longitude: location.longitude, dateTaken: Date(), isRepresentative: isRepresentative)
        } else {
            print("No location data found")
            media = Media(url: downloadURL.absoluteString, latitude: nil, longitude: nil, dateTaken: Date(), isRepresentative: isRepresentative)
        }
        
        return media
    }
}

extension StorageReference {
    func updateMetadataAsync(_ metadata: StorageMetadata) async throws -> StorageMetadata {
        try await withCheckedThrowingContinuation { continuation in
            self.updateMetadata(metadata) { updatedMetadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let updatedMetadata = updatedMetadata {
                    continuation.resume(returning: updatedMetadata)
                } else {
                    continuation.resume(throwing: NSError(domain: "StorageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }

    func putDataAsync(_ data: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
        try await withCheckedThrowingContinuation { continuation in
            self.putData(data, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: NSError(domain: "StorageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }
}
